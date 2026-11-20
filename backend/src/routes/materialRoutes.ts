import { Router, Request, Response } from 'express';
import multer from 'multer';
import { supabase } from '../config/supabase';
import { verificarToken, RequisicaoAutenticada } from '../middlewares/authMiddleware';

const router = Router();

// Constantes semânticas (Clean Code: sem Magic Numbers/Strings)
const LIMITE_TAMANHO_ARQUIVO_BYTES = 10 * 1024 * 1024; // 10 MB
const BUCKET_STORAGE = 'materiais-ads';
const TIPOS_MIME_PERMITIDOS = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'text/plain',
];
const STATUS_VALIDOS_MODERACAO = ['APROVADO', 'REJEITADO'];

// Configuração do Multer em memória com trava de tamanho e formato
const uploadArquivo = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: LIMITE_TAMANHO_ARQUIVO_BYTES },
  fileFilter: (_req, file, callback) => {
    const formatoValido = TIPOS_MIME_PERMITIDOS.includes(file.mimetype);
    if (!formatoValido) {
      return callback(new Error('Formato não permitido. Envie apenas PDF, JPG, JPEG, PNG ou TXT.'));
    }
    callback(null, true);
  },
});

function gerarNomeUnicoArquivo(nomeOriginal: string): string {
  const nomeSanitizado = nomeOriginal.replace(/\s+/g, '_');
  return `${Date.now()}-${nomeSanitizado}`;
}

// 1. GET /api/materiais — Lista materiais aprovados para o acervo
router.get('/', async (req: Request, res: Response) => {
  if (!supabase) {
    return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
  }

  const { busca, formato } = req.query;

  let consulta = supabase
    .from('material')
    .select(`
      id_material,
      titulo,
      descricao,
      tipo_material,
      status,
      data_envio,
      turma (
        semestre,
        disciplina ( nome )
      ),
      arquivo (
        nome_arquivo,
        caminho_arquivo
      )
    `)
    .eq('status', 'APROVADO')
    .order('data_envio', { ascending: false });

  if (formato && formato !== 'Todos') {
    consulta = consulta.eq('tipo_material', String(formato));
  }

  if (busca) {
    consulta = consulta.ilike('titulo', `%${String(busca)}%`);
  }

  const { data, error } = await consulta;

  if (error) {
    return res.status(400).json({ erro: error.message });
  }

  return res.status(200).json(data);
});

// 2. POST /api/materiais — Envio de novo material + Upload (Rota Protegida)
router.post(
  '/',
  verificarToken,
  uploadArquivo.single('arquivo'),
  async (req: RequisicaoAutenticada, res: Response) => {
    const { titulo, descricao, tipo_material, id_turma } = req.body;
    const arquivoEnviado = req.file;

    if (!titulo || !descricao || !id_turma || !arquivoEnviado) {
      return res.status(400).json({
        erro: 'Título, assunto/descrição, turma e arquivo são obrigatórios.',
      });
    }

    if (!supabase) {
      return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
    }

    const caminhoNoBucket = gerarNomeUnicoArquivo(arquivoEnviado.originalname);

    // Passo A: Upload do arquivo físico para o Supabase Storage
    const { error: erroStorage } = await supabase.storage
      .from(BUCKET_STORAGE)
      .upload(caminhoNoBucket, arquivoEnviado.buffer, {
        contentType: arquivoEnviado.mimetype,
      });

    if (erroStorage) {
      return res.status(500).json({ erro: `Falha no upload do arquivo: ${erroStorage.message}` });
    }

    const { data: urlPublicaData } = supabase.storage
      .from(BUCKET_STORAGE)
      .getPublicUrl(caminhoNoBucket);

    // Passo B: Salva metadados do material (nasce como PENDENTE para moderação)
    const { data: materialCriado, error: erroMaterial } = await supabase
      .from('material')
      .insert([
        {
          id_turma: Number(id_turma),
          id_usuario_autor: req.usuario?.id_usuario,
          titulo,
          descricao,
          tipo_material: tipo_material || 'PDF',
          status: 'PENDENTE',
        },
      ])
      .select('id_material, titulo, status')
      .single();

    if (erroMaterial || !materialCriado) {
      return res.status(400).json({ erro: erroMaterial?.message || 'Erro ao salvar material.' });
    }

    // Passo C: Vincula o registro do arquivo na tabela 'arquivo'
    await supabase.from('arquivo').insert([
      {
        id_material: materialCriado.id_material,
        nome_arquivo: arquivoEnviado.originalname,
        caminho_arquivo: urlPublicaData.publicUrl,
        tipo_mime: arquivoEnviado.mimetype,
        tamanho_bytes: arquivoEnviado.size,
      },
    ]);

    return res.status(201).json({
      mensagem: 'Material enviado com sucesso! Aguardando aprovação de um moderador.',
      material: materialCriado,
    });
  }
);

// 3. PATCH /api/materiais/:id/status — Aprovar ou Rejeitar material (MVP Moderação)
router.patch('/:id/status', verificarToken, async (req: RequisicaoAutenticada, res: Response) => {
  const { id } = req.params;
  const { status, motivo } = req.body;

  if (!STATUS_VALIDOS_MODERACAO.includes(status)) {
    return res.status(400).json({ erro: 'Status inválido. Use APROVADO ou REJEITADO.' });
  }

  if (!supabase) {
    return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
  }

  const { data: materialAtualizado, error } = await supabase
    .from('material')
    .update({ status })
    .eq('id_material', Number(id))
    .select('id_material, titulo, status')
    .single();

  if (error) {
    return res.status(400).json({ erro: error.message });
  }

  // Registra o histórico simples de moderação conforme decisão da equipe
  await supabase.from('moderacao').insert([
    {
      id_material: Number(id),
      id_moderador: req.usuario?.id_usuario,
      status_anterior: 'PENDENTE',
      status_novo: status,
      motivo: motivo || null,
    },
  ]);

  return res.status(200).json({
    mensagem: `Material marcado como ${status}.`,
    material: materialAtualizado,
  });
});

export default router;