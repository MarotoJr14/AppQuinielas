import { Button } from './Button';
import { Modal } from './Modal';

interface ConfirmDialogProps {
  titulo: string;
  mensaje: string;
  textoConfirmar?: string;
  peligroso?: boolean;
  cargando?: boolean;
  onConfirmar: () => void;
  onCancelar: () => void;
}

export function ConfirmDialog({
  titulo,
  mensaje,
  textoConfirmar = 'Confirmar',
  peligroso = false,
  cargando = false,
  onConfirmar,
  onCancelar,
}: ConfirmDialogProps) {
  return (
    <Modal
      titulo={titulo}
      onClose={onCancelar}
      ancho={420}
      acciones={
        <>
          <Button variante="secundario" onClick={onCancelar} disabled={cargando}>
            Cancelar
          </Button>
          <Button variante={peligroso ? 'peligro' : 'primario'} onClick={onConfirmar} cargando={cargando}>
            {textoConfirmar}
          </Button>
        </>
      }
    >
      <p>{mensaje}</p>
    </Modal>
  );
}
