-- =============================================================================
-- MIGRATION 0001 — SCHEMA INICIAL (LINHA DE BASE)
-- -----------------------------------------------------------------------------
-- ATENÇÃO: este schema JÁ FOI EXECUTADO no Supabase na Fase 18
-- (projeto "Projeto Repositório Alunos", vmuoeyiedmprkshzoqvx).
--
-- Este arquivo existe para que a estrutura do banco fique VERSIONADA no Git.
-- Ele foi escrito a partir da leitura do banco REAL em 20/11/2026 (colunas,
-- tipos, chaves, CHECKs e índices conferidos um a um).
--
-- Tudo aqui usa "IF NOT EXISTS": se for executado de novo por engano, ele
-- NÃO recria nem apaga nada que já existe (é "idempotente").
--
-- Observação: o Supabase deste projeto tem um "event trigger" (ensure_rls)
-- que LIGA o RLS automaticamente em toda tabela nova. Por isso as 13 tabelas
-- já estão com RLS ligado — mas sem nenhuma policy (ou seja, a API não
-- consegue ler nada ainda). As policies são criadas na migration 0004.
-- =============================================================================

-- Extensão de criptografia (funções como gen_random_uuid()).
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- TIPOS ENUMERADOS (ENUM): lista fechada de valores permitidos numa coluna.
-- "CREATE TYPE" não aceita IF NOT EXISTS, por isso usamos um bloco DO que
-- verifica no catálogo (pg_type) se o tipo já existe antes de criar.
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  -- Como a pessoa participa de uma turma (vem do cadastro acadêmico, o usuário não escolhe).
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_participacao') THEN
    CREATE TYPE public.tipo_participacao AS ENUM ('ALUNO', 'PROFESSOR');
  END IF;

  -- Formato do material. PDF; IMAGEM = JPG/JPEG/PNG; TEXTO = TXT.
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_material') THEN
    CREATE TYPE public.tipo_material AS ENUM ('PDF', 'IMAGEM', 'TEXTO');
  END IF;

  -- Ciclo de vida do material no fluxo de moderação.
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_material') THEN
    CREATE TYPE public.status_material AS ENUM ('PENDENTE', 'APROVADO', 'REJEITADO', 'ARQUIVADO');
  END IF;
END
$$;

-- -----------------------------------------------------------------------------
-- USUARIO: dados acadêmicos da pessoa.
-- A senha NÃO fica aqui: quem cuida de login/senha é o Supabase Auth
-- (tabela auth.users). "id_auth" é a ponte entre as duas tabelas.
-- BIGINT GENERATED ALWAYS AS IDENTITY = número gerado automaticamente pelo banco.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.usuario (
  id_usuario        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_auth           UUID UNIQUE,                 -- id do usuário no Supabase Auth
  matricula         VARCHAR(30) UNIQUE,          -- nº de matrícula (ex.: 01926669)
  nome_completo     VARCHAR(160) NOT NULL,
  email             VARCHAR(160) NOT NULL UNIQUE,
  ativo             BOOLEAN     NOT NULL DEFAULT TRUE,
  data_criacao      TIMESTAMPTZ NOT NULL DEFAULT now(),
  data_atualizacao  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- PAPEL: funções no sistema (ALUNO, PROFESSOR, MODERADOR, ADMINISTRADOR).
CREATE TABLE IF NOT EXISTS public.papel (
  id_papel   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome       VARCHAR(40) NOT NULL UNIQUE,
  descricao  VARCHAR(255)
);

-- USUARIO_PAPEL: tabela associativa N:N — uma pessoa pode ter vários papéis
-- (ex.: aluno + moderador). A chave primária composta impede duplicidade.
-- ON DELETE CASCADE: apagou o usuário, apaga os vínculos de papel dele.
-- ON DELETE RESTRICT: não deixa apagar um papel que ainda está em uso.
CREATE TABLE IF NOT EXISTS public.usuario_papel (
  id_usuario       BIGINT NOT NULL,
  id_papel         BIGINT NOT NULL,
  data_atribuicao  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id_usuario, id_papel),
  CONSTRAINT fk_usuario_papel_usuario FOREIGN KEY (id_usuario)
    REFERENCES public.usuario (id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_usuario_papel_papel FOREIGN KEY (id_papel)
    REFERENCES public.papel (id_papel) ON DELETE RESTRICT
);

-- CURSO (ex.: Análise e Desenvolvimento de Sistemas).
CREATE TABLE IF NOT EXISTS public.curso (
  id_curso   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome       VARCHAR(150) NOT NULL,
  codigo     VARCHAR(30)  NOT NULL UNIQUE,
  descricao  TEXT,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE
);

-- DISCIPLINA (ex.: Banco de Dados).
CREATE TABLE IF NOT EXISTS public.disciplina (
  id_disciplina  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome           VARCHAR(150) NOT NULL,
  codigo         VARCHAR(30)  NOT NULL UNIQUE,
  carga_horaria  INT CHECK (carga_horaria IS NULL OR carga_horaria > 0),
  ativo          BOOLEAN NOT NULL DEFAULT TRUE
);

-- TURMA: uma oferta de uma disciplina de um curso em um ano/semestre.
CREATE TABLE IF NOT EXISTS public.turma (
  id_turma       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_curso       BIGINT NOT NULL,
  id_disciplina  BIGINT NOT NULL,
  nome_turma     VARCHAR(50) NOT NULL,
  ano            INT      NOT NULL CHECK (ano >= 2000),
  semestre       SMALLINT NOT NULL CHECK (semestre IN (1, 2)),
  ativo          BOOLEAN  NOT NULL DEFAULT TRUE,
  -- Não pode existir duas turmas iguais no mesmo curso/disciplina/ano/semestre.
  CONSTRAINT uq_turma_contexto UNIQUE (id_curso, id_disciplina, nome_turma, ano, semestre),
  CONSTRAINT fk_turma_curso FOREIGN KEY (id_curso)
    REFERENCES public.curso (id_curso) ON DELETE RESTRICT,
  CONSTRAINT fk_turma_disciplina FOREIGN KEY (id_disciplina)
    REFERENCES public.disciplina (id_disciplina) ON DELETE RESTRICT
);

-- MATRICULA: vínculo pessoa x turma, dizendo se participa como ALUNO ou PROFESSOR.
CREATE TABLE IF NOT EXISTS public.matricula (
  id_matricula       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_usuario         BIGINT NOT NULL,
  id_turma           BIGINT NOT NULL,
  tipo_participacao  public.tipo_participacao NOT NULL,
  data_inicio        DATE    NOT NULL DEFAULT CURRENT_DATE,
  data_fim           DATE,                       -- NULL = vínculo ainda ativo
  ativo              BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT ck_matricula_periodo CHECK (data_fim IS NULL OR data_fim >= data_inicio),
  CONSTRAINT uq_matricula_usuario_turma_tipo UNIQUE (id_usuario, id_turma, tipo_participacao),
  CONSTRAINT fk_matricula_usuario FOREIGN KEY (id_usuario)
    REFERENCES public.usuario (id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_matricula_turma FOREIGN KEY (id_turma)
    REFERENCES public.turma (id_turma) ON DELETE RESTRICT
);

-- MATERIAL: o conteúdo enviado. Todo material nasce PENDENTE.
-- RESTRICT no autor: não se apaga um usuário que tem materiais (preserva o acervo).
CREATE TABLE IF NOT EXISTS public.material (
  id_material       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_usuario_autor  BIGINT NOT NULL,
  titulo            VARCHAR(180) NOT NULL,
  descricao         TEXT,
  tipo_material     public.tipo_material   NOT NULL,
  status            public.status_material NOT NULL DEFAULT 'PENDENTE',
  data_envio        TIMESTAMPTZ NOT NULL DEFAULT now(),
  data_atualizacao  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_material_autor FOREIGN KEY (id_usuario_autor)
    REFERENCES public.usuario (id_usuario) ON DELETE RESTRICT
);

-- MATERIAL_TURMA: N:N — um material pode servir a várias turmas.
CREATE TABLE IF NOT EXISTS public.material_turma (
  id_material      BIGINT NOT NULL,
  id_turma         BIGINT NOT NULL,
  data_associacao  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id_material, id_turma),
  CONSTRAINT fk_material_turma_material FOREIGN KEY (id_material)
    REFERENCES public.material (id_material) ON DELETE CASCADE,
  CONSTRAINT fk_material_turma_turma FOREIGN KEY (id_turma)
    REFERENCES public.turma (id_turma) ON DELETE RESTRICT
);

-- ARQUIVO: METADADOS do arquivo. O arquivo físico fica no Supabase Storage;
-- aqui guardamos só o caminho dele lá dentro (caminho_arquivo).
CREATE TABLE IF NOT EXISTS public.arquivo (
  id_arquivo       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_material      BIGINT NOT NULL,
  nome_arquivo     VARCHAR(255) NOT NULL,
  caminho_arquivo  VARCHAR(500) NOT NULL UNIQUE,
  tipo_mime        VARCHAR(100) NOT NULL,
  tamanho_bytes    BIGINT       NOT NULL CHECK (tamanho_bytes > 0),
  data_envio       TIMESTAMPTZ  NOT NULL DEFAULT now(),
  -- Só os formatos decididos na Fase 17: PDF, JPG/JPEG, PNG e TXT.
  CONSTRAINT ck_arquivo_tipo_mime CHECK (
    tipo_mime IN ('application/pdf', 'image/jpeg', 'image/png', 'text/plain')
  ),
  CONSTRAINT fk_arquivo_material FOREIGN KEY (id_material)
    REFERENCES public.material (id_material) ON DELETE CASCADE
);

-- CATEGORIA (SLIDES, EXERCICIO, PROVA, RESUMO, AULA).
CREATE TABLE IF NOT EXISTS public.categoria (
  id_categoria  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome          VARCHAR(80) NOT NULL UNIQUE,
  descricao     VARCHAR(255),
  ativo         BOOLEAN NOT NULL DEFAULT TRUE
);

-- MATERIAL_CATEGORIA: N:N — um material pode ter várias categorias.
CREATE TABLE IF NOT EXISTS public.material_categoria (
  id_material   BIGINT NOT NULL,
  id_categoria  BIGINT NOT NULL,
  PRIMARY KEY (id_material, id_categoria),
  CONSTRAINT fk_material_categoria_material FOREIGN KEY (id_material)
    REFERENCES public.material (id_material) ON DELETE CASCADE,
  CONSTRAINT fk_material_categoria_categoria FOREIGN KEY (id_categoria)
    REFERENCES public.categoria (id_categoria) ON DELETE RESTRICT
);

-- MODERACAO: histórico de TODA mudança de status (quem, quando, de/para, motivo).
CREATE TABLE IF NOT EXISTS public.moderacao (
  id_moderacao     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_material      BIGINT NOT NULL,
  id_moderador     BIGINT NOT NULL,
  status_anterior  public.status_material NOT NULL,
  status_novo      public.status_material NOT NULL,
  motivo           VARCHAR(500),
  data_moderacao   TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Não faz sentido registrar "mudança" para o mesmo status.
  CONSTRAINT ck_moderacao_status_diferente CHECK (status_anterior <> status_novo),
  -- Rejeição sempre precisa de motivo preenchido.
  CONSTRAINT ck_moderacao_motivo_rejeicao CHECK (
    status_novo <> 'REJEITADO' OR NULLIF(btrim(motivo), '') IS NOT NULL
  ),
  CONSTRAINT fk_moderacao_material FOREIGN KEY (id_material)
    REFERENCES public.material (id_material) ON DELETE CASCADE,
  CONSTRAINT fk_moderacao_moderador FOREIGN KEY (id_moderador)
    REFERENCES public.usuario (id_usuario) ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- ÍNDICES: aceleram buscas pelas colunas mais consultadas
-- (principalmente chaves estrangeiras e o status do material).
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_matricula_usuario       ON public.matricula (id_usuario);
CREATE INDEX IF NOT EXISTS idx_matricula_turma         ON public.matricula (id_turma);
CREATE INDEX IF NOT EXISTS idx_material_autor          ON public.material (id_usuario_autor);
CREATE INDEX IF NOT EXISTS idx_material_status         ON public.material (status);
CREATE INDEX IF NOT EXISTS idx_material_turma_turma    ON public.material_turma (id_turma);
CREATE INDEX IF NOT EXISTS idx_arquivo_material        ON public.arquivo (id_material);
CREATE INDEX IF NOT EXISTS idx_moderacao_material_data ON public.moderacao (id_material, data_moderacao DESC);

-- -----------------------------------------------------------------------------
-- DADOS INICIAIS. "ON CONFLICT (nome) DO NOTHING" = se já existir, ignora.
-- -----------------------------------------------------------------------------
INSERT INTO public.papel (nome, descricao) VALUES
  ('ALUNO',         'Estudante da instituição'),
  ('PROFESSOR',     'Docente da instituição'),
  ('MODERADOR',     'Aprova, rejeita e arquiva materiais'),
  ('ADMINISTRADOR', 'Gerencia cursos, disciplinas, turmas e papéis')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO public.categoria (nome, descricao) VALUES
  ('SLIDES',    'Apresentações de aula'),
  ('EXERCICIO', 'Listas e exercícios'),
  ('PROVA',     'Provas anteriores'),
  ('RESUMO',    'Resumos feitos pelos alunos'),
  ('AULA',      'Anotações e materiais de aula')
ON CONFLICT (nome) DO NOTHING;
