interface Material {
    id: number;
    titulo: string;
    assunto: string;
    disciplina: string;
    periodo: string;
    formato: string;
}
export function LinhaMaterial(props:Material){
    return (

    <div className="grid grid-cols-5 gap-4 items-center border-b border-gray-200 hover:bg-gray-50">
    
    {/* Coluna 1: Material / Assunto */}
    <div className="flex flex-col">
        <strong className="text-gray-800"> {props.titulo} </strong>    
        <span className="text-sm text-gray-500">{props.assunto}</span>
    </div>

    {/* Coluna 2: Disciplina*/}
    <p className="text-gray-600">{props.disciplina}</p>

    {/* Coluna 3: Periodo*/}
    <p className="text-gray-600">{props.periodo}</p>

    {/* Coluna 4: Formato*/}
    <p className="text-gray-600">{props.formato}</p>
    
        <div>
            <button className="border border-gray-300 rounded px-4 text-sm font-semibold text-gray-700">
            Abrir ↗
            </button>
        </div>

    </div>
);
}