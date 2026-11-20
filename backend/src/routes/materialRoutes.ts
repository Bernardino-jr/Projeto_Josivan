import { Router, Request, Response } from 'express';
import multer from 'multer';
import { supabase } from '../config/supabase';
import { verificarToken, RequisicaoAutenticada } from '../middlewares/authMiddleware';

const router = Router();

const LIMITE_TAMANHO_ARQUIVO_BYTES = 10 * 1024 * 1024; // 10 MB
const BUCKET_STORAGE = 'materiais';
const TEMPO_EXPIRACAO_LINK_SEGUNDOS = 60 * 10; // 10 minutos
const TIPOS_MIME_PERMITIDOS = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'text/plain',
];
const STATUS_VALIDOS_MODERACAO = ['APROVADO', 'REJEITADO'];

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

// 1. GET /api/materiais — Lista materiais aprovados com links assinados temporários
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
      material_turma (
        turma (
          semestre,
          disciplina ( nome )
        )
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

  const { data: materiais, error } = await consulta;

  if (error) {
    return res.status(400).json({ erro: error.message });
  }

  // Gera URL assinada temporária (10 min) para o bucket privado 'materiais'
  const materiaisComUrlAssinada = await Promise.all(
    (materiais || []).map(async (material: any) => {
      const registroArquivo = material.arquivo?.[0];
      let urlDownload: string | null = null;

      if (registroArquivo?.caminho_arquivo) {
        const { data: linkAssinado } = await supabase!.storage
          .from(BUCKET_STORAGE)
          .createSignedUrl(registroArquivo.caminho_arquivo, TEMPO_EXPIRACAO_LINK_SEGUNDOS);

        urlDownload = linkAssinado?.signedUrl || null;
      }

      const primeiraTurma = material.material_turma?.[0]?.turma;

      return {
        ...material,
        turma: primeiraTurma || null,
        url_download: urlDownload,
      };
    })
  );

  return res.status(200).json(materiaisComUrlAssinada);
});

// 2. POST /api/materiais — Envio de novo material + Upload + Vínculo em material_turma
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

    // Passo A: Upload do arquivo físico para o bucket privado 'materiais'
    const { error: erroStorage } = await supabase.storage
      .from(BUCKET_STORAGE)
      .upload(caminhoNoBucket, arquivoEnviado.buffer, {
        contentType: arquivoEnviado.mimetype,
      });

    if (erroStorage) {
      return res.status(500).json({ erro: `Falha no upload do arquivo: ${erroStorage.message}` });
    }

    // Passo B: Salva metadados na tabela 'material' (sem id_turma)
    const { data: materialCriado, error: erroMaterial } = await supabase
      .from('material')
      .insert([
        {
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

    // Passo C: Vincula o material à turma na tabela associativa 'material_turma'
    const { error: erroTurma } = await supabase.from('material_turma').insert([
      {
        id_material: materialCriado.id_material,
        id_turma: Number(id_turma),
      },
    ]);

    if (erroTurma) {
      return res.status(400).json({ erro: `Erro ao vincular turma: ${erroTurma.message}` });
    }

    // Passo D: Salva apenas o caminho relativo do arquivo no bucket privado
    await supabase.from('arquivo').insert([
      {
        id_material: materialCriado.id_material,
        nome_arquivo: arquivoEnviado.originalname,
        caminho_arquivo: caminhoNoBucket,
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

// 3. PATCH /api/materiais/:id/status — Aprovar ou Rejeitar material com histórico real
router.patch('/:id/status', verificarToken, async (req: RequisicaoAutenticada, res: Response) => {
  const { id } = req.params;
  const { status, motivo } = req.body;

  if (!STATUS_VALIDOS_MODERACAO.includes(status)) {
    return res.status(400).json({ erro: 'Status inválido. Use APROVADO ou REJEITADO.' });
  }

  if (status === 'REJEITADO' && (!motivo || !String(motivo).trim())) {
    return res.status(400).json({ erro: 'O motivo é obrigatório ao rejeitar um material.' });
  }

  if (!supabase) {
    return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
  }

  // Lê o status atual antes de atualizar
  const { data: materialAtual, error: erroBusca } = await supabase
    .from('material')
    .select('status')
    .eq('id_material', Number(id))
    .single();

  if (erroBusca || !materialAtual) {
    return res.status(404).json({ erro: 'Material não encontrado.' });
  }

  const { data: materialAtualizado, error: erroUpdate } = await supabase
    .from('material')
    .update({ status })
    .eq('id_material', Number(id))
    .select('id_material, titulo, status')
    .single();

  if (erroUpdate) {
    return res.status(400).json({ erro: erroUpdate.message });
  }

  await supabase.from('moderacao').insert([
    {
      id_material: Number(id),
      id_moderador: req.usuario?.id_usuario,
      status_anterior: materialAtual.status,
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