-- =============================================================================
-- MIGRATION 0003 — FLUXO DE ENVIO E MODERAÇÃO DE MATERIAIS
-- -----------------------------------------------------------------------------
-- Em vez de deixar o front-end inserir/alterar tabelas diretamente, criamos
-- FUNÇÕES (chamadas pelo front com supabase.rpc('nome_da_funcao', {...})).
-- Vantagens:
--   * Tudo acontece numa TRANSAÇÃO: ou grava material + turmas + categorias +
--     arquivo juntos, ou não grava nada (resolve a pendência da Fase 18:
--     "todo material deve ter pelo menos uma turma").
--   * As regras de status (PENDENTE -> APROVADO etc.) ficam no banco, e
--     ninguém consegue burlá-las mexendo no código do navegador.
--   * Toda mudança de status gera histórico em MODERACAO automaticamente.
--
-- Fluxo de status permitido (definido na Fase 17):
--   PENDENTE  -> APROVADO   (moderador)
--   PENDENTE  -> REJEITADO  (moderador, motivo obrigatório)
--   REJEITADO -> PENDENTE   (autor reenviando para revisão)
--   APROVADO  -> ARQUIVADO  (moderador)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- enviar_material: cria um material PENDENTE já com turmas, categorias e arquivo.
--
-- Ordem de uso pelo front-end:
--   1. Faz upload do arquivo para o Storage, no caminho "<uid>/<nome>"
--   2. Chama esta função passando o caminho usado no upload
--
-- Retorna o id_material criado.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enviar_material(
  p_titulo           TEXT,
  p_descricao        TEXT,
  p_caminho_arquivo  TEXT,   -- caminho no Storage (ex.: "8f3c.../1732-resumo.pdf")
  p_nome_arquivo     TEXT,   -- nome original do arquivo, para exibição
  p_turmas           BIGINT[],  -- ids das turmas (pelo menos 1)
  p_categorias       BIGINT[] DEFAULT '{}'
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_autor     BIGINT := public.id_usuario_atual();  -- quem está enviando
  v_objeto    RECORD;                            -- dados do arquivo no Storage
  v_mime      TEXT;
  v_tipo      public.tipo_material;
  v_id        BIGINT;
BEGIN
  -- 1) Precisa estar logado e ter cadastro em public.usuario.
  IF v_autor IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado ou sem cadastro.' USING ERRCODE = '42501';
  END IF;

  -- 2) Validações básicas dos dados recebidos.
  IF coalesce(trim(p_titulo), '') = '' THEN
    RAISE EXCEPTION 'O título é obrigatório.';
  END IF;

  IF coalesce(cardinality(p_turmas), 0) = 0 THEN
    RAISE EXCEPTION 'Informe pelo menos uma turma para o material.';
  END IF;

  -- 3) O arquivo precisa estar na PASTA DO PRÓPRIO USUÁRIO no Storage
  --    (impede vincular o arquivo de outra pessoa).
  IF split_part(p_caminho_arquivo, '/', 1) <> auth.uid()::TEXT THEN
    RAISE EXCEPTION 'Caminho de arquivo inválido.' USING ERRCODE = '42501';
  END IF;

  -- 4) O arquivo precisa EXISTIR no bucket "materiais". Lemos o tipo (mimetype)
  --    e o tamanho direto do Storage: assim não confiamos no que o navegador diz.
  SELECT o.metadata ->> 'mimetype' AS mimetype,
         (o.metadata ->> 'size')::BIGINT AS tamanho
    INTO v_objeto
  FROM storage.objects o
  WHERE o.bucket_id = 'materiais'
    AND o.name = p_caminho_arquivo;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Arquivo não encontrado no Storage. Faça o upload antes.';
  END IF;

  -- 5) Converte o tipo MIME para o ENUM tipo_material.
  v_mime := lower(v_objeto.mimetype);
  v_tipo := CASE v_mime
              WHEN 'application/pdf' THEN 'PDF'
              WHEN 'image/jpeg'      THEN 'IMAGEM'
              WHEN 'image/png'       THEN 'IMAGEM'
              WHEN 'text/plain'      THEN 'TEXTO'
            END::public.tipo_material;

  IF v_tipo IS NULL THEN
    RAISE EXCEPTION 'Formato não permitido: %. Use PDF, JPG, PNG ou TXT.', v_mime;
  END IF;

  -- 6) Grava o material — SEMPRE como PENDENTE (aguardando moderação).
  INSERT INTO public.material (id_usuario_autor, titulo, descricao, tipo_material, status)
  VALUES (v_autor, trim(p_titulo), nullif(trim(p_descricao), ''), v_tipo, 'PENDENTE')
  RETURNING id_material INTO v_id;   -- guarda o id gerado na variável v_id

  -- 7) Liga o material às turmas. unnest() transforma o array em linhas;
  --    DISTINCT remove ids repetidos. Turma inexistente => erro de FK => nada é gravado.
  INSERT INTO public.material_turma (id_material, id_turma)
  SELECT DISTINCT v_id, t FROM unnest(p_turmas) AS t;

  -- 8) Liga às categorias (opcional).
  INSERT INTO public.material_categoria (id_material, id_categoria)
  SELECT DISTINCT v_id, c FROM unnest(coalesce(p_categorias, '{}')) AS c;

  -- 9) Grava os metadados do arquivo.
  INSERT INTO public.arquivo (id_material, nome_arquivo, caminho_arquivo, tipo_mime, tamanho_bytes)
  VALUES (v_id, coalesce(nullif(trim(p_nome_arquivo), ''), p_caminho_arquivo),
          p_caminho_arquivo, v_mime, v_objeto.tamanho);

  RETURN v_id;
END;
$$;

-- -----------------------------------------------------------------------------
-- moderar_material: usada por MODERADOR/ADMINISTRADOR para aprovar,
-- rejeitar ou arquivar. Grava o histórico em MODERACAO.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.moderar_material(
  p_id_material  BIGINT,
  p_novo_status  public.status_material,
  p_motivo       TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_moderador  BIGINT := public.id_usuario_atual();
  v_atual      public.status_material;
BEGIN
  -- 1) Só quem tem papel de moderação pode usar esta função.
  IF NOT public.pode_moderar() THEN
    RAISE EXCEPTION 'Apenas moderadores podem alterar o status.' USING ERRCODE = '42501';
  END IF;

  -- 2) Lê o status atual. FOR UPDATE "trava" a linha até o fim da transação,
  --    evitando que dois moderadores alterem o mesmo material ao mesmo tempo.
  SELECT m.status INTO v_atual
  FROM public.material m
  WHERE m.id_material = p_id_material
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Material % não encontrado.', p_id_material;
  END IF;

  -- 3) Confere se a transição é permitida para moderadores.
  IF NOT (
       (v_atual = 'PENDENTE' AND p_novo_status IN ('APROVADO', 'REJEITADO'))
    OR (v_atual = 'APROVADO' AND p_novo_status = 'ARQUIVADO')
  ) THEN
    RAISE EXCEPTION 'Transição de status não permitida: % -> %.', v_atual, p_novo_status;
  END IF;

  -- 4) Rejeição exige justificativa, para o autor saber o que corrigir.
  IF p_novo_status = 'REJEITADO' AND coalesce(trim(p_motivo), '') = '' THEN
    RAISE EXCEPTION 'Informe o motivo da rejeição.';
  END IF;

  -- 5) Garantia extra: não aprova material sem nenhuma turma vinculada.
  IF p_novo_status = 'APROVADO' AND NOT EXISTS (
    SELECT 1 FROM public.material_turma mt WHERE mt.id_material = p_id_material
  ) THEN
    RAISE EXCEPTION 'Material sem turma vinculada não pode ser aprovado.';
  END IF;

  -- 6) Atualiza o status e registra o histórico.
  UPDATE public.material SET status = p_novo_status WHERE id_material = p_id_material;

  INSERT INTO public.moderacao (id_material, id_moderador, status_anterior, status_novo, motivo, data_moderacao)
  VALUES (p_id_material, v_moderador, v_atual, p_novo_status, nullif(trim(p_motivo), ''), now());
END;
$$;

-- -----------------------------------------------------------------------------
-- reenviar_material: o AUTOR devolve um material REJEITADO para PENDENTE
-- (depois de corrigir título/descrição). Também fica no histórico; nesse
-- caso "id_moderador" registra quem fez a ação (o próprio autor).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.reenviar_material(
  p_id_material  BIGINT,
  p_motivo       TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_usuario  BIGINT := public.id_usuario_atual();
  v_autor    BIGINT;
  v_atual    public.status_material;
BEGIN
  SELECT m.id_usuario_autor, m.status INTO v_autor, v_atual
  FROM public.material m
  WHERE m.id_material = p_id_material
  FOR UPDATE;

  IF NOT FOUND OR v_autor IS DISTINCT FROM v_usuario THEN
    -- Mesma mensagem nos dois casos: não revela se o material existe.
    RAISE EXCEPTION 'Material não encontrado.' USING ERRCODE = '42501';
  END IF;

  IF v_atual <> 'REJEITADO' THEN
    RAISE EXCEPTION 'Só é possível reenviar materiais rejeitados.';
  END IF;

  UPDATE public.material SET status = 'PENDENTE' WHERE id_material = p_id_material;

  INSERT INTO public.moderacao (id_material, id_moderador, status_anterior, status_novo, motivo, data_moderacao)
  VALUES (p_id_material, v_usuario, 'REJEITADO', 'PENDENTE',
          coalesce(nullif(trim(p_motivo), ''), 'Reenviado pelo autor'), now());
END;
$$;

-- -----------------------------------------------------------------------------
-- PERMISSÕES DAS FUNÇÕES
-- Por padrão o Postgres deixa QUALQUER um executar funções (PUBLIC).
-- Tiramos de todos e liberamos só para usuários logados (authenticated).
-- -----------------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.enviar_material(TEXT, TEXT, TEXT, TEXT, BIGINT[], BIGINT[]) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.moderar_material(BIGINT, public.status_material, TEXT) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.reenviar_material(BIGINT, TEXT) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.enviar_material(TEXT, TEXT, TEXT, TEXT, BIGINT[], BIGINT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.moderar_material(BIGINT, public.status_material, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reenviar_material(BIGINT, TEXT) TO authenticated;

-- -----------------------------------------------------------------------------
-- PERMISSÕES DAS TABELAS DO FLUXO
-- O Supabase, por padrão, dá permissão total nas tabelas para "anon" e
-- "authenticated" (e confia no RLS para filtrar). Aqui fechamos a escrita
-- direta: inserir/alterar status só pelas funções acima.
-- -----------------------------------------------------------------------------
REVOKE INSERT, UPDATE, DELETE ON
  public.material, public.material_turma, public.material_categoria,
  public.arquivo,  public.moderacao
FROM anon, authenticated;

-- Exceção: o autor pode corrigir SÓ título e descrição (permissão por coluna).
-- Quem pode e quando (só se PENDENTE) é decidido pelo RLS na migration 0004.
GRANT UPDATE (titulo, descricao) ON public.material TO authenticated;
