import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { Button } from '../components/Button';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Drawer } from '../components/Drawer';
import { Cargando, ErrorBanner, EstadoVacio } from '../components/Estados';
import { EntityTable } from '../components/EntityTable';
import type { ColumnaTabla } from '../components/EntityTable';
import { EquipoFicha } from '../components/fichas/EquipoFicha';
import { Input, Select } from '../components/FormField';
import { ImportarEquiposModal } from '../components/ImportarEquiposModal';
import { Modal } from '../components/Modal';
import { extraerMensajeError } from '../api/client';
import { actualizarEquipo, crearEquipo, eliminarEquipo } from '../api/equipos';
import { vincularEquipoATemporadaCompeticion } from '../api/equipoTemporadaCompeticiones';
import { listarTemporadaCompeticiones, obtenerOCrearTemporadaCompeticion } from '../api/temporadaCompeticiones';
import { useCatalogoDatos } from '../hooks/useCatalogoDatos';
import { useToast } from '../context/ToastContext';
import type { Competicion, Equipo, Temporada } from '../types/models';

export function EquiposPage() {
  const { mostrarExito, mostrarError } = useToast();
  const { temporadas, competiciones, equipos, temporadaCompeticiones, vinculosEquipo, cargando, error, recargar } = useCatalogoDatos();

  const [busqueda, setBusqueda] = useState('');
  const [filtroTemporadaId, setFiltroTemporadaId] = useState<number | ''>('');
  const [filtroCompeticionId, setFiltroCompeticionId] = useState<number | ''>('');
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modalImportacionAbierto, setModalImportacionAbierto] = useState(false);
  const [equipoEnEdicion, setEquipoEnEdicion] = useState<Equipo | null>(null);
  const [equipoParaFicha, setEquipoParaFicha] = useState<Equipo | null>(null);
  const [equipoAEliminar, setEquipoAEliminar] = useState<Equipo | null>(null);
  const [eliminando, setEliminando] = useState(false);

  const competicionesDelFiltro = useMemo(() => {
    if (filtroTemporadaId === '') return [];
    const idsCompeticion = new Set(
      temporadaCompeticiones.filter((tc) => tc.temporada_id === filtroTemporadaId).map((tc) => tc.competicion_id),
    );
    return competiciones.filter((c) => idsCompeticion.has(c.id));
  }, [filtroTemporadaId, temporadaCompeticiones, competiciones]);

  const equipoIdsDelFiltro = useMemo<Set<number> | null>(() => {
    if (filtroTemporadaId === '') return null;
    const idsTemporadaCompeticion = new Set(
      temporadaCompeticiones
        .filter((tc) => tc.temporada_id === filtroTemporadaId && (filtroCompeticionId === '' || tc.competicion_id === filtroCompeticionId))
        .map((tc) => tc.id),
    );
    return new Set(vinculosEquipo.filter((v) => idsTemporadaCompeticion.has(v.temporada_competicion_id)).map((v) => v.equipo_id));
  }, [filtroTemporadaId, filtroCompeticionId, temporadaCompeticiones, vinculosEquipo]);

  const filtrados = equipos
    .filter((e) => e.nombre.toLowerCase().includes(busqueda.toLowerCase()))
    .filter((e) => equipoIdsDelFiltro === null || equipoIdsDelFiltro.has(e.id));

  const columnas: ColumnaTabla<Equipo>[] = [
    { clave: 'nombre', etiqueta: 'Nombre', render: (e) => <strong>{e.nombre}</strong>, ordenar: (e) => e.nombre.toLowerCase() },
    { clave: 'pais', etiqueta: 'País', render: (e) => e.pais, ordenar: (e) => e.pais.toLowerCase() },
    {
      clave: 'tipo',
      etiqueta: 'Tipo',
      render: (e) => (
        <span className={`etiqueta ${e.es_club ? 'etiqueta--acento' : ''}`}>{e.es_club ? 'Club' : 'Selección'}</span>
      ),
      ordenar: (e) => (e.es_club ? 'Club' : 'Selección'),
    },
  ];

  async function handleEliminar() {
    if (!equipoAEliminar) return;
    setEliminando(true);
    try {
      await eliminarEquipo(equipoAEliminar.id);
      mostrarExito('Equipo eliminado correctamente.');
      setEquipoAEliminar(null);
      if (equipoParaFicha?.id === equipoAEliminar.id) setEquipoParaFicha(null);
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
          <h1 className="cabecera-pagina__titulo">Equipos</h1>
          <p className="cabecera-pagina__subtitulo">Listado global de equipos disponibles para los partidos.</p>
        </div>
        <div className="fila-acciones">
          <Button variante="secundario" onClick={() => setModalImportacionAbierto(true)}>
            ⬆ Importación masiva
          </Button>
          <Button variante="primario" onClick={() => setModalAbierto(true)}>
            + Nuevo equipo
          </Button>
        </div>
      </div>

      <Input
        placeholder="Buscar equipo..."
        value={busqueda}
        onChange={(evento) => setBusqueda(evento.target.value)}
        style={{ marginBottom: 14 }}
      />

      <div className="grid-dos-columnas" style={{ marginBottom: 20 }}>
        <Select
          etiqueta="Temporada"
          value={filtroTemporadaId}
          onChange={(evento) => {
            setFiltroTemporadaId(evento.target.value === '' ? '' : Number(evento.target.value));
            setFiltroCompeticionId('');
          }}
        >
          <option value="">Todas las temporadas</option>
          {temporadas.map((t) => (
            <option key={t.id} value={t.id}>
              {t.nombre}
            </option>
          ))}
        </Select>
        <Select
          etiqueta="Competición"
          value={filtroCompeticionId}
          onChange={(evento) => setFiltroCompeticionId(evento.target.value === '' ? '' : Number(evento.target.value))}
          disabled={filtroTemporadaId === ''}
        >
          <option value="">{filtroTemporadaId === '' ? 'Selecciona antes una temporada' : 'Todas las competiciones'}</option>
          {competicionesDelFiltro.map((c) => (
            <option key={c.id} value={c.id}>
              {c.nombre}
            </option>
          ))}
        </Select>
      </div>

      {cargando ? (
        <Cargando />
      ) : error ? (
        <ErrorBanner mensaje={error} onReintentar={recargar} />
      ) : filtrados.length === 0 ? (
        <EstadoVacio icono="⚽" titulo="No se han encontrado equipos" subtitulo="Prueba a ajustar el filtro o crea un equipo nuevo." />
      ) : (
        <EntityTable
          columnas={columnas}
          filas={filtrados}
          onVerFicha={setEquipoParaFicha}
          onEditar={setEquipoEnEdicion}
          onEliminar={setEquipoAEliminar}
        />
      )}

      {modalAbierto ? (
        <ModalEquipo
          temporadas={temporadas}
          competiciones={competiciones}
          onClose={() => setModalAbierto(false)}
          onGuardado={() => {
            setModalAbierto(false);
            mostrarExito('Equipo creado correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {equipoEnEdicion ? (
        <ModalEquipo
          equipo={equipoEnEdicion}
          temporadas={temporadas}
          competiciones={competiciones}
          onClose={() => setEquipoEnEdicion(null)}
          onGuardado={() => {
            setEquipoEnEdicion(null);
            mostrarExito('Equipo actualizado correctamente.');
            void recargar();
          }}
        />
      ) : null}

      {modalImportacionAbierto ? (
        <ImportarEquiposModal
          temporadas={temporadas}
          competiciones={competiciones}
          equiposExistentes={equipos}
          onClose={() => setModalImportacionAbierto(false)}
          onCompletado={() => void recargar()}
        />
      ) : null}

      {equipoParaFicha ? (
        <Drawer titulo={equipoParaFicha.nombre} subtitulo="Ficha de equipo" onClose={() => setEquipoParaFicha(null)}>
          <EquipoFicha
            equipo={equipoParaFicha}
            temporadas={temporadas}
            competiciones={competiciones}
            temporadaCompeticiones={temporadaCompeticiones}
            vinculosEquipo={vinculosEquipo}
          />
        </Drawer>
      ) : null}

      {equipoAEliminar ? (
        <ConfirmDialog
          titulo="Eliminar equipo"
          mensaje={`¿Seguro que quieres eliminar "${equipoAEliminar.nombre}"? Se eliminarán también sus vínculos con competiciones y temporadas. Los partidos que lo tuvieran asignado quedarán sin equipo asignado.`}
          textoConfirmar="Eliminar"
          peligroso
          cargando={eliminando}
          onConfirmar={handleEliminar}
          onCancelar={() => setEquipoAEliminar(null)}
        />
      ) : null}
    </div>
  );
}

function ModalEquipo({
  equipo,
  temporadas,
  competiciones,
  onClose,
  onGuardado,
}: {
  equipo?: Equipo;
  temporadas: Temporada[];
  competiciones: Competicion[];
  onClose: () => void;
  onGuardado: () => void;
}) {
  const { mostrarError } = useToast();
  const [nombre, setNombre] = useState(equipo?.nombre ?? '');
  const [pais, setPais] = useState(equipo?.pais ?? 'España');
  const [esClub, setEsClub] = useState(equipo?.es_club ?? true);
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [competicionId, setCompeticionId] = useState<number>(0);
  const [cargando, setCargando] = useState(false);

  // Solo se muestran (y se pueden elegir) las competiciones compatibles con
  // el tipo de equipo seleccionado: no se puede vincular una selección
  // nacional a una competición de clubes, ni viceversa.
  const competicionesCompatibles = useMemo(
    () => competiciones.filter((c) => c.es_clubes === esClub),
    [competiciones, esClub],
  );

  function handleCambiarTipo(nuevoEsClub: boolean) {
    setEsClub(nuevoEsClub);
    setCompeticionId(0);
  }

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    if (nombre.trim().length < 2) {
      mostrarError('Introduce un nombre de equipo válido.');
      return;
    }
    if (!equipo) {
      if (!temporadaId) {
        mostrarError('Selecciona la temporada a la que pertenecerá el equipo.');
        return;
      }
      if (!competicionId) {
        mostrarError('Selecciona la competición a la que pertenecerá el equipo.');
        return;
      }
      const competicionElegida = competiciones.find((c) => c.id === competicionId);
      if (competicionElegida && competicionElegida.es_clubes !== esClub) {
        mostrarError(
          `No se puede vincular un equipo de tipo '${esClub ? 'Club' : 'Selección'}' a una competición de tipo '${
            competicionElegida.es_clubes ? 'Clubes' : 'Selecciones'
          }'.`,
        );
        return;
      }
    }

    setCargando(true);
    try {
      if (equipo) {
        await actualizarEquipo(equipo.id, { nombre: nombre.trim(), pais: pais.trim(), es_club: esClub });
      } else {
        const nuevo = await crearEquipo({ nombre: nombre.trim(), pais: pais.trim(), es_club: esClub });
        const existentes = await listarTemporadaCompeticiones();
        const temporadaCompeticion = await obtenerOCrearTemporadaCompeticion(existentes, temporadaId, competicionId);
        await vincularEquipoATemporadaCompeticion(nuevo.id, temporadaCompeticion.id);
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
      titulo={equipo ? 'Editar equipo' : 'Nuevo equipo'}
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-equipo" type="submit" cargando={cargando}>
            Guardar
          </Button>
        </>
      }
    >
      <form id="form-equipo" onSubmit={handleSubmit}>
        <Input etiqueta="Nombre" value={nombre} onChange={(evento) => setNombre(evento.target.value)} autoFocus required />
        <Input etiqueta="País" value={pais} onChange={(evento) => setPais(evento.target.value)} required />
        <Select etiqueta="Tipo" value={esClub ? 'club' : 'seleccion'} onChange={(evento) => handleCambiarTipo(evento.target.value === 'club')}>
          <option value="club">Club</option>
          <option value="seleccion">Selección nacional</option>
        </Select>

        {!equipo ? (
          <>
            <Select etiqueta="Temporada" value={temporadaId} onChange={(evento) => setTemporadaId(Number(evento.target.value))} required>
              {temporadas.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.nombre}
                </option>
              ))}
            </Select>
            <Select
              etiqueta="Competición"
              value={competicionId}
              onChange={(evento) => setCompeticionId(Number(evento.target.value))}
              ayuda="Solo se muestran competiciones compatibles con el tipo de equipo elegido."
              required
            >
              <option value={0} disabled>
                Selecciona una competición
              </option>
              {competicionesCompatibles.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nombre}
                </option>
              ))}
            </Select>
          </>
        ) : null}
      </form>
    </Modal>
  );
}
