import type { ReactNode } from 'react';
import { Button } from './Button';

export function Cargando() {
  return (
    <div className="cargando">
      <div className="spinner" />
    </div>
  );
}

interface ErrorBannerProps {
  mensaje: string;
  onReintentar?: () => void;
}

export function ErrorBanner({ mensaje, onReintentar }: ErrorBannerProps) {
  return (
    <div className="banner-error">
      <span>⚠️</span>
      <span style={{ flex: 1 }}>{mensaje}</span>
      {onReintentar ? (
        <Button variante="secundario" chico onClick={onReintentar}>
          Reintentar
        </Button>
      ) : null}
    </div>
  );
}

interface EstadoVacioProps {
  icono?: string;
  titulo: string;
  subtitulo?: string;
  accion?: ReactNode;
}

export function EstadoVacio({ icono = '📭', titulo, subtitulo, accion }: EstadoVacioProps) {
  return (
    <div className="estado-vacio">
      <div className="estado-vacio__icono">{icono}</div>
      <div className="estado-vacio__titulo">{titulo}</div>
      {subtitulo ? <p>{subtitulo}</p> : null}
      {accion ? <div style={{ marginTop: 16 }}>{accion}</div> : null}
    </div>
  );
}
