-- =============================================================================
-- CONFERÊNCIA DO SCHEMA REAL (consulta de apoio, somente leitura)
-- -----------------------------------------------------------------------------
-- Mostra como o banco REALMENTE está (colunas, tipos e chaves). Útil para
-- conferir se as migrations do repositório continuam batendo com o banco,
-- por exemplo depois que alguém alterar algo direto pelo painel.
-- (A migration 0001 já foi conferida com o banco real em 20/11/2026.)
--
-- Como usar: Supabase > SQL Editor > colar > Run. É somente leitura (SELECT),
-- não altera nada no banco.
-- =============================================================================

-- 1) Todas as colunas de todas as tabelas do schema "public"
SELECT
  c.table_name      AS tabela,
  c.column_name     AS coluna,
  c.data_type       AS tipo,          -- ex.: integer, bigint, uuid, character varying
  c.is_nullable     AS aceita_nulo,   -- YES / NO
  c.column_default  AS valor_padrao   -- ex.: nextval(...), now(), 'PENDENTE'
FROM information_schema.columns c
WHERE c.table_schema = 'public'
ORDER BY c.table_name, c.ordinal_position;

-- 2) Chaves primárias, estrangeiras e UNIQUE de cada tabela
SELECT
  tc.table_name       AS tabela,
  tc.constraint_type  AS tipo_restricao,  -- PRIMARY KEY / FOREIGN KEY / UNIQUE
  tc.constraint_name  AS nome_restricao,
  kcu.column_name     AS coluna
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema    = tc.table_schema
WHERE tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_type, kcu.column_name;
