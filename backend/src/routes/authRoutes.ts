import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { supabase } from '../config/supabase';
import { DadosUsuarioToken } from '../middlewares/authMiddleware';

const router = Router();

const CHAVE_SECRETA_JWT = process.env.JWT_SECRET || 'uninassau_ads_repositorio_chave_secreta_2026';
const TEMPO_EXPIRACAO_TOKEN = '8h';
const CUSTO_HASH_BCRYPT = 10;
const CODIGO_ERRO_DUPLICIDADE_POSTGRES = '23505';

function gerarTokenAcesso(usuario: DadosUsuarioToken): string {
  return jwt.sign(usuario, CHAVE_SECRETA_JWT, { expiresIn: TEMPO_EXPIRACAO_TOKEN });
}

// POST /api/auth/register — Cadastro de novo estudante
router.post('/register', async (req: Request, res: Response) => {
  const { matricula, nome, email, senha } = req.body;

  if (!matricula || !nome || !senha) {
    return res.status(400).json({ erro: 'Preencha matrícula, nome e senha.' });
  }

  if (!supabase) {
    return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
  }

  const senhaHash = await bcrypt.hash(senha, CUSTO_HASH_BCRYPT);

  const { data: usuarioCriado, error } = await supabase
    .from('usuario')
    .insert([{ matricula, nome, email: email || null, senha_hash: senhaHash, ativo: true }])
    .select('id_usuario, matricula, nome')
    .single();

  if (error) {
    const mensagemErro =
      error.code === CODIGO_ERRO_DUPLICIDADE_POSTGRES
        ? 'Matrícula ou e-mail já cadastrado no sistema.'
        : error.message;

    const statusHttp = error.code === CODIGO_ERRO_DUPLICIDADE_POSTGRES ? 409 : 400;
    return res.status(statusHttp).json({ erro: mensagemErro });
  }

  return res.status(201).json({ mensagem: 'Cadastro realizado com sucesso!', usuario: usuarioCriado });
});

// POST /api/auth/login — Autenticação por matrícula e senha
router.post('/login', async (req: Request, res: Response) => {
  const { matricula, senha } = req.body;

  if (!matricula || !senha) {
    return res.status(400).json({ erro: 'Informe matrícula e senha.' });
  }

  if (!supabase) {
    return res.status(503).json({ erro: 'Banco de dados ainda não configurado no .env.' });
  }

  const { data: usuario, error } = await supabase
    .from('usuario')
    .select('id_usuario, matricula, nome, senha_hash, ativo')
    .eq('matricula', matricula)
    .single();

  if (error || !usuario || !usuario.ativo) {
    return res.status(401).json({ erro: 'Matrícula ou senha inválidos.' });
  }

  const senhaValida = await bcrypt.compare(senha, usuario.senha_hash);
  if (!senhaValida) {
    return res.status(401).json({ erro: 'Matrícula ou senha inválidos.' });
  }

  const dadosToken: DadosUsuarioToken = {
    id_usuario: usuario.id_usuario,
    matricula: usuario.matricula,
    nome: usuario.nome,
  };

  return res.status(200).json({
    token: gerarTokenAcesso(dadosToken),
    usuario: dadosToken,
  });
});

export default router;