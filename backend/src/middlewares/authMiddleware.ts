import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const CHAVE_SECRETA_JWT = process.env.JWT_SECRET || 'uninassau_ads_repositorio_chave_secreta_2026';
const PREFIXO_BEARER = 'Bearer ';

export interface DadosUsuarioToken {
  id_usuario: number;
  matricula: string;
  nome: string;
}

export interface RequisicaoAutenticada extends Request {
  usuario?: DadosUsuarioToken;
}

function extrairTokenDoCabecalho(cabecalhoAutorizacao?: string): string | null {
  if (!cabecalhoAutorizacao || !cabecalhoAutorizacao.startsWith(PREFIXO_BEARER)) {
    return null;
  }
  return cabecalhoAutorizacao.slice(PREFIXO_BEARER.length).trim();
}

export function verificarToken(req: RequisicaoAutenticada, res: Response, next: NextFunction) {
  const token = extrairTokenDoCabecalho(req.headers.authorization);

  if (!token) {
    return res.status(401).json({ erro: 'Acesso negado. Token de autenticação ausente.' });
  }

  try {
    req.usuario = jwt.verify(token, CHAVE_SECRETA_JWT) as DadosUsuarioToken;
    return next();
  } catch {
    return res.status(401).json({ erro: 'Sessão expirada ou token inválido.' });
  }
}