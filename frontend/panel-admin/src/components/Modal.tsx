import type { MouseEvent, ReactNode } from 'react';

interface ModalProps {
  titulo: string;
  onClose: () => void;
  children: ReactNode;
  acciones?: ReactNode;
  ancho?: number;
}

export function Modal({ titulo, onClose, children, acciones, ancho }: ModalProps) {
  const detenerPropagacion = (evento: MouseEvent) => evento.stopPropagation();

  return (
    <div className="modal-fondo" onClick={onClose} role="presentation">
      <div
        className="modal"
        style={ancho ? { maxWidth: ancho } : undefined}
        onClick={detenerPropagacion}
        role="dialog"
        aria-modal="true"
        aria-label={titulo}
      >
        <div className="modal__cabecera">
          <h2 className="modal__titulo">{titulo}</h2>
          <button className="boton boton--icono" onClick={onClose} aria-label="Cerrar">
            ✕
          </button>
        </div>
        {children}
        {acciones ? <div className="modal__acciones">{acciones}</div> : null}
      </div>
    </div>
  );
}
