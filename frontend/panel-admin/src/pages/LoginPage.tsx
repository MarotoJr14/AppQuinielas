import { useState } from 'react';
import type { FormEvent } from 'react';
import { Navigate } from 'react-router-dom';
import { Button } from '../components/Button';
import { ErrorBanner } from '../components/Estados';
import { Input } from '../components/FormField';
import { useAuth } from '../context/AuthContext';
import { extraerMensajeError } from '../api/client';

export function LoginPage() {
  const { estado, iniciarSesion } = useAuth();
  const [nombreUsuario, setNombreUsuario] = useState('');
  const [password, setPassword] = useState('');
  const [cargando, setCargando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (estado === 'autenticado') {
    return <Navigate to="/" replace />;
  }

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    setError(null);
    setCargando(true);
    try {
      await iniciarSesion(nombreUsuario.trim(), password);
    } catch (err) {
      setError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="login-pagina">
      <div className="login-tarjeta">
        <div className="login-logo">Q</div>
        <h1 style={{ textAlign: 'center', fontSize: '1.3rem', marginBottom: 4 }}>Administración de Quinielas</h1>
        <p className="texto-secundario" style={{ textAlign: 'center', marginBottom: 24 }}>
          Accede con tu cuenta de administrador del sistema.
        </p>
        {error ? <ErrorBanner mensaje={error} /> : null}
        <form onSubmit={handleSubmit}>
          <Input
            etiqueta="Nombre de usuario"
            value={nombreUsuario}
            onChange={(evento) => setNombreUsuario(evento.target.value)}
            autoFocus
            required
          />
          <Input
            etiqueta="Contraseña"
            type="password"
            value={password}
            onChange={(evento) => setPassword(evento.target.value)}
            required
          />
          <Button type="submit" variante="primario" ancho cargando={cargando}>
            Entrar
          </Button>
        </form>
      </div>
    </div>
  );
}
