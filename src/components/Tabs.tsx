// 1. Criamos o contrato tipado avisando o que este componente vai receber do pai
interface TabsProps {
  abaAtiva: string;
  setAbaAtiva: (aba: string) => void;
}


// 2. O componente agora recebe as informações pelas "props" (entre chaves)
export function Tabs({ abaAtiva, setAbaAtiva }: TabsProps) {

    return(

        <div className="flex gap-2 mb-8 mt-6">
    
       {/* BOTÃO 1 */}
      <button 
        onClick={() => setAbaAtiva('Todos')}
        className={`font-medium rounded-full px-4 py-1.5 text-sm transition-colors ${
          abaAtiva === 'Todos' 
            ? 'bg-[yellow] text-blue-700' 
            : 'text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300'
        }`}
      >
        Todos os Materiais
      </button>

        {/* BOTÃO 2 */}
      <button 
        onClick={() => setAbaAtiva('PDFs')}
        className={`font-medium rounded-full px-4 py-1.5 text-sm transition-colors ${
          abaAtiva === 'PDFs' 
            ? 'bg-[yellow] text-blue-700' 
            : 'text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300'
        }`}
      >
        PDFs
      </button>

       {/* BOTÃO 3 */}
      <button 
        onClick={() => setAbaAtiva('Vídeos')}
        className={`font-medium rounded-full px-4 py-1.5 text-sm transition-colors ${
          abaAtiva === 'Vídeos' 
            ? 'bg-[yellow] text-blue-700' 
            : 'text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300'
        }`}
      >
        Vídeos
      </button>

       {/* BOTÃO 4 */}
      <button 
        onClick={() => setAbaAtiva('Planilhas')}
        className={`font-medium rounded-full px-4 py-1.5 text-sm transition-colors ${
          abaAtiva === 'Planilhas' 
            ? 'bg-[yellow] text-blue-700' 
            : 'text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300'
        }`}
      >
        Planilhas/Textos
      </button>

        </div>
    )
}