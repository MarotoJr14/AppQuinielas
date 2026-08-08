import { useEffect, useState } from 'react';
import type { ChangeEvent } from 'react';
import { Button } from './Button';
import { Modal } from './Modal';
import { ListaErroresImportacion, ResumenResultadoImportacion } from './ResumenImportacion';
import { Select } from './FormField';
import { crearEquipo } from '../api/equipos';
import { listarEquipoTemporadaCompeticiones, vincularEquipoATemporadaCompeticion } from '../api/equipoTemporadaCompeticiones';
import { listarTemporadaCompeticiones, obtenerOCrearTemporadaCompeticion } from '../api/temporadaCompeticiones';
import { extraerMensajeError } from '../api/client';
import {
  descargarArchivo,
  filasCSVAObjetos,
  generarPlantillaCSV,
  generarPlantillaJSON,
  jsonAFilas,
  leerArchivoComoTexto,
  parsearBooleano,
  parsearCSV,
  validarColumnas,
  type CampoPlantilla,
  type FilaImportacion,
} from '../utils/importacion';
import type { Competicion, Equipo, Temporada } from '../types/models';

const CAMPOS_EQUIPO: CampoPlantilla[] = [
  { clave: 'nombre', etiqueta: 'Nombre', tipo: 'texto', requerido: true, maxLength: 150 },
  { clave: 'pais', etiqueta: 'País', tipo: 'texto', requerido: true, maxLength: 100 },
  { clave: 'es_club', etiqueta: 'Es club (true/false)', tipo: 'booleano', requerido: true },
];

const FILAS_EJEMPLO_EQUIPO = [
  { nombre: 'Real Madrid', pais: 'España', es_club: 'true' },
  { nombre: 'Athletic Club', pais: 'España', es_club: 'true' },
];

interface FilaEquipoValidada {
  numeroFila: number;
  nombre: string;
  pais: string;
  esClub: boolean;
  existente: boolean;
}

type Fase = 'seleccion' | 'validado' | 'importando' | 'resultado';

interface Props {
  temporadas: Temporada[];
  competiciones: Competicion[];
  equiposExistentes: Equipo[];
  onClose: () => void;
  onCompletado: () => void;
}

export function ImportarEquiposModal({ temporadas, competiciones, equiposExistentes, onClose, onCompletado }: Props) {
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [competicionId, setCompeticionId] = useState<number>(competiciones[0]?.id ?? 0);
  const [nombreArchivo, setNombreArchivo] = useState<string>('');
  const [filasCrudas, setFilasCrudas] = useState<FilaImportacion[] | null>(null);
  const [fase, setFase] = useState<Fase>('seleccion');
  const [errores, setErrores] = useState<string[]>([]);
  const [filasValidas, setFilasValidas] = useState<FilaEquipoValidada[]>([]);
  const [resultado, setResultado] = useState<{ creados: number; vinculadosNuevos: number; yaVinculados: number } | null>(null);
  const [procesando, setProcesando] = useState(false);

  const competicionSeleccionada = competiciones.find((c) => c.id === competicionId) ?? null;

  function validarFilas(filas: FilaImportacion[]): { errores: string[]; validas: FilaEquipoValidada[] } {
    const erroresColumnas = validarColumnas(filas, CAMPOS_EQUIPO);
    if (erroresColumnas.length > 0) return { errores: erroresColumnas, validas: [] };

    const listaErrores: string[] = [];
    const validas: FilaEquipoValidada[] = [];
    const nombresVistos = new Map<string, number>();

    filas.forEach((fila, indice) => {
      const numeroFila = indice + 2; // +1 por índice base 0, +1 por la cabecera
      const nombre = (fila.nombre ?? '').trim();
      const pais = (fila.pais ?? '').trim();
      const esClub = parsearBooleano(fila.es_club);

      if (!nombre) {
        listaErrores.push(`Fila ${numeroFila}: falta el nombre del equipo.`);
      } else if (nombre.length > 150) {
        listaErrores.push(`Fila ${numeroFila}: el nombre supera los 150 caracteres.`);
      }
      if (!pais) {
        listaErrores.push(`Fila ${numeroFila}: falta el país.`);
      }
      if (esClub === null) {
        listaErrores.push(`Fila ${numeroFila}: el valor de 'es_club' no es válido (usa true/false).`);
      } else if (competicionSeleccionada && esClub !== competicionSeleccionada.es_clubes) {
        listaErrores.push(
          `Fila ${numeroFila}: "${nombre || 'equipo'}" es de tipo '${esClub ? 'Club' : 'Selección'}', pero la competición ` +
            `seleccionada ("${competicionSeleccionada.nombre}") es de tipo '${
              competicionSeleccionada.es_clubes ? 'Clubes' : 'Selecciones'
            }'.`,
        );
      }

      if (nombre) {
        const clave = nombre.toLowerCase();
        if (nombresVistos.has(clave)) {
          listaErrores.push(`Nombre duplicado en el archivo: "${nombre}" (filas ${nombresVistos.get(clave)} y ${numeroFila}).`);
        } else {
          nombresVistos.set(clave, numeroFila);
        }
      }

      if (nombre && pais && esClub !== null && (!competicionSeleccionada || esClub === competicionSeleccionada.es_clubes)) {
        const existente = equiposExistentes.some((e) => e.nombre.toLowerCase() === nombre.toLowerCase());
        validas.push({ numeroFila, nombre, pais, esClub, existente });
      }
    });

    return { errores: listaErrores, validas };
  }

  // Si el usuario cambia la competición seleccionada después de adjuntar el
  // archivo, se revalida automáticamente contra la nueva competición (el
  // tipo club/selección debe coincidir).
  useEffect(() => {
    if (filasCrudas === null) return;
    const { errores: erroresValidacion, validas } = validarFilas(filasCrudas);
    setErrores(erroresValidacion);
    setFilasValidas(validas);
    setResultado(null);
    setFase('validado');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filasCrudas, competicionId]);

  async function handleArchivo(evento: ChangeEvent<HTMLInputElement>) {
    const archivo = evento.target.files?.[0];
    if (!archivo) return;
    setNombreArchivo(archivo.name);
    setResultado(null);
    try {
      const texto = await leerArchivoComoTexto(archivo);
      const esJson = archivo.name.toLowerCase().endsWith('.json');
      const filas = esJson ? jsonAFilas(texto) : filasCSVAObjetos(parsearCSV(texto));
      setFilasCrudas(filas);
    } catch (err) {
      setFilasCrudas(null);
      setErrores([extraerMensajeError(err).message]);
      setFilasValidas([]);
      setFase('validado');
    }
    evento.target.value = '';
  }

  function handleDescargarPlantilla(formato: 'csv' | 'json') {
    if (formato === 'csv') {
      descargarArchivo('plantilla-equipos.csv', generarPlantillaCSV(CAMPOS_EQUIPO, FILAS_EJEMPLO_EQUIPO), 'text/csv;charset=utf-8');
    } else {
      descargarArchivo(
        'plantilla-equipos.json',
        generarPlantillaJSON(FILAS_EJEMPLO_EQUIPO.map((f) => ({ ...f, es_club: f.es_club === 'true' }))),
        'application/json',
      );
    }
  }

  async function handleConfirmarImportacion() {
    if (filasValidas.length === 0 || !temporadaId || !competicionId) return;
    setProcesando(true);
    setFase('importando');
    try {
      const temporadaCompeticionesExistentes = await listarTemporadaCompeticiones();
      const temporadaCompeticion = await obtenerOCrearTemporadaCompeticion(temporadaCompeticionesExistentes, temporadaId, competicionId);

      const vinculosExistentes = await listarEquipoTemporadaCompeticiones();
      const equipoIdsYaVinculados = new Set(
        vinculosExistentes.filter((v) => v.temporada_competicion_id === temporadaCompeticion.id).map((v) => v.equipo_id),
      );

      let equiposConocidos = [...equiposExistentes];
      let creados = 0;
      let vinculadosNuevos = 0;
      let yaVinculados = 0;
      const erroresEjecucion: string[] = [];

      for (const fila of filasValidas) {
        try {
          let equipo = equiposConocidos.find((e) => e.nombre.toLowerCase() === fila.nombre.toLowerCase());
          if (!equipo) {
            // eslint-disable-next-line no-await-in-loop
            equipo = await crearEquipo({ nombre: fila.nombre, pais: fila.pais, es_club: fila.esClub });
            equiposConocidos = [...equiposConocidos, equipo];
            creados += 1;
          }

          if (equipoIdsYaVinculados.has(equipo.id)) {
            yaVinculados += 1;
          } else {
            // eslint-disable-next-line no-await-in-loop
            await vincularEquipoATemporadaCompeticion(equipo.id, temporadaCompeticion.id);
            equipoIdsYaVinculados.add(equipo.id);
            vinculadosNuevos += 1;
          }
        } catch (err) {
          erroresEjecucion.push(`Fila ${fila.numeroFila} ("${fila.nombre}"): ${extraerMensajeError(err).message}`);
        }
      }

      if (erroresEjecucion.length > 0) {
        setErrores(erroresEjecucion);
      }
      setResultado({ creados, vinculadosNuevos, yaVinculados });
      setFase('resultado');
      onCompletado();
    } catch (err) {
      setErrores([extraerMensajeError(err).message]);
      setFase('validado');
    } finally {
      setProcesando(false);
    }
  }

  const puedeImportar = filasValidas.length > 0 && errores.length === 0 && temporadaId > 0 && competicionId > 0;
  const faltanDatosBase = temporadas.length === 0 || competiciones.length === 0;

  if (faltanDatosBase) {
    return (
      <Modal titulo="Importación masiva de equipos" onClose={onClose} ancho={480}>
        <p>
          Antes de importar equipos necesitas tener al menos una <strong>temporada</strong> y una{' '}
          <strong>competición</strong> creadas, para poder vincular los equipos importados a una edición concreta.
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
    <Modal titulo="Importación masiva de equipos" onClose={onClose} ancho={560}>
      <div className="campo">
        <span className="campo__etiqueta">1. Vincular a temporada y competición</span>
        <div className="grid-dos-columnas">
          <Select value={temporadaId} onChange={(e) => setTemporadaId(Number(e.target.value))}>
            {temporadas.map((t) => (
              <option key={t.id} value={t.id}>
                {t.nombre}
              </option>
            ))}
          </Select>
          <Select value={competicionId} onChange={(e) => setCompeticionId(Number(e.target.value))}>
            {competiciones.map((c) => (
              <option key={c.id} value={c.id}>
                {c.nombre}
              </option>
            ))}
          </Select>
        </div>
        <span className="campo__ayuda">
          Todos los equipos importados quedarán vinculados a esta edición de la competición. El tipo de cada equipo
          (club/selección) debe coincidir con el tipo de la competición
          {competicionSeleccionada ? ` (actualmente: ${competicionSeleccionada.es_clubes ? 'Clubes' : 'Selecciones'})` : ''}.
        </span>
      </div>

      <div className="campo">
        <span className="campo__etiqueta">2. Descargar plantilla</span>
        <div className="fila-acciones">
          <Button variante="secundario" chico onClick={() => handleDescargarPlantilla('csv')}>
            ⬇ Plantilla CSV
          </Button>
          <Button variante="secundario" chico onClick={() => handleDescargarPlantilla('json')}>
            ⬇ Plantilla JSON
          </Button>
        </div>
      </div>

      <div className="campo">
        <span className="campo__etiqueta">3. Adjuntar archivo relleno (.csv o .json)</span>
        <input type="file" accept=".csv,.json,application/json,text/csv" className="input" onChange={handleArchivo} />
        {nombreArchivo ? <span className="campo__ayuda">Archivo seleccionado: {nombreArchivo}</span> : null}
      </div>

      {fase === 'validado' || fase === 'resultado' ? (
        <>
          <ListaErroresImportacion errores={errores} />
          {errores.length === 0 && filasValidas.length > 0 && fase === 'validado' ? (
            <div className="tarjeta" style={{ background: 'var(--color-superficie-alt)', marginBottom: 16 }}>
              <p>
                Se han validado <strong>{filasValidas.length}</strong> filas correctamente:{' '}
                <strong>{filasValidas.filter((f) => !f.existente).length}</strong> equipos nuevos y{' '}
                <strong>{filasValidas.filter((f) => f.existente).length}</strong> ya existentes (se reutilizarán y se
                vincularán a esta edición).
              </p>
            </div>
          ) : null}
          {resultado ? (
            <ResumenResultadoImportacion
              creados={resultado.creados}
              vinculadosNuevos={resultado.vinculadosNuevos}
              yaVinculados={resultado.yaVinculados}
              entidadPlural="equipos"
            />
          ) : null}
        </>
      ) : null}

      <div className="modal__acciones">
        <Button variante="secundario" onClick={onClose}>
          {fase === 'resultado' ? 'Cerrar' : 'Cancelar'}
        </Button>
        {fase !== 'resultado' ? (
          <Button variante="primario" onClick={handleConfirmarImportacion} disabled={!puedeImportar} cargando={procesando}>
            Confirmar e importar
          </Button>
        ) : null}
      </div>
    </Modal>
  );
}
