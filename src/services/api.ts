const URL_BASE_API = import.meta.env.VITE_API_URL || 'http://localhost:3333/api';
const CHAVE_TOKEN_STORAGE = '@uninassau_ads:token';
const CHAVE_USUARIO_STORAGE = '@uninassau_ads:usuario';

export interface UsuarioLogado {
  id_usuario: number;
  matricula: string;
  nome: string;
}

export function salvarSessao(token: string, usuario: UsuarioLogado): void {
  localStorage.setItem(CHAVE_TOKEN_STORAGE, token);
  localStorage.setItem(CHAVE_USUARIO_STORAGE, JSON.stringify(usuario));
}

export function obterToken(): string | null {
  return localStorage.getItem(CHAVE_TOKEN_STORAGE);
}

export function encerrarSessao(): void {
  localStorage.removeItem(CHAVE_TOKEN_STORAGE);
  localStorage.removeItem(CHAVE_USUARIO_STORAGE);
}

export { URL_BASE_API };