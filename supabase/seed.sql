-- =============================================================================
-- SEED — DADOS DE TESTE (FICTÍCIOS)
-- -----------------------------------------------------------------------------
-- Popula o banco com os mesmos 3 materiais que hoje estão "chumbados" no
-- Repositorio.tsx, para o front-end poder testar a integração.
-- NÃO contém dados reais. Pode ser executado mais de uma vez (não duplica).
-- Rodar DEPOIS das migrations 0001 a 0006.
--
-- Os materiais apontam para arquivos que NÃO existem no Storage, então o
-- botão "Abrir" vai falhar para eles — servem só para testar a listagem.
-- =============================================================================

-- Curso
INSERT INTO public.curso (nome, codigo, descricao)
VALUES ('Análise e Desenvolvimento de Sistemas', 'ADS', 'Curso tecnólogo de ADS')
ON CONFLICT (codigo) DO NOTHING;

-- Disciplinas com o período da grade (coluna criada na migration 0002)
INSERT INTO public.disciplina (nome, codigo, carga_horaria, periodo) VALUES
  ('Lógica de Programação', 'ADS-LOG', 80, 1),
  ('Banco de Dados',        'ADS-BD',  80, 2),
  ('Programação Web',       'ADS-WEB', 80, 3)
ON CONFLICT (codigo) DO NOTHING;

-- Bloco DO: permite usar variáveis e lógica (IF, loops) num script.
DO $$
DECLARE
  v_curso  BIGINT;
  v_autor  BIGINT;
  v_turma  BIGINT;
  v_mat    BIGINT;
  -- Cada item: título | assunto | código da disciplina | tipo | arquivo fictício
  v_item   TEXT[];
  v_dados  TEXT[][] := ARRAY[
    ARRAY['Introdução ao React',  'Componentes, propriedades e estado', 'ADS-WEB', 'PDF',   'seed/introducao-react.pdf'],
    ARRAY['Modelagem de dados',   'Modelo entidade-relacionamento',     'ADS-BD',  'PDF',   'seed/modelagem-dados.pdf'],
    ARRAY['Lógica e algoritmos',  'Estruturas de decisão',              'ADS-LOG', 'TEXTO', 'seed/logica-algoritmos.txt']
  ];
BEGIN
  SELECT id_curso INTO v_curso FROM public.curso WHERE codigo = 'ADS';

  -- Uma turma de 2026/2 para cada disciplina (se ainda não existir)
  INSERT INTO public.turma (id_curso, id_disciplina, nome_turma, ano, semestre)
  SELECT v_curso, d.id_disciplina, d.codigo || '-2026.2', 2026, 2
  FROM public.disciplina d
  WHERE d.codigo IN ('ADS-LOG', 'ADS-BD', 'ADS-WEB')
    AND NOT EXISTS (
      SELECT 1 FROM public.turma t
      WHERE t.id_disciplina = d.id_disciplina AND t.ano = 2026 AND t.semestre = 2
    );

  -- Autor fictício, sem conta de login (id_auth NULL)
  INSERT INTO public.usuario (nome_completo, email, matricula)
  VALUES ('Aluno Teste', 'aluno.teste@exemplo.com', '00000001')
  ON CONFLICT (email) DO NOTHING;

  SELECT id_usuario INTO v_autor FROM public.usuario WHERE email = 'aluno.teste@exemplo.com';

  -- FOREACH ... SLICE 1 percorre a matriz linha por linha
  FOREACH v_item SLICE 1 IN ARRAY v_dados
  LOOP
    -- Pula se esse material de teste já foi criado antes
    CONTINUE WHEN EXISTS (SELECT 1 FROM public.material WHERE titulo = v_item[1]);

    SELECT t.id_turma INTO v_turma
    FROM public.turma t
    JOIN public.disciplina d ON d.id_disciplina = t.id_disciplina
    WHERE d.codigo = v_item[3] AND t.ano = 2026 AND t.semestre = 2;

    -- O seed roda como administrador do banco, então pode inserir direto
    -- e já como APROVADO (os usuários comuns passam pela moderação).
    INSERT INTO public.material (id_usuario_autor, titulo, descricao, tipo_material, status)
    VALUES (v_autor, v_item[1], v_item[2], v_item[4]::public.tipo_material, 'APROVADO')
    RETURNING id_material INTO v_mat;

    INSERT INTO public.material_turma (id_material, id_turma) VALUES (v_mat, v_turma);

    INSERT INTO public.arquivo (id_material, nome_arquivo, caminho_arquivo, tipo_mime, tamanho_bytes)
    VALUES (
      v_mat,
      split_part(v_item[5], '/', 2),
      v_item[5],
      CASE v_item[4] WHEN 'PDF' THEN 'application/pdf' ELSE 'text/plain' END,
      1024  -- tamanho fictício (o banco exige tamanho_bytes > 0)
    );
  END LOOP;
END
$$;
