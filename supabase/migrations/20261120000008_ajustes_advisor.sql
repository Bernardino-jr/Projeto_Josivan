-- =============================================================================
-- MIGRATION 0008 — AJUSTES APONTADOS PELO SUPABASE ADVISOR
-- -----------------------------------------------------------------------------
-- Depois de aplicar as migrations 0002 a 0006, rodamos o verificador do
-- Supabase (Security Advisor e Performance Advisor). Esta migration corrige
-- os pontos que valem a pena corrigir:
--
--   1. SEGURANÇA: a função "rls_auto_enable" (criada pelo próprio Supabase,
--      não por nós) podia ser chamada pela API por qualquer visitante.
--   2. DESEMPENHO: 4 chaves estrangeiras sem índice.
--   3. DESEMPENHO: as policies "_admin" (FOR ALL) também valiam para SELECT,
--      então o Postgres avaliava DUAS regras em toda leitura. Separamos a
--      regra do admin em INSERT / UPDATE / DELETE.
--
-- Observação: o Advisor também lista as nossas funções SECURITY DEFINER
-- (enviar_material, moderar_material, tem_papel...) como "podem ser chamadas
-- por usuários logados". Isso é INTENCIONAL — são a porta de entrada do
-- front-end e cada uma faz suas próprias verificações de permissão.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Função interna do Supabase não deve ficar exposta na API (/rest/v1/rpc)
-- -----------------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;

-- -----------------------------------------------------------------------------
-- 2. Índices nas chaves estrangeiras que estavam sem índice.
-- Sem índice, apagar/alterar a linha "pai" obriga o banco a varrer a tabela
-- "filha" inteira para conferir a FK.
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_material_categoria_categoria ON public.material_categoria (id_categoria);
CREATE INDEX IF NOT EXISTS idx_moderacao_moderador          ON public.moderacao (id_moderador);
CREATE INDEX IF NOT EXISTS idx_turma_disciplina             ON public.turma (id_disciplina);
CREATE INDEX IF NOT EXISTS idx_usuario_papel_papel          ON public.usuario_papel (id_papel);

-- -----------------------------------------------------------------------------
-- 3. Policies de administrador: de "FOR ALL" para INSERT / UPDATE / DELETE.
-- A LEITURA continua coberta pelas policies "_select" (criadas na 0004).
-- O loop aplica a mesma troca nas 7 tabelas que tinham policy "_admin".
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_tabela TEXT;
  v_regra  TEXT := '(SELECT public.tem_papel(''ADMINISTRADOR''))';
BEGIN
  FOREACH v_tabela IN ARRAY ARRAY[
    'papel', 'curso', 'disciplina', 'turma', 'categoria', 'usuario_papel', 'matricula'
  ]
  LOOP
    -- Remove a policy antiga que cobria tudo (inclusive SELECT)
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_admin', v_tabela);

    -- INSERT: só "WITH CHECK" (confere a linha nova)
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_admin_insert', v_tabela);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR INSERT TO authenticated WITH CHECK (%s)',
      v_tabela || '_admin_insert', v_tabela, v_regra);

    -- UPDATE: "USING" (qual linha pode alterar) + "WITH CHECK" (como ela fica)
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_admin_update', v_tabela);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated USING (%s) WITH CHECK (%s)',
      v_tabela || '_admin_update', v_tabela, v_regra, v_regra);

    -- DELETE: só "USING" (qual linha pode apagar)
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_tabela || '_admin_delete', v_tabela);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR DELETE TO authenticated USING (%s)',
      v_tabela || '_admin_delete', v_tabela, v_regra);
  END LOOP;
END
$$;
