import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import { ToastProvider } from './context/ToastContext';
import { JornadasPage } from './pages/JornadasPage';
import { CompeticionesPage } from './pages/CompeticionesPage';
import { EquiposPage } from './pages/EquiposPage';
import { JornadaDetailPage } from './pages/JornadaDetailPage';
import { LoginPage } from './pages/LoginPage';
import { TemporadasPage } from './pages/TemporadasPage';

export default function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        <BrowserRouter>
          <AuthProvider>
            <Routes>
              <Route path="/login" element={<LoginPage />} />
              <Route element={<ProtectedRoute />}>
                <Route path="/" element={<JornadasPage />} />
                <Route path="/jornadas/:id" element={<JornadaDetailPage />} />
                <Route path="/equipos" element={<EquiposPage />} />
                <Route path="/competiciones" element={<CompeticionesPage />} />
                <Route path="/temporadas" element={<TemporadasPage />} />
              </Route>
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </AuthProvider>
        </BrowserRouter>
      </ToastProvider>
    </ThemeProvider>
  );
}
