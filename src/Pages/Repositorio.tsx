import { useState, useEffect } from 'react';
import { Navbar } from '../components/Navbar';
import { LinhaMaterial } from '../components/LinhaMaterial';
import { Filtros } from '../components/Filtros';
import { Tabs } from '../components/Tabs';
import { Modal } from '../components/Modal';
import { Rodape } from '../components/Rodape';
import { URL_BASE_API } from '../services/api';

interface MaterialAPI {
  id_material: number;
  titulo: string;
  descricao: string;
  tipo_material: string;
  url_download?: string | null;
  turma?: {
    semestre?: number;
    disciplina?: { nome?: string };
  };
}

export function Repositorio() {
  const [modalAberto, setModalAberto] = useState(false);
  const [abaAtiva, setAbaAtiva] = useState('Todos');
  const [materiais, setMateriais] = useState<MaterialAPI[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [termoBusca, setTermoBusca] = useState('');

  async function carregarMateriaisAprovados() {
    setCarregando(true);
    try {
      const resposta = await fetch(`${URL_BASE_API}/materiais`);
      if (resposta.ok) {
        const dados = await resposta.json();
        setMateriais(dados);
      }
    } catch {
      console.warn('Não foi possível buscar materiais da API no momento.');
    } finally {
      setCarregando(false);
    }
  }

  useEffect(() => {
    carregarMateriaisAprovados();
  }, []);

  const materiaisFiltrados = materiais.filter((item) => {
    const bateCategoria =
      abaAtiva === 'Todos' ||
      (abaAtiva === 'PDFs' && item.tipo_material === 'PDF') ||
      (abaAtiva === 'Vídeos' && item.tipo_material === 'VIDEO') ||
      (abaAtiva === 'Planilhas' && item.tipo_material === 'TXT');

    const termo = termoBusca.toLowerCase().trim();
    const bateTexto =
      !termo ||
      item.titulo.toLowerCase().includes(termo) ||
      item.descricao.toLowerCase().includes(termo) ||
      (item.turma?.disciplina?.nome || '').toLowerCase().includes(termo);

    return bateCategoria && bateTexto;
  });

  return (
    <div className="min-h-screen relative z-0 bg-slate-50">
      <div className="absolute inset-0 opacity-10 bg-[url('/uninassau-bg.jpg')] bg-center bg-contain bg-no-repeat bg-fixed pointer-events-none" />
      <main className="max-w-6xl mx-auto p-6 relative z-10">
        <Navbar />
        <h1 className="text-2xl font-medium text-blue-700 mt-4">
          Materiais de Estudo
        </h1>
        <p className="font-medium text-blue-700 mt-2 mb-4">
          Selecione o curso e o período abaixo para filtrar os materiais aprovados.
        </p>

        <Filtros
          abrirModal={() => setModalAberto(true)}
          termoBusca={termoBusca}
          aoMudarBusca={setTermoBusca}
        />
        <Tabs abaAtiva={abaAtiva} setAbaAtiva={setAbaAtiva} />

        <div className="mt-6">
          <div className="grid grid-cols-5 gap-4 px-4 py-3 text-xs font-bold text-blue-700 uppercase border-b border-gray-200 bg-gray-50 mb-4">
            <span>Material / Assunto</span>
            <span>Disciplina</span>
            <span>Período</span>
            <span>Formato</span>
            <span>Acessar</span>
          </div>

          {carregando ? (
            <p className="text-center text-gray-500 py-8">Carregando materiais aprovados...</p>
          ) : materiaisFiltrados.length === 0 ? (
            <p className="text-center text-gray-500 py-8">
              Nenhum material aprovado encontrado nesta categoria.
            </p>
          ) : (
            materiaisFiltrados.map((item) => (
              <LinhaMaterial
                key={item.id_material}
                id={item.id_material}
                titulo={item.titulo}
                assunto={item.descricao}
                disciplina={item.turma?.disciplina?.nome || 'ADS Geral'}
                periodo={item.turma?.semestre ? `${item.turma.semestre}º período` : 'Geral'}
                formato={item.tipo_material}
                urlDownload={item.url_download}
              />
            ))
          )}
        </div>
        <Rodape />
      </main>

      {modalAberto && (
        <Modal
          fecharModal={() => setModalAberto(false)}
          aoEnviarComSucesso={carregarMateriaisAprovados}
        />
      )}
    </div>
  );
}