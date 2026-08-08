import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import { login as loginRequest, obtenerMiUsuario } from '../api/auth';
import { TOKEN_STORAGE_KEY, extraerMensajeError } from '../api/client';
import type { Usuario } from '../types/models';

/** El usuario con id=1 es el administrador del sistema (ver backend). */
export const ADMIN_USUARIO_ID = 1;

type EstadoSesion = 'comprobando' | 'invitado' | 'autenticado';

interface AuthContextValue {
  estado: EstadoSesion;
  usuario: Usuario | null;
  iniciarSesion: (nombreUsuario: string, password: string) => Promise<void>;
  cerrarSesion: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [estado, setEstado] = useState<EstadoSesion>('comprobando');
  const [usuario, setUsuario] = useState<Usuario | null>(null);

  useEffect(() => {
    const token = localStorage.getItem(TOKEN_STORAGE_KEY);
    if (!token) {
      setEstado('invitado');
      return;
    }
    obtenerMiUsuario()
      .then((datos) => {
        if (datos.id !== ADMIN_USUARIO_ID) {
          localStorage.removeItem(TOKEN_STORAGE_KEY);
          setEstado('invitado');
          return;
        }
        setUsuario(datos);
        setEstado('autenticado');
      })
      .catch(() => {
        localStorage.removeItem(TOKEN_STORAGE_KEY);
        setEstado('invitado');
      });
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      estado,
      usuario,
      iniciarSesion: async (nombreUsuario: string, password: string) => {
        const { access_token: token } = await loginRequest({ nombre_usuario: nombreUsuario, password });
        localStorage.setItem(TOKEN_STORAGE_KEY, token);
        try {
          const datos = await obtenerMiUsuario();
          if (datos.id !== ADMIN_USUARIO_ID) {
            localStorage.removeItem(TOKEN_STORAGE_KEY);
            throw new Error('Esta cuenta no tiene permisos de administrador del sistema.');
          }
          setUsuario(datos);
          setEstado('autenticado');
        } catch (error) {
          localStorage.removeItem(TOKEN_STORAGE_KEY);
          setEstado('invitado');
          throw error instanceof Error ? error : extraerMensajeError(error);
        }
      },
      cerrarSesion: () => {
        localStorage.removeItem(TOKEN_STORAGE_KEY);
        setUsuario(null);
        setEstado('invitado');
      },
    }),
    [estado, usuario],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth debe usarse dentro de un AuthProvider.');
  return ctx;
}
