interface FiltrosProps {
  abrirModal: () => void;
  termoBusca: string;
  aoMudarBusca: (valor: string) => void;
}

export function Filtros({ abrirModal, termoBusca, aoMudarBusca }: FiltrosProps) {
  return (
    <div className="max-w-4xl p-3 bg-white rounded-lg border border-gray-200">
      <form
        onSubmit={(e) => e.preventDefault()}
        className="flex gap-4"
      >
        <input
          type="text"
          value={termoBusca}
          onChange={(e) => aoMudarBusca(e.target.value)}
          placeholder="Pesquisar por título, assunto ou disciplina..."
          className="flex-1 border border-gray-300 rounded-md px-4 py-2 text-sm text-ellipsis"
        />

        <button
          type="submit"
          className="bg-yellow-500 text-white font-semibold rounded-md px-6 py-2 hover:bg-blue-700 cursor-pointer"
        >
          Buscar
        </button>
      </form>

      <div className="mt-6 bg-blue-50 border-l-4 border-[#1E3A8A] p-5 mb-6 rounded-r-lg flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-sm">
        <div>
          <h2 className="text-lg font-bold text-blue-900 flex items-center gap-2">
            Feito de Alunos para Alunos 🎓
          </h2>
          <p className="text-gray-700 text-sm mt-1 leading-relaxed">
            Este repositório é 100% colaborativo. Todo o material acadêmico disponível aqui
            é criado, revisado e mantido pela comunidade de estudantes de ADS.
          </p>
        </div>

        <button
          onClick={abrirModal}
          className="bg-[#DC2626] hover:bg-red-800 text-white font-semibold px-5 py-2.5 rounded-md transition-colors text-sm whitespace-nowrap shadow-sm cursor-pointer"
        >
          + Adicionar Materiais
        </button>
      </div>
    </div>
  );
}