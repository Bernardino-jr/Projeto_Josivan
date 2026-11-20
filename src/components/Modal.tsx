import { useState, FormEvent, ChangeEvent } from 'react';
import { URL_BASE_API, obterToken } from '../services/api';

interface ModalProps {
  fecharModal: () => void;
  aoEnviarComSucesso?: () => void;
}

export function Modal({ fecharModal, aoEnviarComSucesso }: ModalProps) {
  const [titulo, setTitulo] = useState('');
  const [descricao, setDescricao] = useState('');
  const [tipoMaterial, setTipoMaterial] = useState('PDF');
  const [idTurma, setIdTurma] = useState('1');
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [mensagemErro, setMensagemErro] = useState('');
  const [enviando, setEnviando] = useState(false);

  function selecionarArquivo(evento: ChangeEvent<HTMLInputElement>) {
    const arquivoEscolhido = evento.target.files?.[0] || null;
    setArquivo(arquivoEscolhido);
  }

  async function enviarMaterial(evento: FormEvent) {
    evento.preventDefault();
    setMensagemErro('');

    if (!arquivo) {
      setMensagemErro('Selecione um arquivo antes de enviar.');
      return;
    }

    const token = obterToken();
    if (!token) {
      setMensagemErro('Sessão expirada. Faça login novamente.');
      return;
    }

    const corpoFormulario = new FormData();
    corpoFormulario.append('titulo', titulo);
    corpoFormulario.append('descricao', descricao);
    corpoFormulario.append('tipo_material', tipoMaterial);
    corpoFormulario.append('id_turma', idTurma);
    corpoFormulario.append('arquivo', arquivo);

    setEnviando(true);

    try {
      const resposta = await fetch(`${URL_BASE_API}/materiais`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: corpoFormulario,
      });

      const dados = await resposta.json();

      if (!resposta.ok) {
        setMensagemErro(dados.erro || 'Erro ao enviar o material.');
        return;
      }

      alert(dados.mensagem || 'Material enviado para revisão com sucesso!');
      aoEnviarComSucesso?.();
      fecharModal();
    } catch {
      setMensagemErro('Erro de conexão com o servidor Back-end.');
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg p-6 flex flex-col gap-4">
        <div className="flex items-center justify-between border-b border-gray-100 pb-3">
          <h2 className="text-xl font-bold text-[#1E3A8A]">Adicionar Novo Material</h2>
          <button
            type="button"
            onClick={fecharModal}
            className="text-gray-400 hover:text-gray-700 font-bold text-lg"
          >
            ✕
          </button>
        </div>

        <p className="text-gray-600 text-sm">
          Preencha as informações do arquivo que deseja compartilhar com a turma de ADS.
        </p>

        {mensagemErro && (
          <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
            {mensagemErro}
          </div>
        )}

        <form onSubmit={enviarMaterial} className="flex flex-col gap-3">
          <input
            type="text"
            value={titulo}
            onChange={(e) => setTitulo(e.target.value)}
            placeholder="Título do material (Ex: Resumo de Banco de Dados)"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#1E3A8A]"
            required
          />

          <input
            type="text"
            value={descricao}
            onChange={(e) => setDescricao(e.target.value)}
            placeholder="Assunto / Descrição breve"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#1E3A8A]"
            required
          />

          <div className="grid grid-cols-2 gap-3">
            <select
              value={tipoMaterial}
              onChange={(e) => setTipoMaterial(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm bg-white"
            >
              <option value="PDF">Formato: PDF</option>
              <option value="TXT">Formato: TXT</option>
              <option value="IMAGEM">Formato: Imagem (JPG/PNG)</option>
            </select>

            <select
              value={idTurma}
              onChange={(e) => setIdTurma(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm bg-white"
            >
              <option value="1">1º Período (Turma 1)</option>
              <option value="2">2º Período (Turma 2)</option>
              <option value="3">3º Período (Turma 3)</option>
            </select>
          </div>

          <label className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-xl p-6 flex flex-col items-center justify-center gap-2 hover:bg-gray-100 transition-colors cursor-pointer">
            <svg
              className="w-8 h-8 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
              />
            </svg>
            <span className="text-gray-600 font-medium text-sm">
              {arquivo ? arquivo.name : 'Clique para selecionar o arquivo'}
            </span>
            <span className="text-gray-400 text-xs">Suporta PDF, JPG, PNG e TXT (Max 10MB)</span>
            <input
              type="file"
              accept=".pdf,.jpg,.jpeg,.png,.txt"
              onChange={selecionarArquivo}
              className="hidden"
            />
          </label>

          <div className="flex justify-end gap-3 mt-2 pt-4 border-t border-gray-100">
            <button
              type="button"
              onClick={fecharModal}
              className="px-5 py-2.5 text-sm font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={enviando}
              className="px-5 py-2.5 text-sm font-semibold text-white bg-[#DC2626] hover:bg-red-800 disabled:opacity-60 rounded-lg transition-colors shadow-sm"
            >
              {enviando ? 'Enviando...' : 'Enviar para Revisão'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}