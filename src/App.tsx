import { Navbar } from './components/Navbar';
import { LinhaMaterial } from './components/LinhaMaterial';
import { Filtros } from './components/Filtros';
import { Tabs } from './components/Tabs';

function App() {

  const materiais = [
    { id: 1, titulo: "Introdução ao React", assunto: "Componentes, propriedades e estado", disciplina: "Programação Web", periodo: "3º período", formato: "PDF" },
    { id: 2, titulo: "Modelagem de dados", assunto: "Modelo entidade-relacionamento", disciplina: "Banco de Dados", periodo: "2º período", formato: "PDF" },
    { id: 3, titulo: "Lógica e algoritmos", assunto: "Estruturas de decisão", disciplina: "Lógica de Programação", periodo: "1º período", formato: "Planilha" } ];
  return (
   <div className="min-h-screen relative z-0 bg-slate-50">
      <div className="absolute inset-0 opacity-10 bg-[url('/uninassau-bg.jpg')] bg-center bg-contain bg-no-repeat bg-fixed pointer-events-none"></div>
      <main className="max-w-6xl mx-auto p-6 relative z-10">
        <Navbar/>
        {/* PRIMEIRO ELEMENTO */}
        <h1 className="text-2xl font-medium text-blue-700 mt-4">
          Materiais de Estudo
        </h1>
        <p className="font-medium text-blue-700 mt-2 mb-4">
          Selecione o curso e o período abaixo para filtrar os materiais aprovados.
        </p>

         <Filtros/>
         <Tabs/>
        {/* SEGUNDO ELEMENTO: A Lista Dinâmica */}
        <div className="mt-8">
          {/* Cabeçalho das Colunas */}
          <div className="grid grid-cols-5 gap-4 px-4 py-3 text-xs font-bold text-blue-700 uppercase border-b border-gray-200 bg-gray-50 mb-4">
            <span>Material / Assunto</span>
            <span>Disciplina</span>
            <span>Período</span>
            <span>Formato</span>
            <span>Acessar</span>
          </div>

          {/* Renderização Automática das Linhas */}
          {materiais.map((item) => (
            <LinhaMaterial 
              key={item.id}
              id={item.id}
              titulo={item.titulo} 
              assunto={item.assunto}
              disciplina={item.disciplina} 
              periodo={item.periodo}
              formato={item.formato}
            />
          ))}
        </div>
      </main>
    </div>
  );
}

export default App;