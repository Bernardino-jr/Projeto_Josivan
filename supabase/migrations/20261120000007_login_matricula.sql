-- =============================================================================
-- MIGRATION 0007 — LOGIN POR MATRÍCULA (OPCIONAL — decidir com a equipe)
-- -----------------------------------------------------------------------------
-- Problema: o Supabase Auth faz login por E-MAIL + senha, mas a tela de
-- Login pede MATRÍCULA + senha.
-- Solução: esta função recebe a matrícula e devolve o e-mail cadastrado;
-- o front então chama supabase.auth.signInWithPassword({ email, password }).
--
-- ⚠ PONTO DE ATENÇÃO (privacidade):
-- Como o visitante ainda não está logado, a função precisa ser liberada para
-- "anon". Isso permite que alguém descubra o e-mail de uma pessoa testando
-- matrículas. Alternativas mais seguras, para decidir com o back-end:
--   (a) fazer o login por matrícula numa Edge Function / API do back-end,
--       que nunca devolve o e-mail ao navegador; ou
--   (b) login só por e-mail institucional ou conta Google.
-- Se optarem por (a) ou (b), NÃO executem esta migration.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.email_por_matricula(p_matricula TEXT)
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER          -- precisa ler public.usuario sem estar logado
SET search_path = ''
AS $$
  SELECT u.email
  FROM public.usuario u
  WHERE u.matricula = trim(p_matricula)
    AND u.ativo                -- usuário desativado não consegue entrar
    AND u.id_auth IS NOT NULL  -- só quem já tem conta de login
  LIMIT 1;
$$;

REVOKE EXECUTE ON FUNCTION public.email_por_matricula(TEXT) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.email_por_matricula(TEXT) TO anon, authenticated;
