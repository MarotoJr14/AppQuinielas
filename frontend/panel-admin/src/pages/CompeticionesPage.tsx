import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { Button } from '../components/Button';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Drawer } from '../components/Drawer';
import { Cargando, ErrorBanner, EstadoVacio } from '../components/Estados';
import { EntityTable } from '../components/EntityTable';
import type { ColumnaTabla } from '../components/EntityTable';
import { CompeticionFicha } from '../components/fichas/CompeticionFicha';
import { Input, Select } from '../components/FormField';
import { ImportarCompeticionesModal } from '../components/ImportarCompeticionesModal';
import { Modal } from '../components/Modal';
import { extraerMensajeError } from '../api/client';
import { actualizarCompeticion, crearCompeticion, eliminarCompeticion } from '../api/competiciones';
import { listarTemporadaCompeticiones, obtenerOCrearTemporadaCompeticion } from '../api/temporadaCompeticiones';
import { useCatalogoDatos } from '../hooks/useCatalogoDatos';
import { useToast } from '../context/ToastContext';
import type { Competicion, Temporada } from '../types/models';

export function CompeticionesPage() {
  const { mostrarExito, mostrarError } = useToast();
  const { temporadas, competiciones, equipos, temporadaCompeticiones, vinculosEquipo, cargando, error, recargar } = useCatalogoDatos();

  const [busqueda, setBusqueda] = useState('');
  const [filtroTemporadaId, setFiltroTemporadaId] = useState<number | ''>('');
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modalImportacionAbierto, setModalImportacionAbierto] = useState(false);
  const [competicionEnEdicion, setCompeticionEnEdicion] = useState<Competicion | null>(null);
  const [competicionParaFicha, setCompeticionParaFicha] = useState<Competicion | null>(null);
  const [competicionAEliminar, setCompeticionAEliminar] = useState<Competicion | null>(null);
  const [eliminando, setEliminando] = useState(false);

  const competicionIdsDelFiltro = useMemo<Set<number> | null>(() => {
    if (filtroTemporadaId === '') return null;
    return new Set(temporadaCompeticiones.filter((tc) => tc.temporada_id === filtroTemporadaId).map((tc) => tc.competicion_id));
  }, [filtroTemporadaId, temporadaCompeticiones]);

  const filtrados = competiciones
    .filter((c) => c.nombre.toLowerCase().includes(busqueda.toLowerCase()))
    .filter((c) => competicionIdsDelFiltro === null || competicionIdsDelFiltro.has(c.id));

  const columnas: ColumnaTabla<Competicion>[] = [
    { clave: 'nombre', etiqueta: 'Nombre', render: (c) => <strong>{c.nombre}</strong>, ordenar: (c) => c.nombre.toLowerCase() },
    { clave: 'ambito', etiqueta: 'Ámbito', render: (c) => c.ambito, ordenar: (c) => c.ambito.toLowerCase() },
    {
      clave: 'tipo',
      etiqueta: 'Tipo',
      render: (c) => <span className={`etiqueta ${c.es_clubes ? 'etiqueta--acento' : ''}`}>{c.es_clubes ? 'Clubes' : 'Selecciones'}</span>,
      ordenar: (c) => (c.es_clubes ? 'Clubes' : 'Selecciones'),
    },
  ];

  async function handleEliminar() {
    if (!competicionAEliminar) return;
    setEliminando(true);
    try {
      await eliminarCompeticion(competicionAEliminar.id);
      mostrarExito('Competición eliminada correctamente.');
      setCompeticionAEliminar(null);
      if (competicionParaFicha?.id === competicionAEliminar.id) setCompeticionParaFicha(null);
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
          <h1 className="cabecera-pagina__titulo">Competiciones</h1>
          <p className="cabecera-pagina__subtitulo">Listado global de competiciones disponibles para las jornadas.</p>
        </div>
        <div className="fila-acciones">
          <Button variante="secundario" onClick={() => setModalImportacionAbierto(true)}>
            ⬆ Importación masiva
          </Button>
          <Button variante="primario" onClick={() => setModalAbierto(true)}>
            + Nueva competición
          </Button>
        </div>
      </div>

      <Input
        placeholder="Buscar competición..."
        value={busqueda}
        onChange={(evento) => setBusqueda(evento.target.value)}
        style={{ marginBottom: 14 }}
      />

      <div className="grid-dos-columnas" style={{ marginBottom: 20 }}>
        <Select
          etiqueta="Temporada"
          value={filtroTemporadaId}
          onChange={(evento) => setFiltroTemporadaId(evento.target.value === '' ? '' : Number(evento.target.value))}
        >
          <option value="">Todas las temporadas</option>
          {temporadas.map((t) => (
            <option key={t.id} value={t.id}>
              {t.nombre}
            </option>
          ))}
        </Select>
        <div />
      </div>

      {cargando ? (
        <Cargando />
      ) : error ? (
        <ErrorBanner mensaje={error} onReintentar={recargar} />
      ) : filtrados.length === 0 ? (
        <EstadoVacio
          icono="🏆"
          titulo="No se han encontrado competiciones"
          subtitulo="Prueba a ajustar el filtro o crea una competición nueva."
        />
      ) : (
        <EntityTable
          columnas={columnas}
          filas={filtrados}
          onVerFicha={setCompeticionParaFicha}
          onEditar={setCompeticionEnEdicion}
          onEliminar={setCompeticionAEliminar}
        />
      )}

      {modalAbierto ? (
        <ModalCompeticion
          temporadas={temporadas}
          onClose={() => setModalAbierto(false)}
          onGuardado={() => {
            setModalAbierto(false);
            mostrarExito('Competición creada correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {competicionEnEdicion ? (
        <ModalCompeticion
          competicion={competicionEnEdicion}
          temporadas={temporadas}
          onClose={() => setCompeticionEnEdicion(null)}
          onGuardado={() => {
            setCompeticionEnEdicion(null);
            mostrarExito('Competición actualizada correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {modalImportacionAbierto ? (
        <ImportarCompeticionesModal
          temporadas={temporadas}
          competicionesExistentes={competiciones}
          onClose={() => setModalImportacionAbierto(false)}
          onCompletado={() => void recargar()}
        />
      ) : null}

      {competicionParaFicha ? (
        <Drawer titulo={competicionParaFicha.nombre} subtitulo="Ficha de competición" onClose={() => setCompeticionParaFicha(null)}>
          <CompeticionFicha
            competicion={competicionParaFicha}
            temporadas={temporadas}
            equipos={equipos}
            temporadaCompeticiones={temporadaCompeticiones}
            vinculosEquipo={vinculosEquipo}
          />
        </Drawer>
      ) : null}

      {competicionAEliminar ? (
        <ConfirmDialog
          titulo="Eliminar competición"
          mensaje={`¿Seguro que quieres eliminar "${competicionAEliminar.nombre}"? Se eliminarán también sus vínculos con temporadas y equipos. Los partidos que la tuvieran asignada quedarán sin competición asignada.`}
          textoConfirmar="Eliminar"
          peligroso
          cargando={eliminando}
          onConfirmar={handleEliminar}
          onCancelar={() => setCompeticionAEliminar(null)}
        />
      ) : null}
    </div>
  );
}

function ModalCompeticion({
  competicion,
  temporadas,
  onClose,
  onGuardado,
}: {
  competicion?: Competicion;
  temporadas: Temporada[];
  onClose: () => void;
  onGuardado: () => void;
}) {
  const { mostrarError } = useToast();
  const [nombre, setNombre] = useState(competicion?.nombre ?? '');
  const [ambito, setAmbito] = useState(competicion?.ambito ?? 'Nacional');
  const [esClubes, setEsClubes] = useState(competicion?.es_clubes ?? true);
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [cargando, setCargando] = useState(false);

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    if (nombre.trim().length < 2) {
      mostrarError('Introduce un nombre de competición válido.');
      return;
    }
    if (!competicion && !temporadaId) {
      mostrarError('Selecciona la temporada a la que pertenecerá la competición.');
      return;
    }
    setCargando(true);
    try {
      if (competicion) {
        await actualizarCompeticion(competicion.id, { nombre: nombre.trim(), ambito: ambito.trim(), es_clubes: esClubes });
      } else {
        const nueva = await crearCompeticion({ nombre: nombre.trim(), ambito: ambito.trim(), es_clubes: esClubes });
        const existentes = await listarTemporadaCompeticiones();
        await obtenerOCrearTemporadaCompeticion(existentes, temporadaId, nueva.id);
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
      titulo={competicion ? 'Editar competición' : 'Nueva competición'}
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-competicion" type="submit" cargando={cargando}>
            Guardar
          </Button>
        </>
      }
    >
      <form id="form-competicion" onSubmit={handleSubmit}>
        <Input etiqueta="Nombre" value={nombre} onChange={(evento) => setNombre(evento.target.value)} autoFocus required />
        <Input etiqueta="Ámbito" value={ambito} onChange={(evento) => setAmbito(evento.target.value)} required placeholder="ej. Nacional, Internacional..." />
        <Select
          etiqueta="Tipo"
          value={esClubes ? 'clubes' : 'selecciones'}
          onChange={(evento) => setEsClubes(evento.target.value === 'clubes')}
        >
          <option value="clubes">Clubes</option>
          <option value="selecciones">Selecciones nacionales</option>
        </Select>
        {!competicion ? (
          <Select
            etiqueta="Temporada"
            value={temporadaId}
            onChange={(evento) => setTemporadaId(Number(evento.target.value))}
            ayuda="La competición quedará vinculada a esta temporada."
            required
          >
            {temporadas.map((t) => (
              <option key={t.id} value={t.id}>
                {t.nombre}
              </option>
            ))}
          </Select>
        ) : null}
      </form>
    </Modal>
  );
}
