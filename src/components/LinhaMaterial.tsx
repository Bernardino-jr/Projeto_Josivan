interface Material {
  id: number;
  titulo: string;
  assunto: string;
  disciplina: string;
  periodo: string;
  formato: string;
  urlDownload?: string | null;
}

export function LinhaMaterial(props: Material) {
  function handleAbrir() {
    if (!props.urlDownload) {
      alert('Este material de exemplo não possui arquivo anexado no Storage.');
      return;
    }

    window.open(props.urlDownload, '_blank', 'noopener,noreferrer');
  }

  return (
    <div className="grid grid-cols-5 gap-4 px-4 py-4 items-center bg-white border-b border-gray-200 hover:bg-gray-50">
      {/* Coluna 1: Material / Assunto */}
      <div className="flex flex-col">
        <strong className="text-yellow-500">{props.titulo}</strong>
        <span className="text-sm text-blue-700">{props.assunto}</span>
      </div>

      {/* Coluna 2: Disciplina */}
      <p className="text-blue-700">{props.disciplina}</p>

      {/* Coluna 3: Período */}
      <p className="text-yellow-500">{props.periodo}</p>

      {/* Coluna 4: Formato */}
      <p className="text-blue-700">{props.formato}</p>

      {/* Coluna 5: Acessar */}
      <div>
        <button
          type="button"
          onClick={handleAbrir}
          className="border border-gray-300 rounded px-4 py-1.5 text-sm font-semibold text-gray-700 hover:bg-yellow-500 transition-colors cursor-pointer"
        >
          Abrir ↗
        </button>
      </div>
    </div>
  );
}