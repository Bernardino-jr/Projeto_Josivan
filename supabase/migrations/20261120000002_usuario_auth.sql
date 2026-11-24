-- =============================================================================
-- MIGRATION 0002 — LIGAÇÃO ENTRE USUARIO E SUPABASE AUTH
-- -----------------------------------------------------------------------------
-- O que faz:
--   1. Adiciona a coluna "periodo" em DISCIPLINA (o front exibe o período).
--   2. Cria a FK usuario.id_auth -> auth.users (pendência da Fase 18).
--   3. Cria um TRIGGER: quando alguém se cadastra no Supabase Auth, a linha
--      correspondente em public.usuario é criada/vinculada automaticamente.
--   4. Cria funções auxiliares usadas pelas regras de segurança (RLS).
--   5. Mantém "data_atualizacao" sempre correta em USUARIO e MATERIAL.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. NOVA COLUNA ("ADD COLUMN IF NOT EXISTS" não falha se já existir)
-- Período da disciplina na grade (1º, 2º, 3º...). O front mostra essa
-- informação na tabela de materiais, mas ela não existia no modelo.
-- -----------------------------------------------------------------------------
ALTER TABLE public.disciplina
  ADD COLUMN IF NOT EXISTS periodo SMALLINT
  CONSTRAINT ck_disciplina_periodo CHECK (periodo BETWEEN 1 AND 12);

-- -----------------------------------------------------------------------------
-- 2. CHAVE ESTRANGEIRA id_auth -> auth.users(id)
-- ON DELETE SET NULL: se a conta de login for apagada, o registro acadêmico
-- (e o histórico de materiais/moderação) é preservado, só perde o vínculo.
-- O bloco DO evita erro caso a FK já tenha sido criada antes.
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_usuario_auth'
  ) THEN
    ALTER TABLE public.usuario
      ADD CONSTRAINT fk_usuario_auth
      FOREIGN KEY (id_auth) REFERENCES auth.users (id) ON DELETE SET NULL;
  END IF;
END
$$;

-- -----------------------------------------------------------------------------
-- 3. TRIGGER: cadastro no Auth  ->  linha em public.usuario
--
-- SECURITY DEFINER: a função roda com as permissões do DONO (postgres),
--   necessário porque quem está se cadastrando ainda não tem permissão
--   nenhuma na tabela usuario.
-- SET search_path = '': boa prática de segurança para funções SECURITY
--   DEFINER — obriga a escrever "public.tabela", impedindo que alguém
--   "sequestre" a função criando tabelas com o mesmo nome em outro schema.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.ao_criar_usuario_auth()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- "NEW" é a linha que acabou de ser inserida em auth.users.
  -- raw_user_meta_data é um JSON com dados extras enviados no cadastro
  -- (o front manda "nome_completo" e "matricula"; o Google manda "full_name").
  INSERT INTO public.usuario (id_auth, nome_completo, email, matricula)
  VALUES (
    NEW.id,
    COALESCE(                                   -- usa o primeiro valor não nulo:
      NULLIF(trim(NEW.raw_user_meta_data ->> 'nome_completo'), ''), -- formulário
      NULLIF(trim(NEW.raw_user_meta_data ->> 'full_name'), ''),     -- conta Google
      split_part(NEW.email, '@', 1)                                 -- antes do @
    ),
    lower(NEW.email),
    NULLIF(trim(NEW.raw_user_meta_data ->> 'matricula'), '')
  )
  -- Se a secretaria já tinha cadastrado essa pessoa (mesmo e-mail) sem login,
  -- apenas VINCULA a conta de login ao registro existente.
  ON CONFLICT (email) DO UPDATE
    SET id_auth = EXCLUDED.id_auth
    WHERE public.usuario.id_auth IS NULL;

  -- Observação: se a matrícula informada já pertencer a outra pessoa, a
  -- restrição UNIQUE gera erro e o cadastro é recusado (comportamento desejado).
  RETURN NEW;
END;
$$;

-- Remove o trigger antigo (se houver) e cria de novo — permite reexecutar o arquivo.
DROP TRIGGER IF EXISTS trg_ao_criar_usuario_auth ON auth.users;
CREATE TRIGGER trg_ao_criar_usuario_auth
  AFTER INSERT ON auth.users          -- depois de cada novo cadastro
  FOR EACH ROW                        -- uma vez por linha inserida
  EXECUTE FUNCTION public.ao_criar_usuario_auth();

-- A função do trigger não deve ser chamada diretamente pela API.
REVOKE EXECUTE ON FUNCTION public.ao_criar_usuario_auth() FROM PUBLIC, anon, authenticated;

-- -----------------------------------------------------------------------------
-- 4. FUNÇÕES AUXILIARES PARA AS REGRAS DE SEGURANÇA
-- auth.uid() = id (UUID) de quem está logado e fazendo a requisição.
-- STABLE = o resultado não muda dentro da mesma consulta (o Postgres otimiza).
-- -----------------------------------------------------------------------------

-- Retorna o id_usuario (tabela public.usuario) da pessoa logada, ou NULL.
CREATE OR REPLACE FUNCTION public.id_usuario_atual()
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT u.id_usuario
  FROM public.usuario u
  WHERE u.id_auth = auth.uid()
    AND u.ativo;
$$;

-- Retorna TRUE se a pessoa logada possui o papel informado (ex.: 'MODERADOR').
CREATE OR REPLACE FUNCTION public.tem_papel(p_papel TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.usuario_papel up
    JOIN public.papel p ON p.id_papel = up.id_papel
    WHERE up.id_usuario = public.id_usuario_atual()
      AND p.nome = upper(p_papel)
  );
$$;

-- Atalho: moderadores e administradores podem moderar materiais.
CREATE OR REPLACE FUNCTION public.pode_moderar()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT public.tem_papel('MODERADOR') OR public.tem_papel('ADMINISTRADOR');
$$;

-- Essas funções só fazem sentido para quem está logado.
REVOKE EXECUTE ON FUNCTION public.id_usuario_atual() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.tem_papel(TEXT)    FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.pode_moderar()     FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION public.id_usuario_atual() TO authenticated;
GRANT  EXECUTE ON FUNCTION public.tem_papel(TEXT)    TO authenticated;
GRANT  EXECUTE ON FUNCTION public.pode_moderar()     TO authenticated;

-- -----------------------------------------------------------------------------
-- 5. DATA_ATUALIZACAO AUTOMÁTICA
-- As colunas existem em USUARIO e MATERIAL, mas nada as atualizava.
-- Este trigger roda ANTES de cada UPDATE e grava a hora atual.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.definir_data_atualizacao()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.data_atualizacao := now();  -- altera a linha antes de ela ser gravada
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usuario_data_atualizacao ON public.usuario;
CREATE TRIGGER trg_usuario_data_atualizacao
  BEFORE UPDATE ON public.usuario
  FOR EACH ROW EXECUTE FUNCTION public.definir_data_atualizacao();

DROP TRIGGER IF EXISTS trg_material_data_atualizacao ON public.material;
CREATE TRIGGER trg_material_data_atualizacao
  BEFORE UPDATE ON public.material
  FOR EACH ROW EXECUTE FUNCTION public.definir_data_atualizacao();

REVOKE EXECUTE ON FUNCTION public.definir_data_atualizacao() FROM PUBLIC, anon, authenticated;
