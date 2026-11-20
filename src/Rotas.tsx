import { ReactNode } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Login } from './Pages/Login';
import { Repositorio } from './Pages/Repositorio';
import { obterToken } from './services/api';

interface RotaPrivadaProps {
  children: ReactNode;
}

function RotaPrivada({ children }: RotaPrivadaProps) {
  const estaAutenticado = Boolean(obterToken());
  return estaAutenticado ? <>{children}</> : <Navigate to="/" replace />;
}

export function Rotas() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />

        {/* Rota Protegida: exige token JWT válido no localStorage */}
        <Route
          path="/repositorio"
          element={
            <RotaPrivada>
              <Repositorio />
            </RotaPrivada>
          }
        />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}