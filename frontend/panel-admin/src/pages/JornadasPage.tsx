import { useEffect, useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '../components/Button';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Drawer } from '../components/Drawer';
import { Cargando, ErrorBanner, EstadoVacio } from '../components/Estados';
import { EntityTable } from '../components/EntityTable';
import type { ColumnaTabla } from '../components/EntityTable';
import { JornadaFicha } from '../components/fichas/JornadaFicha';
import { Input, Select } from '../components/FormField';
import { ImportarJornadaModal } from '../components/ImportarJornadaModal';
import { Modal } from '../components/Modal';
import { useToast } from '../context/ToastContext';
import { listarCompeticiones } from '../api/competiciones';
import { listarEquipos } from '../api/equipos';
import { crearJornada, eliminarJornada, listarJornadas, listarPremiosDeJornada } from '../api/jornadas';
import { listarPartidosDeJornada } from '../api/partidos';
import { listarTemporadaCompeticiones } from '../api/temporadaCompeticiones';
import { listarTemporadas } from '../api/temporadas';
import { extraerMensajeError } from '../api/client';
import type { Competicion, Equipo, Jornada, Partido, PremioJornada, Temporada, TemporadaCompeticion } from '../types/models';
import { formatearFecha, inputLocalAIso } from '../utils/fechas';

export function JornadasPage() {
  const navigate = useNavigate();
  const { mostrarExito, mostrarError } = useToast();

  const [temporadas, setTemporadas] = useState<Temporada[]>([]);
  const [jornadas, setJornadas] = useState<Jornada[]>([]);
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [competiciones, setCompeticiones] = useState<Competicion[]>([]);
  const [temporadaCompeticiones, setTemporadaCompeticiones] = useState<TemporadaCompeticion[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busqueda, setBusqueda] = useState('');
  const [filtroTemporadaId, setFiltroTemporadaId] = useState<number | ''>('');

  const [modalJornadaAbierto, setModalJornadaAbierto] = useState(false);
  const [modalImportacionAbierto, setModalImportacionAbierto] = useState(false);
  const [jornadaAEliminar, setJornadaAEliminar] = useState<Jornada | null>(null);
  const [eliminando, setEliminando] = useState(false);

  const [jornadaParaFicha, setJornadaParaFicha] = useState<Jornada | null>(null);
  const [fichaCargando, setFichaCargando] = useState(false);
  const [fichaError, setFichaError] = useState<string | null>(null);
  const [fichaPartidos, setFichaPartidos] = useState<Partido[]>([]);
  const [fichaPremios, setFichaPremios] = useState<PremioJornada[]>([]);

  async function cargarDatos() {
    setCargando(true);
    setError(null);
    try {
      const [listaTemporadas, listaJornadas, listaEquipos, listaCompeticiones, listaTemporadaCompeticiones] = await Promise.all([
        listarTemporadas(),
        listarJornadas(),
        listarEquipos(),
        listarCompeticiones(),
        listarTemporadaCompeticiones(),
      ]);
      setTemporadas(listaTemporadas);
      setJornadas(listaJornadas);
      setEquipos(listaEquipos);
      setCompeticiones(listaCompeticiones);
      setTemporadaCompeticiones(listaTemporadaCompeticiones);
    } catch (err) {
      setError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    void cargarDatos();
  }, []);

  function nombreTemporada(temporadaId: number): string {
    return temporadas.find((t) => t.id === temporadaId)?.nombre ?? `Temporada #${temporadaId}`;
  }

  const filtradas = useMemo(() => {
    return jornadas
      .filter((j) => j.nombre.toLowerCase().includes(busqueda.toLowerCase()))
      .filter((j) => filtroTemporadaId === '' || j.temporada_id === filtroTemporadaId);
  }, [jornadas, busqueda, filtroTemporadaId]);

  const columnas: ColumnaTabla<Jornada>[] = [
    { clave: 'nombre', etiqueta: 'Nombre', render: (j) => <strong>{j.nombre}</strong>, ordenar: (j) => j.nombre.toLowerCase() },
    {
      clave: 'temporada',
      etiqueta: 'Temporada',
      render: (j) => nombreTemporada(j.temporada_id),
      ordenar: (j) => nombreTemporada(j.temporada_id).toLowerCase(),
    },
    {
      clave: 'fecha_cierre',
      etiqueta: 'Fecha de cierre',
      render: (j) => formatearFecha(j.fecha_cierre),
      ordenar: (j) => new Date(j.fecha_cierre).getTime(),
    },
  ];

  async function handleEliminarJornada() {
    if (!jornadaAEliminar) return;
    setEliminando(true);
    try {
      await eliminarJornada(jornadaAEliminar.id);
      mostrarExito('Jornada eliminada correctamente.');
      setJornadaAEliminar(null);
      if (jornadaParaFicha?.id === jornadaAEliminar.id) setJornadaParaFicha(null);
      await cargarDatos();
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setEliminando(false);
    }
  }

  async function abrirFicha(jornada: Jornada) {
    setJornadaParaFicha(jornada);
    setFichaCargando(true);
    setFichaError(null);
    try {
      const [partidos, premios] = await Promise.all([listarPartidosDeJornada(jornada.id), listarPremiosDeJornada(jornada.id)]);
      setFichaPartidos(partidos);
      setFichaPremios(premios);
    } catch (err) {
      setFichaError(extraerMensajeError(err).message);
    } finally {
      setFichaCargando(false);
    }
  }

  return (
    <div>
      <div className="cabecera-pagina">
        <div>
          <h1 className="cabecera-pagina__titulo">Jornadas</h1>
          <p className="cabecera-pagina__subtitulo">Gestiona las jornadas y sus quinielas.</p>
        </div>
        <div className="fila-acciones">
          <Button variante="secundario" onClick={() => setModalImportacionAbierto(true)}>
            ⬆ Importar jornada
          </Button>
          <Button variante="primario" onClick={() => setModalJornadaAbierto(true)} disabled={temporadas.length === 0}>
            + Nueva jornada
          </Button>
        </div>
      </div>

      <Input
        placeholder="Buscar jornada..."
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
        <ErrorBanner mensaje={error} onReintentar={cargarDatos} />
      ) : filtradas.length === 0 ? (
        <EstadoVacio icono="🗓️" titulo="No se han encontrado jornadas" subtitulo="Crea una jornada nueva o ajusta el filtro." />
      ) : (
        <EntityTable
          columnas={columnas}
          filas={filtradas}
          onVerFicha={(j) => void abrirFicha(j)}
          onEditar={(j) => navigate(`/jornadas/${j.id}`)}
          onEliminar={setJornadaAEliminar}
        />
      )}

      {modalJornadaAbierto ? (
        <ModalNuevaJornada
          temporadas={temporadas}
          onClose={() => setModalJornadaAbierto(false)}
          onCreada={(jornada) => {
            setModalJornadaAbierto(false);
            navigate(`/jornadas/${jornada.id}`);
          }}
        />
      ) : null}

      {modalImportacionAbierto ? (
        <ImportarJornadaModal
          temporadas={temporadas}
          jornadas={jornadas}
          onClose={() => setModalImportacionAbierto(false)}
          onCompletado={() => void cargarDatos()}
        />
      ) : null}

      {jornadaAEliminar ? (
        <ConfirmDialog
          titulo="Eliminar jornada"
          mensaje={`¿Seguro que quieres eliminar "${jornadaAEliminar.nombre}"? Se eliminarán también sus partidos, premios y apuestas asociadas.`}
          textoConfirmar="Eliminar"
          peligroso
          cargando={eliminando}
          onConfirmar={handleEliminarJornada}
          onCancelar={() => setJornadaAEliminar(null)}
        />
      ) : null}

      {jornadaParaFicha ? (
        <Drawer titulo={jornadaParaFicha.nombre} subtitulo="Ficha de jornada" onClose={() => setJornadaParaFicha(null)}>
          {fichaCargando ? (
            <Cargando />
          ) : fichaError ? (
            <ErrorBanner mensaje={fichaError} onReintentar={() => void abrirFicha(jornadaParaFicha)} />
          ) : (
            <JornadaFicha
              jornada={jornadaParaFicha}
              temporada={temporadas.find((t) => t.id === jornadaParaFicha.temporada_id)}
              partidos={fichaPartidos}
              premios={fichaPremios}
              equipos={equipos}
              competiciones={competiciones}
              temporadaCompeticiones={temporadaCompeticiones}
            />
          )}
        </Drawer>
      ) : null}
    </div>
  );
}

function ModalNuevaJornada({
  temporadas,
  onClose,
  onCreada,
}: {
  temporadas: Temporada[];
  onClose: () => void;
  onCreada: (jornada: Jornada) => void;
}) {
  const { mostrarError } = useToast();
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [nombre, setNombre] = useState('');
  const [fechaCierre, setFechaCierre] = useState('');
  const [cargando, setCargando] = useState(false);

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    if (nombre.trim().length < 2) {
      mostrarError('Introduce un nombre de jornada válido.');
      return;
    }
    const fechaIso = inputLocalAIso(fechaCierre);
    if (!fechaIso) {
      mostrarError('Selecciona una fecha y hora de cierre válidas.');
      return;
    }
    setCargando(true);
    try {
      const jornada = await crearJornada({ temporada_id: temporadaId, nombre: nombre.trim(), fecha_cierre: fechaIso });
      onCreada(jornada);
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <Modal
      titulo="Nueva jornada"
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-nueva-jornada" type="submit" cargando={cargando}>
            Crear jornada
          </Button>
        </>
      }
    >
      <form id="form-nueva-jornada" onSubmit={handleSubmit}>
        <Select etiqueta="Temporada" value={temporadaId} onChange={(evento) => setTemporadaId(Number(evento.target.value))} required>
          {temporadas.map((temporada) => (
            <option key={temporada.id} value={temporada.id}>
              {temporada.nombre}
            </option>
          ))}
        </Select>
        <Input
          etiqueta="Nombre de la jornada"
          placeholder="ej. J1"
          value={nombre}
          onChange={(evento) => setNombre(evento.target.value)}
          autoFocus
          required
        />
        <Input
          etiqueta="Fecha y hora de cierre"
          type="datetime-local"
          value={fechaCierre}
          onChange={(evento) => setFechaCierre(evento.target.value)}
          required
        />
      </form>
    </Modal>
  );
}
