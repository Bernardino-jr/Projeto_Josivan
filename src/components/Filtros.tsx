interface FiltrosProps {
  abrirModal: () => void;
}
export function Filtros({ abrirModal }: FiltrosProps) {
  return (
    // 1. CAIXA PRINCIPAL (Fundo branco e borda suave ao redor de todo o componente)
    <div className="max-w-3xl p-3 bg-white rounded-lg border border-gray-200">
      
      {/* 2. LINHA 1: BUSCA (O flex e o gap-4 alinham o input e o botão) */}
      <div className="flex gap-4">
        
        {/* 3. INPUT (Filho direto do flex, sem nenhuma div extra ao redor) */}
        <input 
          type="text" 
          placeholder="Pesquisar" 
          className="flex-1 border border-gray-300 rounded-md px-8 py-4 text-sm text-ellipsis" 
        />
        
        {/* 4. BOTÃO (Classes limpas, separadas apenas por espaço) */}
        <button className="bg-yellow-500 text-white font-semibold rounded-md px-6 py-2 hover:bg-blue-700">
          Buscar
        </button>

      </div>

      {/* BANNER DE COMUNIDADE */}
        <div className="mt-6 bg-blue-50 border-l-4 border-[#1E3A8A] p-5 mb-8 rounded-r-lg flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-sm">
          <div>
            <h2 className="text-lg font-bold text-blue-700 flex items-center gap-2">
              Feito de Alunos para Alunos 🎓
            </h2>
            <p className="text-gray-700 text-sm mt-1 leading-relaxed">
              Este repositório é 100% colaborativo. Todo o material acadêmico disponível aqui é criado, revisado e mantido pela comunidade de estudantes de ADS.
            </p>
          </div>
          
          <button onClick={abrirModal} className="bg-[#DC2626] hover:bg-red-800 text-white font-semibold px-5 py-2.5 rounded-md transition-colors text-sm whitespace-nowrap shadow-sm">
            + Adicionar Materiais
          </button>
        </div>

    </div>
  );
}