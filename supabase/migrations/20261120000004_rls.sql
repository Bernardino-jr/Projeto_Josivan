-- =============================================================================
-- MIGRATION 0004 — RLS (ROW LEVEL SECURITY / SEGURANÇA POR LINHA)
-- -----------------------------------------------------------------------------
-- O front-end acessa o banco DIRETAMENTE pela chave pública (anon key), que
-- fica visível no navegador. Quem protege os dados é o RLS: com ele ligado,
-- cada consulta só "enxerga" as linhas que alguma POLICY (regra) permitir.
-- Sem policy = sem acesso nenhum.
--
-- Papéis do Supabase usados aqui:
--   anon          -> visitante NÃO logado (não recebe nenhuma policy: o
--                    repositório exige login)
--   authenticated -> usuário logado
--
-- Dica de desempenho: "(SELECT funcao())" faz o Postgres calcular a função
-- UMA vez por consulta, e não uma vez por linha.
--
-- Cada policy tem "DROP POLICY IF EXISTS" antes, para o arquivo poder ser
-- executado de novo sem erro.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. LIGAR O RLS EM TODAS AS 13 TABELAS
-- -----------------------------------------------------------------------------
ALTER TABLE public.usuario            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.papel              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuario_papel      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curso              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disciplina         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turma              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matricula          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material_turma     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arquivo            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categoria          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material_categoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderacao          ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 2. USUARIO
-- -----------------------------------------------------------------------------
-- Cada um vê o próprio cadastro; moderadores/admins veem todos.
DROP POLICY IF EXISTS usuario_select ON public.usuario;
CREATE POLICY usuario_select ON public.usuario
  FOR SELECT TO authenticated
  USING (id_auth = (SELECT auth.uid()) OR (SELECT public.pode_moderar()));

-- Cada um pode editar o próprio cadastro...
DROP POLICY IF EXISTS usuario_update_proprio ON public.usuario;
CREATE POLICY usuario_update_proprio ON public.usuario
  FOR UPDATE TO authenticated
  USING (id_auth = (SELECT auth.uid()))
  WITH CHECK (id_auth = (SELECT auth.uid()));

-- ...mas SOMENTE a coluna "nome_completo". E-mail, matrícula e "ativo" não podem ser
-- alterados pelo próprio usuário. Inserção é feita só pelo trigger (0002).
REVOKE INSERT, UPDATE, DELETE ON public.usuario FROM anon, authenticated;
GRANT UPDATE (nome_completo) ON public.usuario TO authenticated;

-- -----------------------------------------------------------------------------
-- 3. TABELAS DE CADASTRO ACADÊMICO (papel, curso, disciplina, turma, categoria)
-- Qualquer logado pode LER (precisa para montar filtros e o formulário de envio).
-- Só ADMINISTRADOR pode criar/alterar/excluir.
-- O bloco DO repete a mesma regra para as 5 tabelas, evitando copiar e colar.
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_tabela TEXT;
BEGIN
  FOREACH v_tabela IN ARRAY ARRAY['papel', 'curso', 'disciplina', 'turma', 'categoria']
  LOOP
    -- format() monta o comando SQL; %I insere o nome da tabela com segurança.
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_select', v_tabela);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (true)',
      v_tabela || '_select', v_tabela);

    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_admin', v_tabela);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO authenticated '
      'USING ((SELECT public.tem_papel(''ADMINISTRADOR''))) '
      'WITH CHECK ((SELECT public.tem_papel(''ADMINISTRADOR'')))',
      v_tabela || '_admin', v_tabela);
  END LOOP;
END
$$;

-- -----------------------------------------------------------------------------
-- 4. USUARIO_PAPEL e MATRICULA (vínculos da pessoa)
-- A pessoa vê os próprios vínculos; admin vê e gerencia todos.
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS usuario_papel_select ON public.usuario_papel;
CREATE POLICY usuario_papel_select ON public.usuario_papel
  FOR SELECT TO authenticated
  USING (id_usuario = (SELECT public.id_usuario_atual())
         OR (SELECT public.tem_papel('ADMINISTRADOR')));

DROP POLICY IF EXISTS usuario_papel_admin ON public.usuario_papel;
CREATE POLICY usuario_papel_admin ON public.usuario_papel
  FOR ALL TO authenticated
  USING ((SELECT public.tem_papel('ADMINISTRADOR')))
  WITH CHECK ((SELECT public.tem_papel('ADMINISTRADOR')));

DROP POLICY IF EXISTS matricula_select ON public.matricula;
CREATE POLICY matricula_select ON public.matricula
  FOR SELECT TO authenticated
  USING (id_usuario = (SELECT public.id_usuario_atual())
         OR (SELECT public.pode_moderar()));

DROP POLICY IF EXISTS matricula_admin ON public.matricula;
CREATE POLICY matricula_admin ON public.matricula
  FOR ALL TO authenticated
  USING ((SELECT public.tem_papel('ADMINISTRADOR')))
  WITH CHECK ((SELECT public.tem_papel('ADMINISTRADOR')));

-- -----------------------------------------------------------------------------
-- 5. MATERIAL — a regra principal do acervo
-- -----------------------------------------------------------------------------
-- Quem vê o quê:
--   * todo usuário logado vê materiais APROVADOS (visíveis para a faculdade toda);
--   * o autor vê os próprios materiais em qualquer status (acompanhar a revisão);
--   * moderadores/admins veem tudo (para poder revisar os PENDENTES).
DROP POLICY IF EXISTS material_select ON public.material;
CREATE POLICY material_select ON public.material
  FOR SELECT TO authenticated
  USING (
    status = 'APROVADO'
    OR id_usuario_autor = (SELECT public.id_usuario_atual())
    OR (SELECT public.pode_moderar())
  );

-- O autor pode corrigir título/descrição enquanto o material está PENDENTE.
-- (As colunas liberadas foram definidas na migration 0003.)
DROP POLICY IF EXISTS material_update_autor ON public.material;
CREATE POLICY material_update_autor ON public.material
  FOR UPDATE TO authenticated
  USING (id_usuario_autor = (SELECT public.id_usuario_atual()) AND status = 'PENDENTE')
  WITH CHECK (id_usuario_autor = (SELECT public.id_usuario_atual()) AND status = 'PENDENTE');

-- -----------------------------------------------------------------------------
-- 6. TABELAS "FILHAS" DO MATERIAL (material_turma, material_categoria, arquivo)
-- Regra: você vê a linha filha se puder ver o material "pai".
-- O EXISTS consulta a tabela material, que JÁ está protegida pelo RLS acima,
-- então a regra é herdada automaticamente.
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS material_turma_select ON public.material_turma;
CREATE POLICY material_turma_select ON public.material_turma
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.material m WHERE m.id_material = material_turma.id_material));

DROP POLICY IF EXISTS material_categoria_select ON public.material_categoria;
CREATE POLICY material_categoria_select ON public.material_categoria
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.material m WHERE m.id_material = material_categoria.id_material));

DROP POLICY IF EXISTS arquivo_select ON public.arquivo;
CREATE POLICY arquivo_select ON public.arquivo
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.material m WHERE m.id_material = arquivo.id_material));

-- -----------------------------------------------------------------------------
-- 7. MODERACAO (histórico)
-- Moderadores/admins veem todo o histórico; o autor vê o histórico dos
-- próprios materiais (ex.: para ler o motivo de uma rejeição).
-- Ninguém escreve direto: só as funções da migration 0003.
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS moderacao_select ON public.moderacao;
CREATE POLICY moderacao_select ON public.moderacao
  FOR SELECT TO authenticated
  USING (
    (SELECT public.pode_moderar())
    OR EXISTS (
      SELECT 1 FROM public.material m
      WHERE m.id_material = moderacao.id_material
        AND m.id_usuario_autor = (SELECT public.id_usuario_atual())
    )
  );
