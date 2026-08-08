import { useState } from 'react';
import type { FormEvent } from 'react';
import { Button } from '../components/Button';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Drawer } from '../components/Drawer';
import { Cargando, ErrorBanner, EstadoVacio } from '../components/Estados';
import { EntityTable } from '../components/EntityTable';
import type { ColumnaTabla } from '../components/EntityTable';
import { TemporadaFicha } from '../components/fichas/TemporadaFicha';
import { Input } from '../components/FormField';
import { Modal } from '../components/Modal';
import { extraerMensajeError } from '../api/client';
import { actualizarTemporada, crearTemporada, eliminarTemporada } from '../api/temporadas';
import { useCatalogoDatos } from '../hooks/useCatalogoDatos';
import { useToast } from '../context/ToastContext';
import type { Temporada } from '../types/models';

export function TemporadasPage() {
  const { mostrarExito, mostrarError } = useToast();
  const { temporadas, competiciones, temporadaCompeticiones, cargando, error, recargar } = useCatalogoDatos();

  const [busqueda, setBusqueda] = useState('');
  const [modalAbierto, setModalAbierto] = useState(false);
  const [temporadaEnEdicion, setTemporadaEnEdicion] = useState<Temporada | null>(null);
  const [temporadaParaFicha, setTemporadaParaFicha] = useState<Temporada | null>(null);
  const [temporadaAEliminar, setTemporadaAEliminar] = useState<Temporada | null>(null);
  const [eliminando, setEliminando] = useState(false);

  const filtradas = temporadas.filter((t) => t.nombre.toLowerCase().includes(busqueda.toLowerCase()));

  const columnas: ColumnaTabla<Temporada>[] = [
    { clave: 'nombre', etiqueta: 'Nombre', render: (t) => <strong>{t.nombre}</strong>, ordenar: (t) => t.nombre.toLowerCase() },
    {
      clave: 'competiciones',
      etiqueta: 'Competiciones vinculadas',
      render: (t) => temporadaCompeticiones.filter((tc) => tc.temporada_id === t.id).length,
      ordenar: (t) => temporadaCompeticiones.filter((tc) => tc.temporada_id === t.id).length,
    },
  ];

  async function handleEliminar() {
    if (!temporadaAEliminar) return;
    setEliminando(true);
    try {
      await eliminarTemporada(temporadaAEliminar.id);
      mostrarExito('Temporada eliminada correctamente.');
      setTemporadaAEliminar(null);
      if (temporadaParaFicha?.id === temporadaAEliminar.id) setTemporadaParaFicha(null);
      await recargar();
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setEliminando(false);
    }
  }

  return (
    <div>
      <div className="cabecera-pagina">
        <div>
          <h1 className="cabecera-pagina__titulo">Temporadas</h1>
          <p className="cabecera-pagina__subtitulo">Listado global de temporadas del sistema.</p>
        </div>
        <Button variante="primario" onClick={() => setModalAbierto(true)}>
          + Nueva temporada
        </Button>
      </div>

      <Input
        placeholder="Buscar temporada..."
        value={busqueda}
        onChange={(evento) => setBusqueda(evento.target.value)}
        style={{ marginBottom: 20 }}
      />

      {cargando ? (
        <Cargando />
      ) : error ? (
        <ErrorBanner mensaje={error} onReintentar={recargar} />
      ) : filtradas.length === 0 ? (
        <EstadoVacio icono="📅" titulo="No se han encontrado temporadas" subtitulo="Crea la primera para empezar a añadir jornadas." />
      ) : (
        <EntityTable
          columnas={columnas}
          filas={filtradas}
          onVerFicha={setTemporadaParaFicha}
          onEditar={setTemporadaEnEdicion}
          onEliminar={setTemporadaAEliminar}
        />
      )}

      {modalAbierto ? (
        <ModalTemporada
          onClose={() => setModalAbierto(false)}
          onGuardado={() => {
            setModalAbierto(false);
            mostrarExito('Temporada creada correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {temporadaEnEdicion ? (
        <ModalTemporada
          temporada={temporadaEnEdicion}
          onClose={() => setTemporadaEnEdicion(null)}
          onGuardado={() => {
            setTemporadaEnEdicion(null);
            mostrarExito('Temporada actualizada correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {temporadaParaFicha ? (
        <Drawer titulo={temporadaParaFicha.nombre} subtitulo="Ficha de temporada" onClose={() => setTemporadaParaFicha(null)}>
          <TemporadaFicha temporada={temporadaParaFicha} competiciones={competiciones} temporadaCompeticiones={temporadaCompeticiones} />
        </Drawer>
      ) : null}

      {temporadaAEliminar ? (
        <ConfirmDialog
          titulo="Eliminar temporada"
          mensaje={`¿Seguro que quieres eliminar "${temporadaAEliminar.nombre}"? Se eliminarán también TODAS sus jornadas, partidos, apuestas y vínculos con competiciones. Esta acción es especialmente destructiva y no se puede deshacer.`}
          textoConfirmar="Eliminar de todos modos"
          peligroso
          cargando={eliminando}
          onConfirmar={handleEliminar}
          onCancelar={() => setTemporadaAEliminar(null)}
        />
      ) : null}
    </div>
  );
}

function ModalTemporada({
  temporada,
  onClose,
  onGuardado,
}: {
  temporada?: Temporada;
  onClose: () => void;
  onGuardado: () => void;
}) {
  const { mostrarError } = useToast();
  const [nombre, setNombre] = useState(temporada?.nombre ?? '');
  const [cargando, setCargando] = useState(false);

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    if (nombre.trim().length < 2) {
      mostrarError('Introduce un nombre de temporada válido.');
      return;
    }
    setCargando(true);
    try {
      if (temporada) {
        await actualizarTemporada(temporada.id, nombre.trim());
      } else {
        await crearTemporada(nombre.trim());
      }
      onGuardado();
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <Modal
      titulo={temporada ? 'Editar temporada' : 'Nueva temporada'}
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-temporada" type="submit" cargando={cargando}>
            Guardar
          </Button>
        </>
      }
    >
      <form id="form-temporada" onSubmit={handleSubmit}>
        <Input
          etiqueta="Nombre"
          placeholder="ej. 2026-2027"
          value={nombre}
          onChange={(evento) => setNombre(evento.target.value)}
          autoFocus
          required
        />
      </form>
    </Modal>
  );
}
