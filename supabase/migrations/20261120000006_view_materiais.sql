-- =============================================================================
-- MIGRATION 0006 — VIEW vw_materiais (consulta pronta para a tela do acervo)
-- -----------------------------------------------------------------------------
-- Uma VIEW é uma "consulta salva" que se comporta como uma tabela.
-- A tela Repositorio precisa de: título, assunto (descrição), disciplina,
-- período, formato e o arquivo. Esses dados estão espalhados em 7 tabelas;
-- a view junta tudo numa linha por material, e o front faz UMA consulta:
--
--   supabase.from('vw_materiais').select('*').eq('status', 'APROVADO')
--
-- security_invoker = true: a view roda com as permissões de QUEM CONSULTA,
-- então todas as regras de RLS (migration 0004) continuam valendo.
-- Sem isso, a view rodaria como dono (postgres) e mostraria tudo para todos.
-- =============================================================================

CREATE OR REPLACE VIEW public.vw_materiais
WITH (security_invoker = true)
AS
SELECT
  m.id_material,
  m.titulo,
  m.descricao,                    -- exibido como "Assunto" na tela
  m.tipo_material,                -- PDF / IMAGEM / TEXTO (abas de formato)
  m.status,
  m.data_envio,
  m.id_usuario_autor,
  -- Dados acadêmicos vêm como ARRAYS porque um material pode estar em várias
  -- turmas (N:N). Ex.: disciplinas = {"Banco de Dados"}, periodos = {2}.
  acad.ids_curso,
  acad.cursos,
  acad.ids_disciplina,
  acad.disciplinas,
  acad.periodos,
  acad.ids_turma,
  cat.categorias,                 -- ex.: {"RESUMO","EXERCICIO"}
  arq.arquivos                    -- JSON com os arquivos do material
FROM public.material m

-- LEFT JOIN LATERAL: para CADA material, roda a subconsulta usando o
-- m.id_material dele. "LEFT ... ON true" mantém o material mesmo se a
-- subconsulta não achar nada (os campos ficam NULL).
LEFT JOIN LATERAL (
  SELECT
    array_agg(DISTINCT cu.id_curso)                       AS ids_curso,
    array_agg(DISTINCT cu.nome ORDER BY cu.nome)          AS cursos,
    array_agg(DISTINCT d.id_disciplina)                   AS ids_disciplina,
    array_agg(DISTINCT d.nome ORDER BY d.nome)            AS disciplinas,
    array_agg(DISTINCT d.periodo ORDER BY d.periodo)
      FILTER (WHERE d.periodo IS NOT NULL)                AS periodos,
    array_agg(DISTINCT t.id_turma)                        AS ids_turma
  FROM public.material_turma mt
  JOIN public.turma      t  ON t.id_turma       = mt.id_turma
  JOIN public.disciplina d  ON d.id_disciplina  = t.id_disciplina
  JOIN public.curso      cu ON cu.id_curso      = t.id_curso
  WHERE mt.id_material = m.id_material
) acad ON true

LEFT JOIN LATERAL (
  SELECT array_agg(c.nome ORDER BY c.nome) AS categorias
  FROM public.material_categoria mc
  JOIN public.categoria c ON c.id_categoria = mc.id_categoria
  WHERE mc.id_material = m.id_material
) cat ON true

LEFT JOIN LATERAL (
  -- jsonb_agg monta uma lista JSON: [{ "id_arquivo": 1, "nome_arquivo": ... }, ...]
  -- O front usa "caminho_arquivo" para gerar o link de download.
  SELECT jsonb_agg(
           jsonb_build_object(
             'id_arquivo',      a.id_arquivo,
             'nome_arquivo',    a.nome_arquivo,
             'caminho_arquivo', a.caminho_arquivo,
             'tipo_mime',       a.tipo_mime,
             'tamanho_bytes',   a.tamanho_bytes
           ) ORDER BY a.id_arquivo
         ) AS arquivos
  FROM public.arquivo a
  WHERE a.id_material = m.id_material
) arq ON true;

-- Só usuários logados podem consultar a view (visitante não vê o acervo).
REVOKE ALL ON public.vw_materiais FROM anon;
GRANT SELECT ON public.vw_materiais TO authenticated;
