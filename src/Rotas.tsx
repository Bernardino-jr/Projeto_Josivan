import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Login } from './Pages/Login';
import { Repositorio } from './Pages/Repositorio';

export function Rotas() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Rotas apontando para a Tela de Login */}
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />

        {/* Rota do Acervo */}
        <Route path="/repositorio" element={<Repositorio />} />

        {/* Rota de segurança: se digitar uma URL inválida, volta para o início */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}

