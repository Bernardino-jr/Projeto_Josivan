export function Rodape(){
    const anoAtual = new Date().getFullYear()
    
    return(

        <footer className="mt-16 pb-8 pt-6 text-center">
            <p className="text-sm text-gray-1000">
                Desenvolvido de forma colaborativa e sem fins lucrativos pela turma de <strong className="text-[blue] font-semibold">Análise e Desenvolvimento de Sistemas</strong>.
            </p>
            <p className="text-xs text-gray-600 mt-2">
                Projeto de Código Aberto © {anoAtual} | UNINASSAU  
            </p>
        </footer>

    )


}