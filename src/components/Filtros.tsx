export function Filtros() {
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
        <button className="bg-yellow-400 text-white font-semibold rounded-md px-6 py-2 hover:bg-blue-700">
          Buscar
        </button>

      </div>

    </div>
  );
}