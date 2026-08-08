import type { MouseEvent, ReactNode } from 'react';

interface DrawerProps {
  titulo: string;
  subtitulo?: string;
  onClose: () => void;
  children: ReactNode;
  acciones?: ReactNode;
}

/** Panel lateral ("ficha") para mostrar el detalle de un registro, con sus relaciones. */
export function Drawer({ titulo, subtitulo, onClose, children, acciones }: DrawerProps) {
  const detenerPropagacion = (evento: MouseEvent) => evento.stopPropagation();

  return (
    <div className="drawer-fondo" onClick={onClose} role="presentation">
      <div className="drawer" onClick={detenerPropagacion} role="dialog" aria-modal="true" aria-label={titulo}>
        <div className="drawer__cabecera">
          <div>
            <h2 className="drawer__titulo">{titulo}</h2>
            {subtitulo ? <p className="texto-secundario">{subtitulo}</p> : null}
          </div>
          <button className="boton boton--icono" onClick={onClose} aria-label="Cerrar">
            ✕
          </button>
        </div>
        <div className="drawer__contenido">{children}</div>
        {acciones ? <div className="drawer__acciones">{acciones}</div> : null}
      </div>
    </div>
  );
}
