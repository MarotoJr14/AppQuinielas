import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Button } from '../components/Button';
import { Cargando, ErrorBanner, EstadoVacio } from '../components/Estados';
import { Input, Select } from '../components/FormField';
import { Modal } from '../components/Modal';
import { ImportarPremiosModal } from '../components/ImportarPremiosModal';
import { extraerMensajeError } from '../api/client';
import { listarCompeticiones } from '../api/competiciones';
import { listarEquipos } from '../api/equipos';
import { listarEquipoTemporadaCompeticiones } from '../api/equipoTemporadaCompeticiones';
import { actualizarPremio, crearPremio, listarPremiosDeJornada, obtenerJornada } from '../api/jornadas';
import {
  actualizarPartido,
  generarQuincePartidos,
  listarPartidosDeJornada,
  registrarResultado,
} from '../api/partidos';
import { listarTemporadaCompeticiones } from '../api/temporadaCompeticiones';
import { useToast } from '../context/ToastContext';
import { CATEGORIAS_PREMIO, ETIQUETA_CATEGORIA } from '../types/models';
import { obtenerInfoEstadoJornada } from '../utils/estadosJornada';
import type {
  CategoriaPremio,
  Competicion,
  Equipo,
  EquipoTemporadaCompeticion,
  EstadoPartido,
  Jornada,
  Partido,
  PremioJornada,
  TemporadaCompeticion,
} from '../types/models';
import { formatearFecha, inputLocalAIso, isoAInputLocal } from '../utils/fechas';
import { validarPartidoParaJornada } from '../utils/validacionesPartido';

export function JornadaDetailPage() {
  const { id } = useParams<{ id: string }>();
  const jornadaId = Number(id);
  const navigate = useNavigate();
  const { mostrarExito, mostrarError } = useToast();

  const [jornada, setJornada] = useState<Jornada | null>(null);
  const [partidos, setPartidos] = useState<Partido[]>([]);
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [competiciones, setCompeticiones] = useState<Competicion[]>([]);
  const [temporadaCompeticiones, setTemporadaCompeticiones] = useState<TemporadaCompeticion[]>([]);
  const [vinculosEquipo, setVinculosEquipo] = useState<EquipoTemporadaCompeticion[]>([]);
  const [premios, setPremios] = useState<PremioJornada[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [generando, setGenerando] = useState(false);
  const [modalPremiosAbierto, setModalPremiosAbierto] = useState(false);
  const [modalImportarPremiosAbierto, setModalImportarPremiosAbierto] = useState(false);
  const [partidoEnEdicion, setPartidoEnEdicion] = useState<Partido | null>(null);

  // Estado "en juego" del partido: es un estado puramente visual/manual de
  // esta pantalla (el backend no almacena un estado de partido, solo el
  // resultado), por lo que se gestiona en memoria durante la sesión. Al
  // cargar la jornada se inicializa como "finalizado" si ya tiene resultado
  // guardado, o "pendiente" en caso contrario.
  const [partidosActualizandoEstado, setPartidosActualizandoEstado] = useState<Set<number>>(new Set());

  async function cargarTodo() {
    setCargando(true);
    setError(null);
    try {
      const [datosJornada, datosPartidos, datosEquipos, datosCompeticiones, datosTemporadaCompeticiones, datosVinculosEquipo, datosPremios] =
        await Promise.all([
          obtenerJornada(jornadaId),
          listarPartidosDeJornada(jornadaId),
          listarEquipos(),
          listarCompeticiones(),
          listarTemporadaCompeticiones(),
          listarEquipoTemporadaCompeticiones(),
          listarPremiosDeJornada(jornadaId),
        ]);
      setJornada(datosJornada);
      setPartidos(datosPartidos);
      setEquipos(datosEquipos);
      setCompeticiones(datosCompeticiones);
      setTemporadaCompeticiones(datosTemporadaCompeticiones);
      setVinculosEquipo(datosVinculosEquipo);
      setPremios(datosPremios);
    } catch (err) {
      setError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    if (Number.isFinite(jornadaId)) {
      void cargarTodo();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [jornadaId]);

  async function handleGenerarPartidos() {
    setGenerando(true);
    try {
      const nuevos = await generarQuincePartidos(jornadaId);
      setPartidos(nuevos);
      mostrarExito('Se han creado los 15 partidos de la jornada.');
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setGenerando(false);
    }
  }

  function nombreEquipo(equipoId: number | null): string {
    if (equipoId === null) return 'Por confirmar';
    return equipos.find((e) => e.id === equipoId)?.nombre ?? `Equipo #${equipoId}`;
  }

  function nombreCompeticion(competicionTemporadaId: number | null): string {
    if (competicionTemporadaId === null) return 'Sin competición';
    const temporadaCompeticion = temporadaCompeticiones.find((tc) => tc.id === competicionTemporadaId);
    if (!temporadaCompeticion) return 'Sin competición';
    return competiciones.find((c) => c.id === temporadaCompeticion.competicion_id)?.nombre ?? 'Sin competición';
  }

  function siguienteEstadoPartido(estado: EstadoPartido): EstadoPartido {
    if (estado === 'pendiente') return 'en_juego';
    if (estado === 'en_juego') return 'finalizado';
    return 'finalizado';
  }

  async function ciclarEstado(partido: Partido) {
    if (partido.estado === 'finalizado' || partidosActualizandoEstado.has(partido.id)) return;
    const siguiente = siguienteEstadoPartido(partido.estado);

    setPartidosActualizandoEstado((actuales) => new Set(actuales).add(partido.id));
    try {
      const actualizado = await actualizarPartido(partido.id, { estado: siguiente });
      const jornadaActualizada = await obtenerJornada(jornadaId);
      setPartidos((actuales) => actuales.map((p) => (p.id === partido.id ? actualizado : p)));
      setJornada(jornadaActualizada);
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setPartidosActualizandoEstado((actuales) => {
        const nuevos = new Set(actuales);
        nuevos.delete(partido.id);
        return nuevos;
      });
    }
  }

  if (cargando) return <Cargando />;
  if (error || !jornada) return <ErrorBanner mensaje={error ?? 'No se ha podido cargar la jornada.'} onReintentar={cargarTodo} />;

  return (
    <div>
      <button className="boton boton--secundario boton--chico" style={{ marginBottom: 16 }} onClick={() => navigate('/')}>
        ← Volver al resumen
      </button>

      <div className="cabecera-pagina">
        <div>
          <h1 className="cabecera-pagina__titulo">{jornada.nombre}</h1>
          <p className="cabecera-pagina__subtitulo">Cierre de apuestas: {formatearFecha(jornada.fecha_cierre)}</p>
        </div>
        <div className="fila-acciones">
          <Button variante="secundario" onClick={() => setModalPremiosAbierto(true)}>
            🏆 Premios
          </Button>
          <Button variante="secundario" onClick={() => setModalImportarPremiosAbierto(true)}>
            ⬆ Importar premios
          </Button>
          {partidos.length === 0 ? (
            <Button variante="primario" onClick={handleGenerarPartidos} cargando={generando}>
              + Crear 15 partidos
            </Button>
          ) : null}
        </div>
      </div>

      {partidos.length === 0 ? (
        <EstadoVacio
          icono="⚽"
          titulo="Esta jornada todavía no tiene partidos"
          subtitulo='Pulsa "Crear 15 partidos" para generar los 14 partidos normales más el Pleno al 15.'
        />
      ) : (
        <>
          <div className="fila-acciones" style={{ marginBottom: 10, justifyContent: 'space-between' }}>
            <p className="texto-secundario">
              🟢 Pendiente · 🟡 En juego · 🔴 Finalizado — haz click en el círculo para avanzar el estado del partido.
            </p>
            <span className={`etiqueta ${obtenerInfoEstadoJornada(jornada.estado).clase.includes('finalizado') ? 'etiqueta--error' : obtenerInfoEstadoJornada(jornada.estado).clase.includes('en-juego') ? 'etiqueta--acento' : 'etiqueta--exito'}`}>
              {obtenerInfoEstadoJornada(jornada.estado).texto}
            </span>
          </div>
          <div className="tabla-partidos-envoltorio">
            <table className="tabla-partidos">
              <thead>
                <tr>
                  <th style={{ width: 36 }}>#</th>
                  <th>Estado</th>
                  <th>Competición</th>
                  <th>Equipo local</th>
                  <th>Equipo visitante</th>
                  <th>Fecha y hora</th>
                  <th>Canal</th>
                  <th>Resultado</th>
                  <th style={{ width: 100 }} />
                </tr>
              </thead>
              <tbody>
                {partidos.map((partido) => (
                  <FilaPartido
                    key={partido.id}
                    partido={partido}
                    estado={partido.estado}
                    actualizandoEstado={partidosActualizandoEstado.has(partido.id)}
                    nombreCompeticion={nombreCompeticion(partido.competicion_temporada_id)}
                    nombreLocal={nombreEquipo(partido.equipo_local_id)}
                    nombreVisitante={nombreEquipo(partido.equipo_visitante_id)}
                    onCambiarEstado={() => void ciclarEstado(partido)}
                    onGuardarResultado={async (golesLocal, golesVisitante) => {
                      try {
                        const actualizado = await registrarResultado(partido.id, golesLocal, golesVisitante);
                        const jornadaActualizada = await obtenerJornada(jornadaId);
                        setPartidos((actuales) => actuales.map((p) => (p.id === partido.id ? actualizado : p)));
                        setJornada(jornadaActualizada);
                        mostrarExito(`Resultado del partido ${partido.orden} guardado.`);
                      } catch (err) {
                        mostrarError(extraerMensajeError(err).message);
                      }
                    }}
                    onModificar={() => setPartidoEnEdicion(partido)}
                  />
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {modalPremiosAbierto ? (
        <ModalPremios
          jornadaId={jornadaId}
          premios={premios}
          onClose={() => setModalPremiosAbierto(false)}
          onGuardado={(nuevosPremios) => {
            setPremios(nuevosPremios);
            setModalPremiosAbierto(false);
            mostrarExito('Premios actualizados correctamente.');
          }}
        />
      ) : null}

      {modalImportarPremiosAbierto ? (
        <ImportarPremiosModal
          jornadaId={jornadaId}
          premiosExistentes={premios}
          onClose={() => setModalImportarPremiosAbierto(false)}
          onCompletado={(nuevosPremios) => {
            setPremios(nuevosPremios);
            mostrarExito('Premios importados correctamente.');
          }}
        />
      ) : null}

      {partidoEnEdicion ? (
        <ModalModificarPartido
          partido={partidoEnEdicion}
          temporadaId={jornada.temporada_id}
          fechaCierreJornada={jornada.fecha_cierre}
          partidosDeLaJornada={partidos}
          equipos={equipos}
          competiciones={competiciones}
          temporadaCompeticiones={temporadaCompeticiones}
          vinculosEquipo={vinculosEquipo}
          nombreLocal={nombreEquipo(partidoEnEdicion.equipo_local_id)}
          nombreVisitante={nombreEquipo(partidoEnEdicion.equipo_visitante_id)}
          onClose={() => setPartidoEnEdicion(null)}
          onGuardado={(actualizado) => {
            setPartidos((actuales) => actuales.map((p) => (p.id === actualizado.id ? actualizado : p)));
            setPartidoEnEdicion(null);
            mostrarExito('Partido actualizado correctamente.');
          }}
        />
      ) : null}
    </div>
  );
}

const ESTADO_INFO: Record<EstadoPartido, { texto: string; clase: string }> = {
  pendiente: { texto: 'Pendiente', clase: 'circulo-estado--pendiente' },
  en_juego: { texto: 'En juego', clase: 'circulo-estado--en-juego' },
  finalizado: { texto: 'Finalizado', clase: 'circulo-estado--finalizado' },
};

interface FilaPartidoProps {
  partido: Partido;
  estado: EstadoPartido;
  actualizandoEstado: boolean;
  nombreCompeticion: string;
  nombreLocal: string;
  nombreVisitante: string;
  onCambiarEstado: () => void;
  onGuardarResultado: (golesLocal: number, golesVisitante: number) => Promise<void>;
  onModificar: () => void;
}

function FilaPartido({
  partido,
  estado,
  actualizandoEstado,
  nombreCompeticion,
  nombreLocal,
  nombreVisitante,
  onCambiarEstado,
  onGuardarResultado,
  onModificar,
}: FilaPartidoProps) {
  const [golesLocal, setGolesLocal] = useState(partido.goles_local?.toString() ?? '');
  const [golesVisitante, setGolesVisitante] = useState(partido.goles_visitante?.toString() ?? '');
  const [guardandoResultado, setGuardandoResultado] = useState(false);

  const esPleno = partido.orden === 15;
  const resultadoCambiado =
    golesLocal !== (partido.goles_local?.toString() ?? '') || golesVisitante !== (partido.goles_visitante?.toString() ?? '');
  const puedeModificar = estado === 'pendiente';
  const puedeEditarResultado = estado === 'en_juego';
  const info = ESTADO_INFO[estado];

  async function guardar() {
    const gl = Number(golesLocal);
    const gv = Number(golesVisitante);
    if (golesLocal === '' || golesVisitante === '' || Number.isNaN(gl) || Number.isNaN(gv) || gl < 0 || gv < 0) {
      return;
    }
    setGuardandoResultado(true);
    try {
      await onGuardarResultado(gl, gv);
    } finally {
      setGuardandoResultado(false);
    }
  }

  return (
    <tr className={esPleno ? 'fila-pleno' : ''}>
      <td>{partido.orden}{esPleno ? ' 🎯' : ''}</td>
      <td>
        <button
          type="button"
          className="circulo-estado-boton"
          onClick={onCambiarEstado}
          disabled={estado === 'finalizado' || actualizandoEstado}
          title={`${info.texto}${estado === 'finalizado' ? '' : ' (click para avanzar)'}`}
          aria-label={info.texto}
        >
          <span className={`circulo-estado ${info.clase}`} />
        </button>
      </td>
      <td className="texto-secundario">{nombreCompeticion}</td>
      <td>{nombreLocal}</td>
      <td>{nombreVisitante}</td>
      <td className="texto-secundario">{formatearFecha(partido.fecha_hora)}</td>
      <td className="texto-secundario">{partido.canal ?? '-'}</td>
      <td>
        <div className="celda-resultado">
          <input
            type="number"
            min={0}
            value={golesLocal}
            onChange={(evento) => setGolesLocal(evento.target.value)}
            className="input"
            disabled={!puedeEditarResultado}
          />
          <span>-</span>
          <input
            type="number"
            min={0}
            value={golesVisitante}
            onChange={(evento) => setGolesVisitante(evento.target.value)}
            className="input"
            disabled={!puedeEditarResultado}
          />
          {puedeEditarResultado && resultadoCambiado ? (
            <Button variante="primario" chico onClick={guardar} cargando={guardandoResultado}>
              Guardar
            </Button>
          ) : null}
        </div>
      </td>
      <td>
        <Button
          variante="secundario"
          chico
          onClick={onModificar}
          disabled={!puedeModificar}
          title={puedeModificar ? 'Modificar competición, equipos, fecha y canal' : 'Solo se puede modificar un partido pendiente'}
        >
          Modificar
        </Button>
      </td>
    </tr>
  );
}

function ModalModificarPartido({
  partido,
  temporadaId,
  fechaCierreJornada,
  partidosDeLaJornada,
  equipos,
  competiciones,
  temporadaCompeticiones,
  vinculosEquipo,
  nombreLocal,
  nombreVisitante,
  onClose,
  onGuardado,
}: {
  partido: Partido;
  temporadaId: number;
  fechaCierreJornada: string | null;
  partidosDeLaJornada: Partido[];
  equipos: Equipo[];
  competiciones: Competicion[];
  temporadaCompeticiones: TemporadaCompeticion[];
  vinculosEquipo: EquipoTemporadaCompeticion[];
  nombreLocal: string;
  nombreVisitante: string;
  onClose: () => void;
  onGuardado: (partido: Partido) => void;
}) {
  const { mostrarError } = useToast();

  // Competiciones vinculadas a la temporada de esta jornada.
  const competicionesDeLaTemporada = competiciones
    .filter((c) => temporadaCompeticiones.some((tc) => tc.temporada_id === temporadaId && tc.competicion_id === c.id))
    .sort((a, b) => a.nombre.localeCompare(b.nombre));

  const temporadaCompeticionInicial = partido.competicion_temporada_id
    ? temporadaCompeticiones.find((tc) => tc.id === partido.competicion_temporada_id)
    : undefined;

  const [competicionId, setCompeticionId] = useState<number | ''>(temporadaCompeticionInicial?.competicion_id ?? '');
  const [equipoLocalId, setEquipoLocalId] = useState<number | ''>(partido.equipo_local_id ?? '');
  const [equipoVisitanteId, setEquipoVisitanteId] = useState<number | ''>(partido.equipo_visitante_id ?? '');
  const [fechaHora, setFechaHora] = useState(isoAInputLocal(partido.fecha_hora));
  const [canal, setCanal] = useState(partido.canal ?? '');
  const [cargando, setCargando] = useState(false);

  const temporadaCompeticionSeleccionada =
    competicionId === '' ? undefined : temporadaCompeticiones.find((tc) => tc.temporada_id === temporadaId && tc.competicion_id === competicionId);

  const equiposDisponibles =
    temporadaCompeticionSeleccionada === undefined
      ? []
      : equipos
          .filter((e) => vinculosEquipo.some((v) => v.equipo_id === e.id && v.temporada_competicion_id === temporadaCompeticionSeleccionada.id))
          .sort((a, b) => a.nombre.localeCompare(b.nombre));

  function handleCambiarCompeticion(valor: string) {
    setCompeticionId(valor === '' ? '' : Number(valor));
    // Al cambiar de competición, la lista de equipos disponibles cambia: se
    // reinician ambos equipos para evitar dejar seleccionado un equipo que
    // ya no pertenece a la competición elegida.
    setEquipoLocalId('');
    setEquipoVisitanteId('');
  }

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();

    const errorValidacion = validarPartidoParaJornada({
      fechaHora: inputLocalAIso(fechaHora),
      equipoLocalId: equipoLocalId === '' ? null : equipoLocalId,
      equipoVisitanteId: equipoVisitanteId === '' ? null : equipoVisitanteId,
      fechaCierreJornada,
      partidosDeLaJornada: partidosDeLaJornada.filter((p) => p.jornada_id === partido.jornada_id),
      partidoActualId: partido.id,
    });

    if (errorValidacion) {
      mostrarError(errorValidacion.mensaje);
      return;
    }

    setCargando(true);
    try {
      const actualizado = await actualizarPartido(partido.id, {
        competicion_temporada_id: temporadaCompeticionSeleccionada?.id ?? null,
        equipo_local_id: equipoLocalId === '' ? null : equipoLocalId,
        equipo_visitante_id: equipoVisitanteId === '' ? null : equipoVisitanteId,
        fecha_hora: inputLocalAIso(fechaHora),
        canal: canal.trim() || null,
      });
      onGuardado(actualizado);
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <Modal
      titulo={`Modificar partido ${partido.orden} — ${nombreLocal} vs ${nombreVisitante}`}
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-modificar-partido" type="submit" cargando={cargando}>
            Guardar
          </Button>
        </>
      }
    >
      <form id="form-modificar-partido" onSubmit={handleSubmit}>
        <Select
          etiqueta="Competición"
          value={competicionId}
          onChange={(evento) => handleCambiarCompeticion(evento.target.value)}
        >
          <option value="">Sin competición</option>
          {competicionesDeLaTemporada.map((c) => (
            <option key={c.id} value={c.id}>
              {c.nombre}
            </option>
          ))}
        </Select>
        <Select
          etiqueta="Equipo local"
          value={equipoLocalId}
          onChange={(evento) => setEquipoLocalId(evento.target.value === '' ? '' : Number(evento.target.value))}
          disabled={competicionId === ''}
          ayuda={competicionId === '' ? 'Selecciona antes una competición.' : undefined}
        >
          <option value="">Por confirmar</option>
          {equiposDisponibles.map((e) => (
            <option key={e.id} value={e.id}>
              {e.nombre}
            </option>
          ))}
        </Select>
        <Select
          etiqueta="Equipo visitante"
          value={equipoVisitanteId}
          onChange={(evento) => setEquipoVisitanteId(evento.target.value === '' ? '' : Number(evento.target.value))}
          disabled={competicionId === ''}
          ayuda={competicionId === '' ? 'Selecciona antes una competición.' : undefined}
        >
          <option value="">Por confirmar</option>
          {equiposDisponibles.map((e) => (
            <option key={e.id} value={e.id}>
              {e.nombre}
            </option>
          ))}
        </Select>
        <Input
          etiqueta="Fecha y hora"
          type="datetime-local"
          value={fechaHora}
          onChange={(evento) => setFechaHora(evento.target.value)}
        />
        <Input
          etiqueta="Canal (opcional)"
          value={canal}
          onChange={(evento) => setCanal(evento.target.value)}
          placeholder="ej. DAZN, Movistar+..."
        />
      </form>
    </Modal>
  );
}

function ModalPremios({
  jornadaId,
  premios,
  onClose,
  onGuardado,
}: {
  jornadaId: number;
  premios: PremioJornada[];
  onClose: () => void;
  onGuardado: (premios: PremioJornada[]) => void;
}) {
  const { mostrarError } = useToast();
  const [valores, setValores] = useState<Record<CategoriaPremio, string>>(() => {
    const iniciales = {} as Record<CategoriaPremio, string>;
    for (const categoria of CATEGORIAS_PREMIO) {
      const existente = premios.find((p) => p.categoria === categoria);
      iniciales[categoria] = existente?.valor != null ? String(existente.valor) : '';
    }
    return iniciales;
  });
  const [cargando, setCargando] = useState(false);

  async function handleSubmit(evento: FormEvent) {
    evento.preventDefault();
    setCargando(true);
    try {
      const resultado: PremioJornada[] = [];
      for (const categoria of CATEGORIAS_PREMIO) {
        const textoValor = valores[categoria].trim();
        const valorNumerico = textoValor === '' ? null : Number(textoValor.replace(',', '.'));
        const existente = premios.find((p) => p.categoria === categoria);
        if (existente) {
          // eslint-disable-next-line no-await-in-loop
          const actualizado = await actualizarPremio(existente.id, valorNumerico);
          resultado.push(actualizado);
        } else if (valorNumerico !== null) {
          // eslint-disable-next-line no-await-in-loop
          const creado = await crearPremio(jornadaId, categoria, valorNumerico);
          resultado.push(creado);
        }
      }
      onGuardado(resultado);
    } catch (err) {
      mostrarError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <Modal
      titulo="Premios de la jornada"
      onClose={onClose}
      acciones={
        <>
          <Button variante="secundario" onClick={onClose}>
            Cancelar
          </Button>
          <Button variante="primario" form="form-premios" type="submit" cargando={cargando}>
            Guardar
          </Button>
        </>
      }
    >
      <form id="form-premios" onSubmit={handleSubmit}>
        {CATEGORIAS_PREMIO.map((categoria) => (
          <Input
            key={categoria}
            etiqueta={ETIQUETA_CATEGORIA[categoria]}
            type="number"
            step="0.01"
            min={0}
            placeholder="0.00"
            value={valores[categoria]}
            onChange={(evento) => setValores((actuales) => ({ ...actuales, [categoria]: evento.target.value }))}
          />
        ))}
      </form>
    </Modal>
  );
}
