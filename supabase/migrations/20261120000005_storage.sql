-- =============================================================================
-- MIGRATION 0005 — SUPABASE STORAGE (onde ficam os ARQUIVOS físicos)
-- -----------------------------------------------------------------------------
-- O banco guarda só os metadados (tabela ARQUIVO). O arquivo em si (PDF,
-- imagem, TXT) vai para um "bucket" (pasta na nuvem) do Supabase Storage.
--
-- Organização das pastas dentro do bucket:
--     materiais/<uuid-do-usuario>/<nome-do-arquivo>
-- A primeira pasta é sempre o id do dono: é isso que as policies verificam.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CRIA O BUCKET "materiais"
--   public = false      -> nada é acessível por link público; para baixar,
--                          o front gera um link temporário (signed URL)
--   file_size_limit     -> 10 MB (10 * 1024 * 1024 bytes)
--   allowed_mime_types  -> só os formatos decididos na Fase 17
-- ON CONFLICT ... DO UPDATE: se o bucket já existir, atualiza as configurações.
-- -----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'materiais',
  'materiais',
  false,
  10485760,
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'text/plain']
)
ON CONFLICT (id) DO UPDATE SET
  public             = EXCLUDED.public,
  file_size_limit    = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- -----------------------------------------------------------------------------
-- 2. POLICIES NA TABELA storage.objects (cada arquivo é uma linha nela)
-- storage.foldername(name) devolve as pastas do caminho como array;
-- [1] é a primeira pasta = id do dono.
-- -----------------------------------------------------------------------------

-- UPLOAD: usuário logado só envia para a PRÓPRIA pasta.
DROP POLICY IF EXISTS materiais_upload_propria_pasta ON storage.objects;
CREATE POLICY materiais_upload_propria_pasta ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'materiais'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::TEXT)
  );

-- DOWNLOAD: pode baixar se
--   (a) o arquivo está na própria pasta, OU
--   (b) o arquivo pertence a um material que a pessoa pode ver.
--       A tabela public.arquivo tem RLS (migration 0004), então este EXISTS
--       só encontra arquivos de materiais APROVADOS / próprios / (moderador: todos).
DROP POLICY IF EXISTS materiais_download ON storage.objects;
CREATE POLICY materiais_download ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'materiais'
    AND (
      (storage.foldername(name))[1] = (SELECT auth.uid()::TEXT)
      OR EXISTS (
        SELECT 1 FROM public.arquivo a
        WHERE a.caminho_arquivo = objects.name
      )
    )
  );

-- EXCLUSÃO: só na própria pasta e só se o arquivo AINDA NÃO estiver
-- vinculado a um material. Serve para limpar uploads "órfãos" (ex.: o upload
-- deu certo, mas o enviar_material falhou). Arquivo de material já enviado
-- não pode ser apagado pelo aluno — o histórico fica preservado.
DROP POLICY IF EXISTS materiais_excluir_orfao ON storage.objects;
CREATE POLICY materiais_excluir_orfao ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'materiais'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::TEXT)
    AND NOT EXISTS (
      SELECT 1 FROM public.arquivo a
      WHERE a.caminho_arquivo = objects.name
    )
  );

-- Não criamos policy de UPDATE: arquivo enviado não pode ser substituído.
-- (Por isso o front NÃO deve usar a opção "upsert" no upload.)
