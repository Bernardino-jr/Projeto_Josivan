interface ModalProps {
  fecharModal: () => void;
}

export function Modal({ fecharModal }: ModalProps) {
  return (
    /* Fundo escuro com desfoque (Overlay) */
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 px-4">
      
      <div className="bg-white rounded-xl p-6 w-full max-w-lg shadow-2xl flex flex-col gap-4 animate-in fade-in zoom-in duration-200">
        
        {/* Cabeçalho do Modal */}
        <div className="flex justify-between items-center border-b border-gray-100 pb-3">
          <h2 className="text-xl font-bold text-[#1E3A8A]">Compartilhar Material</h2>
          <button 
            onClick={fecharModal} 
            className="text-gray-400 hover:text-red-600 font-bold text-2xl leading-none transition-colors"
          >
            ×
          </button>
        </div>
        
        {/* Texto Explicativo */}
        <p className="text-gray-600 text-sm">
          Preencha as informações do arquivo que deseja compartilhar com a turma de ADS.
        </p>
        
        {/* Área de Upload / Formulário */}
        <div className="bg-gray-50 border-2 border-dashed border-gray-300 rounded-xl p-10 flex flex-col items-center justify-center gap-2 hover:bg-gray-100 transition-colors cursor-pointer">
          {/* Ícone de Nuvem/Upload em SVG */}
          <svg className="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
          </svg>
          <span className="text-gray-600 font-medium text-sm">Clique ou arraste o arquivo aqui</span>
          <span className="text-gray-400 text-xs">Suporta PDF, DOCX e XLSX (Max 10MB)</span>
        </div>

        {/* Botões de Ação */}
        <div className="flex justify-end gap-3 mt-2 pt-4 border-t border-gray-100">
          <button 
            onClick={fecharModal} 
            className="px-5 py-2.5 text-sm font-semibold text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
          >
            Cancelar
          </button>
          <button className="px-5 py-2.5 text-sm font-semibold text-white bg-[#DC2626] hover:bg-red-800 rounded-lg transition-colors shadow-sm">
            Enviar para Revisão
          </button>
        </div>

      </div>
    </div>
  );
}