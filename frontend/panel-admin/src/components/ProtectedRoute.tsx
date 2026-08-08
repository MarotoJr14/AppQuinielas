import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Cargando } from './Estados';
import { Layout } from './Layout';

export function ProtectedRoute() {
  const { estado } = useAuth();

  if (estado === 'comprobando') {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Cargando />
      </div>
    );
  }

  if (estado === 'invitado') {
    return <Navigate to="/login" replace />;
  }

  return <Layout />;
}
