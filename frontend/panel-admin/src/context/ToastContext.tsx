import { createContext, useCallback, useContext, useMemo, useState } from 'react';
import type { ReactNode } from 'react';

type TipoToast = 'exito' | 'error' | 'info';

interface Toast {
  id: number;
  tipo: TipoToast;
  mensaje: string;
}

interface ToastContextValue {
  mostrarExito: (mensaje: string) => void;
  mostrarError: (mensaje: string) => void;
  mostrarInfo: (mensaje: string) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

let siguienteId = 1;

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const quitar = useCallback((id: number) => {
    setToasts((actuales) => actuales.filter((t) => t.id !== id));
  }, []);

  const agregar = useCallback(
    (tipo: TipoToast, mensaje: string) => {
      const id = siguienteId++;
      setToasts((actuales) => [...actuales, { id, tipo, mensaje }]);
      setTimeout(() => quitar(id), 4500);
    },
    [quitar],
  );

  const value = useMemo<ToastContextValue>(
    () => ({
      mostrarExito: (mensaje: string) => agregar('exito', mensaje),
      mostrarError: (mensaje: string) => agregar('error', mensaje),
      mostrarInfo: (mensaje: string) => agregar('info', mensaje),
    }),
    [agregar],
  );

  return (
    <ToastContext.Provider value={value}>
      {children}
      <div className="toast-contenedor" aria-live="polite">
        {toasts.map((toast) => (
          <div key={toast.id} className={`toast toast--${toast.tipo}`} onClick={() => quitar(toast.id)}>
            {toast.mensaje}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast(): ToastContextValue {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast debe usarse dentro de un ToastProvider.');
  return ctx;
}
