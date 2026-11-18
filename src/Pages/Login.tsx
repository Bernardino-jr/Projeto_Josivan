import { Navbar } from '../components/Navbar';
import { useNavigate } from 'react-router-dom';

export function Login() {
  const navigate = useNavigate();

  const fazerLogin = (e: React.FormEvent) => {
    e.preventDefault(); 
    navigate('/repositorio');
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      <Navbar />
      <main className="flex-1 flex items-center justify-center p-6 relative overflow-hidden">
        
        {/* Camada da imagem de fundo (Marca d'água) */}
        <div 
          className="absolute inset-0 bg-[url('/uninassau-bg.jpg')] bg-contain bg-center bg-no-repeat opacity-20 pointer-events-none"
        />

        {/* Cartão do Formulário */}
        <div className="bg-white/95 backdrop-blur-sm p-8 rounded-xl shadow-lg border border-gray-100 w-full max-w-md relative z-10">
          
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-[#1E3A8A] mb-2">Acesso ao Repositório</h2>
            <p className="text-gray-600">Faça login para acessar os materiais da turma de ADS.</p>
          </div>

          <form onSubmit={fazerLogin} className="flex flex-col gap-5">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Matrícula
              </label>
              <input
                type="text"
                placeholder="Ex: 01926669"
                className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#1E3A8A] transition-all bg-white"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1">
                Senha
              </label>
              <input
                type="password"
                placeholder="••••••••"
                className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#1E3A8A] transition-all bg-white"
                required
              />
            </div>

            <button
              type="submit"
              className="w-full mt-2 bg-[#1E3A8A] hover:bg-blue-900 text-white font-bold py-3 px-4 rounded-lg transition-colors shadow-sm hover:bg-yellow-600"
            >
              Entrar no Repositório
            </button>
          </form>

          <div className="mt-6 text-center text-sm text-gray-500 border-t border-gray-100 pt-6">
            Primeiro acesso?{' '}
            <a href="#" className="text-yellow-600 font-semibold hover:underline hover:text-blue-800">
              Solicite a sua senha
            </a>
          </div>

        </div>
      </main>
    </div>
  );
}