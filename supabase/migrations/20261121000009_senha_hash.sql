-- =============================================================================
-- MIGRATION 0009 — COLUNA senha_hash (SOLUÇÃO TEMPORÁRIA PARA TESTE DA API)
-- -----------------------------------------------------------------------------
-- O back-end (backend/src/routes/authRoutes.ts) faz cadastro e login próprios:
-- grava a senha com bcrypt em usuario.senha_hash e confere no login.
--
-- ⚠ PONTO DE ATENÇÃO (decidir com a equipe):
-- O modelo original deste banco deixa a senha SOMENTE no Supabase Auth
-- (auth.users), ligada a public.usuario por id_auth. Com esta coluna, quem se
-- cadastra pela API NÃO ganha conta no Supabase Auth (id_auth fica NULL), e as
-- políticas RLS/Storage baseadas em auth.uid() não reconhecem esse usuário.
-- Se a equipe optar por usar o Supabase Auth no back-end, esta coluna pode ser
-- removida com:  ALTER TABLE public.usuario DROP COLUMN senha_hash;
-- =============================================================================

ALTER TABLE public.usuario ADD COLUMN IF NOT EXISTS senha_hash TEXT;

COMMENT ON COLUMN public.usuario.senha_hash IS
  'Hash bcrypt da senha usado pela API própria (temporário — ver migration 0009).';

-- Pede para a API do Supabase (PostgREST) recarregar o esquema na hora.
NOTIFY pgrst, 'reload schema';
