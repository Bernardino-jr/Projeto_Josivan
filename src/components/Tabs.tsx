export function Tabs() {
    return(

        <div className="flex gap-2 mb-8 mt-6">
    
        <button className="bg-[yellow] text-blue-700 font-medium rounded-full px-4 py-1.5 text-sm">
            Todos os Materias:
        </button>

        <button className="text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300 font-medium rounded-full px-4 py-1.5 text-sm transition-colors">
            PDFs
        </button>

        <button className="text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300 font-medium rounded-full px-4 py-1.5 text-sm transition-colors">
            Videos
        </button>

        <button className="text-blue-700 hover:text-[#1E3A8A] hover:bg-yellow-300 font-medium rounded-full px-4 py-1.5 text-sm transition-colors">
            Planilhas/Textos
        </button>

        </div>

    )
}