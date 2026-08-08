import { useEffect, useState } from 'react';
import type { ChangeEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from './Button';
import { Modal } from './Modal';
import { ListaErroresImportacion } from './ResumenImportacion';
import { Select } from './FormField';
import { extraerMensajeError } from '../api/client';
import { listarCompeticiones } from '../api/competiciones';
import { listarEquipoTemporadaCompeticiones } from '../api/equipoTemporadaCompeticiones';
import { listarEquipos } from '../api/equipos';
import { crearJornada } from '../api/jornadas';
import { crearPartido } from '../api/partidos';
import { listarTemporadaCompeticiones } from '../api/temporadaCompeticiones';
import { descargarArchivo, leerArchivoComoTexto } from '../utils/importacion';
import type { Competicion, Equipo, EquipoTemporadaCompeticion, Jornada, Temporada, TemporadaCompeticion } from '../types/models';

interface PartidoValidado {
  orden: number;
  temporadaCompeticionId: number;
  fechaHoraIso: string | null;
  canal: string | null;
  equipoLocalId: number;
  equipoVisitanteId: number;
}

const PLANTILLA_JORNADA = {
  nombre: 'J1',
  fecha_cierre: '2026-08-15T21:00:00',
  partidos: [
    { orden: 1, competicion: 'LaLiga EA Sports', equipo_local: 'Girona', equipo_visitante: 'Rayo Vallecano', fecha_hora: '2026-08-15T19:00:00', canal: 'DAZN' },
    { orden: 2, competicion: 'LaLiga EA Sports', equipo_local: 'Villarreal', equipo_visitante: 'R. Oviedo', fecha_hora: '2026-08-15T21:30:00', canal: null },
    { orden: 3, competicion: 'LaLiga EA Sports', equipo_local: 'Alavés', equipo_visitante: 'Levante', fecha_hora: '2026-08-16T21:30:00', canal: null },
    { orden: 4, competicion: 'LaLiga EA Sports', equipo_local: 'Mallorca', equipo_visitante: 'Barcelona', fecha_hora: '2026-08-16T19:30:00', canal: null },
    { orden: 5, competicion: 'LaLiga EA Sports', equipo_local: 'Valencia', equipo_visitante: 'Real Sociedad', fecha_hora: '2026-08-16T21:30:00', canal: null },
    { orden: 6, competicion: 'LaLiga EA Sports', equipo_local: 'Celta', equipo_visitante: 'Getafe', fecha_hora: '2026-08-17T17:00:00', canal: null },
    { orden: 7, competicion: 'LaLiga EA Sports', equipo_local: 'Athletic Club', equipo_visitante: 'Sevilla', fecha_hora: '2026-08-17T19:30:00', canal: null },
    { orden: 8, competicion: 'LaLiga EA Sports', equipo_local: 'Espanyol', equipo_visitante: 'At. Madrid', fecha_hora: '2026-08-17T21:30:00', canal: null },
    { orden: 9, competicion: 'LaLiga Hypermotion', equipo_local: 'Racing Santander', equipo_visitante: 'Castellón', fecha_hora: '2026-08-16T17:00:00', canal: null },
    { orden: 10, competicion: 'LaLiga Hypermotion', equipo_local: 'Málaga', equipo_visitante: 'Eibar', fecha_hora: '2026-08-16T19:30:00', canal: null },
    { orden: 11, competicion: 'LaLiga Hypermotion', equipo_local: 'Granada', equipo_visitante: 'Deportivo', fecha_hora: '2026-08-16T21:30:00', canal: null },
    { orden: 12, competicion: 'LaLiga Hypermotion', equipo_local: 'Cádiz', equipo_visitante: 'Mirandés', fecha_hora: '2026-08-17T19:30:00', canal: null },
    { orden: 13, competicion: 'LaLiga Hypermotion', equipo_local: 'Huesca', equipo_visitante: 'Leganés', fecha_hora: '2026-08-17T19:30:00', canal: null },
    { orden: 14, competicion: 'LaLiga Hypermotion', equipo_local: 'Las Palmas', equipo_visitante: 'Andorra', fecha_hora: '2026-08-17T21:30:00', canal: null },
    { orden: 15, competicion: 'LaLiga EA Sports', equipo_local: 'Elche', equipo_visitante: 'Betis', fecha_hora: '2026-08-18T21:00:00', canal: null },
  ],
};

interface JornadaValidada {
  nombre: string;
  fechaCierre: string;
  partidos: PartidoValidado[];
}

type Fase = 'seleccion' | 'validado' | 'importando' | 'resultado';

interface Props {
  temporadas: Temporada[];
  jornadas: Jornada[];
  onClose: () => void;
  onCompletado: () => void;
}

interface DatosCatalogo {
  equipos: Equipo[];
  competiciones: Competicion[];
  temporadaCompeticiones: TemporadaCompeticion[];
  vinculosEquipo: EquipoTemporadaCompeticion[];
}

export function ImportarJornadaModal({ temporadas, jornadas, onClose, onCompletado }: Props) {
  const navigate = useNavigate();
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [catalogo, setCatalogo] = useState<DatosCatalogo | null>(null);
  const [cargandoCatalogo, setCargandoCatalogo] = useState(true);
  const [nombreArchivo, setNombreArchivo] = useState('');
  const [fase, setFase] = useState<Fase>('seleccion');
  const [errores, setErrores] = useState<string[]>([]);
  const [jornadaValidada, setJornadaValidada] = useState<JornadaValidada | null>(null);
  const [procesando, setProcesando] = useState(false);

  useEffect(() => {
    Promise.all([listarEquipos(), listarCompeticiones(), listarTemporadaCompeticiones(), listarEquipoTemporadaCompeticiones()])
      .then(([equipos, competiciones, temporadaCompeticiones, vinculosEquipo]) => {
        setCatalogo({ equipos, competiciones, temporadaCompeticiones, vinculosEquipo });
      })
      .catch(() => setCatalogo({ equipos: [], competiciones: [], temporadaCompeticiones: [], vinculosEquipo: [] }))
      .finally(() => setCargandoCatalogo(false));
  }, []);

  function validarJornada(datos: unknown): { errores: string[]; validada: JornadaValidada | null } {
    if (!catalogo) return { errores: ['Todavía se están cargando los datos necesarios, inténtalo de nuevo en un momento.'], validada: null };
    const { equipos, competiciones, temporadaCompeticiones, vinculosEquipo } = catalogo;

    const listaErrores: string[] = [];

    if (typeof datos !== 'object' || datos === null || Array.isArray(datos)) {
      return { errores: ['El JSON debe ser un único objeto con los datos de la jornada (no una lista).'], validada: null };
    }
    const objeto = datos as Record<string, unknown>;

    const nombre = typeof objeto.nombre === 'string' ? objeto.nombre.trim() : '';
    if (!nombre) listaErrores.push('Falta el nombre de la jornada.');

    if (nombre && jornadas.some((j) => j.temporada_id === temporadaId && j.nombre.toLowerCase() === nombre.toLowerCase())) {
      listaErrores.push(`Ya existe una jornada llamada "${nombre}" en la temporada seleccionada.`);
    }

    let fechaCierre = '';
    let fechaCierreDate: Date | null = null;
    if (typeof objeto.fecha_cierre !== 'string' || objeto.fecha_cierre.trim() === '') {
      listaErrores.push('Falta la fecha de cierre de la jornada.');
    } else {
      const fecha = new Date(objeto.fecha_cierre);
      if (Number.isNaN(fecha.getTime())) {
        listaErrores.push(`La fecha de cierre "${objeto.fecha_cierre}" no es una fecha válida.`);
      } else {
        fechaCierre = fecha.toISOString();
        fechaCierreDate = fecha;
      }
    }

    if (!Array.isArray(objeto.partidos)) {
      listaErrores.push('Falta la lista "partidos".');
      return { errores: listaErrores, validada: null };
    }
    if (objeto.partidos.length !== 15) {
      listaErrores.push(`La jornada debe tener exactamente 15 partidos (14 + Pleno al 15); se han encontrado ${objeto.partidos.length}.`);
    }

    const ordenesVistos = new Set<number>();
    const partidosValidados: PartidoValidado[] = [];
    const equipoOrdenes = new Map<number, number[]>(); // equipo_id -> lista de órdenes donde aparece

    (objeto.partidos as unknown[]).forEach((item, indice) => {
      if (typeof item !== 'object' || item === null) {
        listaErrores.push(`Partido en la posición ${indice + 1}: debe ser un objeto.`);
        return;
      }
      const partido = item as Record<string, unknown>;
      const orden = typeof partido.orden === 'number' ? partido.orden : Number(partido.orden);
      if (!Number.isInteger(orden) || orden < 1 || orden > 15) {
        listaErrores.push(`Partido en la posición ${indice + 1}: "orden" debe ser un número entero entre 1 y 15.`);
        return;
      }
      if (ordenesVistos.has(orden)) {
        listaErrores.push(`El orden ${orden} está repetido en varios partidos.`);
      }
      ordenesVistos.add(orden);

      // --- Competición del partido ---
      const competicionNombre = typeof partido.competicion === 'string' ? partido.competicion.trim() : '';
      if (!competicionNombre) listaErrores.push(`Partido ${orden}: falta "competicion".`);
      const competicion = competicionNombre
        ? competiciones.find((c) => c.nombre.toLowerCase() === competicionNombre.toLowerCase())
        : undefined;
      if (competicionNombre && !competicion) {
        listaErrores.push(`Partido ${orden}: no se encuentra la competición "${competicionNombre}".`);
      }

      let temporadaCompeticion: TemporadaCompeticion | undefined;
      if (competicion) {
        temporadaCompeticion = temporadaCompeticiones.find(
          (tc) => tc.temporada_id === temporadaId && tc.competicion_id === competicion.id,
        );
        if (!temporadaCompeticion) {
          listaErrores.push(
            `Partido ${orden}: la competición "${competicion.nombre}" no está vinculada a la temporada seleccionada.`,
          );
        }
      }

      // --- Equipos del partido ---
      const equipoLocalNombre = typeof partido.equipo_local === 'string' ? partido.equipo_local.trim() : '';
      const equipoVisitanteNombre = typeof partido.equipo_visitante === 'string' ? partido.equipo_visitante.trim() : '';
      if (!equipoLocalNombre) listaErrores.push(`Partido ${orden}: falta "equipo_local".`);
      if (!equipoVisitanteNombre) listaErrores.push(`Partido ${orden}: falta "equipo_visitante".`);

      const equipoLocal = equipoLocalNombre
        ? equipos.find((e) => e.nombre.toLowerCase() === equipoLocalNombre.toLowerCase())
        : undefined;
      const equipoVisitante = equipoVisitanteNombre
        ? equipos.find((e) => e.nombre.toLowerCase() === equipoVisitanteNombre.toLowerCase())
        : undefined;
      if (equipoLocalNombre && !equipoLocal) listaErrores.push(`Partido ${orden}: no se encuentra el equipo "${equipoLocalNombre}".`);
      if (equipoVisitanteNombre && !equipoVisitante) {
        listaErrores.push(`Partido ${orden}: no se encuentra el equipo "${equipoVisitanteNombre}".`);
      }

      if (temporadaCompeticion && equipoLocal) {
        const vinculado = vinculosEquipo.some(
          (v) => v.temporada_competicion_id === temporadaCompeticion!.id && v.equipo_id === equipoLocal.id,
        );
        if (!vinculado) {
          listaErrores.push(
            `Partido ${orden}: el equipo "${equipoLocal.nombre}" no pertenece a "${competicion!.nombre}" en la temporada seleccionada.`,
          );
        }
      }
      if (temporadaCompeticion && equipoVisitante) {
        const vinculado = vinculosEquipo.some(
          (v) => v.temporada_competicion_id === temporadaCompeticion!.id && v.equipo_id === equipoVisitante.id,
        );
        if (!vinculado) {
          listaErrores.push(
            `Partido ${orden}: el equipo "${equipoVisitante.nombre}" no pertenece a "${competicion!.nombre}" en la temporada seleccionada.`,
          );
        }
      }

      // --- Fecha y hora del partido ---
      let fechaHoraIso: string | null = null;
      if (partido.fecha_hora !== null && partido.fecha_hora !== undefined && partido.fecha_hora !== '') {
        if (typeof partido.fecha_hora !== 'string') {
          listaErrores.push(`Partido ${orden}: "fecha_hora" debe ser un texto ISO o null.`);
        } else {
          const fecha = new Date(partido.fecha_hora);
          if (Number.isNaN(fecha.getTime())) {
            listaErrores.push(`Partido ${orden}: "fecha_hora" no es una fecha válida.`);
          } else {
            fechaHoraIso = fecha.toISOString();
            if (fechaCierreDate && fecha.getTime() < fechaCierreDate.getTime()) {
              listaErrores.push(`Partido ${orden}: la fecha y hora del partido no puede ser anterior al cierre de la jornada.`);
            }
          }
        }
      }

      const canal = typeof partido.canal === 'string' && partido.canal.trim() !== '' ? partido.canal.trim() : null;

      if (equipoLocal) equipoOrdenes.set(equipoLocal.id, [...(equipoOrdenes.get(equipoLocal.id) ?? []), orden]);
      if (equipoVisitante) equipoOrdenes.set(equipoVisitante.id, [...(equipoOrdenes.get(equipoVisitante.id) ?? []), orden]);

      if (equipoLocal && equipoVisitante && temporadaCompeticion) {
        partidosValidados.push({
          orden,
          temporadaCompeticionId: temporadaCompeticion.id,
          fechaHoraIso,
          canal,
          equipoLocalId: equipoLocal.id,
          equipoVisitanteId: equipoVisitante.id,
        });
      }
    });

    if (ordenesVistos.size === 15 && !Array.from({ length: 15 }, (_, i) => i + 1).every((n) => ordenesVistos.has(n))) {
      listaErrores.push('Los 15 partidos deben tener "orden" del 1 al 15 sin huecos.');
    }

    // Un mismo equipo no puede aparecer más de una vez en toda la jornada.
    for (const [equipoId, ordenes] of equipoOrdenes.entries()) {
      if (ordenes.length > 1) {
        const nombreEquipo = equipos.find((e) => e.id === equipoId)?.nombre ?? `#${equipoId}`;
        listaErrores.push(`El equipo "${nombreEquipo}" aparece más de una vez en la jornada (partidos ${ordenes.join(', ')}).`);
      }
    }

    if (listaErrores.length > 0 || !nombre || !fechaCierre) {
      return { errores: listaErrores, validada: null };
    }

    return {
      errores: [],
      validada: { nombre, fechaCierre, partidos: partidosValidados.sort((a, b) => a.orden - b.orden) },
    };
  }

  async function handleArchivo(evento: ChangeEvent<HTMLInputElement>) {
    const archivo = evento.target.files?.[0];
    if (!archivo) return;
    setNombreArchivo(archivo.name);
    try {
      const texto = await leerArchivoComoTexto(archivo);
      let datos: unknown;
      try {
        datos = JSON.parse(texto);
      } catch {
        throw new Error('El archivo no contiene un JSON válido.');
      }
      const { errores: erroresValidacion, validada } = validarJornada(datos);
      setErrores(erroresValidacion);
      setJornadaValidada(validada);
      setFase('validado');
    } catch (err) {
      setErrores([extraerMensajeError(err).message]);
      setJornadaValidada(null);
      setFase('validado');
    }
    evento.target.value = '';
  }

  function handleDescargarPlantilla() {
    descargarArchivo('plantilla-jornada.json', JSON.stringify(PLANTILLA_JORNADA, null, 2), 'application/json');
  }

  async function handleConfirmarImportacion() {
    if (!jornadaValidada || !temporadaId) return;
    setProcesando(true);
    setFase('importando');
    try {
      const jornada = await crearJornada({
        temporada_id: temporadaId,
        nombre: jornadaValidada.nombre,
        fecha_cierre: jornadaValidada.fechaCierre,
      });

      const erroresPartidos: string[] = [];
      for (const partido of jornadaValidada.partidos) {
        try {
          // eslint-disable-next-line no-await-in-loop
          await crearPartido({
            jornada_id: jornada.id,
            orden: partido.orden,
            competicion_temporada_id: partido.temporadaCompeticionId,
            fecha_hora: partido.fechaHoraIso,
            canal: partido.canal,
            equipo_local_id: partido.equipoLocalId,
            equipo_visitante_id: partido.equipoVisitanteId,
          });
        } catch (err) {
          erroresPartidos.push(`Partido ${partido.orden}: ${extraerMensajeError(err).message}`);
        }
      }

      if (erroresPartidos.length > 0) {
        setErrores(erroresPartidos);
        setFase('validado');
        return;
      }

      onCompletado();
      onClose();
      navigate(`/jornadas/${jornada.id}`);
    } catch (err) {
      setErrores([extraerMensajeError(err).message]);
      setFase('validado');
    } finally {
      setProcesando(false);
    }
  }

  const puedeImportar = jornadaValidada !== null && errores.length === 0 && temporadaId > 0;

  if (temporadas.length === 0) {
    return (
      <Modal titulo="Importar jornada" onClose={onClose} ancho={480}>
        <p>
          Antes de importar una jornada necesitas tener al menos una <strong>temporada</strong> creada.
        </p>
        <div className="modal__acciones">
          <Button variante="secundario" onClick={onClose}>
            Cerrar
          </Button>
        </div>
      </Modal>
    );
  }

  return (
    <Modal titulo="Importar jornada" onClose={onClose} ancho={620}>
      <div className="campo">
        <span className="campo__etiqueta">1. Vincular a temporada</span>
        <Select value={temporadaId} onChange={(e) => setTemporadaId(Number(e.target.value))}>
          {temporadas.map((t) => (
            <option key={t.id} value={t.id}>
              {t.nombre}
            </option>
          ))}
        </Select>
        <span className="campo__ayuda">La jornada importada quedará vinculada a esta temporada.</span>
      </div>

      <div className="campo">
        <span className="campo__etiqueta">2. Descargar plantilla (solo JSON)</span>
        <div className="fila-acciones">
          <Button variante="secundario" chico onClick={handleDescargarPlantilla}>
            ⬇ Plantilla JSON
          </Button>
        </div>
        <span className="campo__ayuda">
          Cada partido debe indicar su "competicion" (debe estar vinculada a la temporada elegida), y los nombres de
          "equipo_local"/"equipo_visitante" deben pertenecer a esa competición en esa temporada.
        </span>
      </div>

      <div className="campo">
        <span className="campo__etiqueta">3. Adjuntar archivo relleno (.json)</span>
        <input
          type="file"
          accept=".json,application/json"
          className="input"
          onChange={handleArchivo}
          disabled={cargandoCatalogo}
        />
        {cargandoCatalogo ? <span className="campo__ayuda">Cargando equipos y competiciones disponibles...</span> : null}
        {nombreArchivo ? <span className="campo__ayuda">Archivo seleccionado: {nombreArchivo}</span> : null}
      </div>

      {fase === 'validado' ? (
        <>
          <ListaErroresImportacion errores={errores} />
          {errores.length === 0 && jornadaValidada ? (
            <div className="tarjeta" style={{ background: 'var(--color-superficie-alt)', marginBottom: 16 }}>
              <p>
                Se ha validado correctamente la jornada <strong>{jornadaValidada.nombre}</strong> con sus{' '}
                <strong>{jornadaValidada.partidos.length}</strong> partidos.
              </p>
            </div>
          ) : null}
        </>
      ) : null}

      <div className="modal__acciones">
        <Button variante="secundario" onClick={onClose}>
          Cancelar
        </Button>
        <Button variante="primario" onClick={handleConfirmarImportacion} disabled={!puedeImportar} cargando={procesando}>
          Confirmar e importar
        </Button>
      </div>
    </Modal>
  );
}
