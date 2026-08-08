import { useState } from 'react';
import type { ChangeEvent } from 'react';
import { Button } from './Button';
import { Modal } from './Modal';
import { ListaErroresImportacion, ResumenResultadoImportacion } from './ResumenImportacion';
import { Select } from './FormField';
import { crearCompeticion } from '../api/competiciones';
import { crearTemporadaCompeticion, listarTemporadaCompeticiones } from '../api/temporadaCompeticiones';
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
import type { Competicion, Temporada } from '../types/models';

const CAMPOS_COMPETICION: CampoPlantilla[] = [
  { clave: 'nombre', etiqueta: 'Nombre', tipo: 'texto', requerido: true, maxLength: 150 },
  { clave: 'ambito', etiqueta: 'Ámbito', tipo: 'texto', requerido: true, maxLength: 100 },
  { clave: 'es_clubes', etiqueta: 'Es de clubes (true/false)', tipo: 'booleano', requerido: true },
];

const FILAS_EJEMPLO_COMPETICION = [
  { nombre: 'LaLiga EA Sports', ambito: 'Nacional', es_clubes: 'true' },
  { nombre: 'UEFA Champions League', ambito: 'Internacional', es_clubes: 'true' },
];

interface FilaCompeticionValidada {
  numeroFila: number;
  nombre: string;
  ambito: string;
  esClubes: boolean;
  existente: boolean;
}

type Fase = 'seleccion' | 'validado' | 'importando' | 'resultado';

interface Props {
  temporadas: Temporada[];
  competicionesExistentes: Competicion[];
  onClose: () => void;
  onCompletado: () => void;
}

export function ImportarCompeticionesModal({ temporadas, competicionesExistentes, onClose, onCompletado }: Props) {
  const [temporadaId, setTemporadaId] = useState<number>(temporadas[0]?.id ?? 0);
  const [nombreArchivo, setNombreArchivo] = useState<string>('');
  const [fase, setFase] = useState<Fase>('seleccion');
  const [errores, setErrores] = useState<string[]>([]);
  const [filasValidas, setFilasValidas] = useState<FilaCompeticionValidada[]>([]);
  const [resultado, setResultado] = useState<{ creados: number; vinculadosNuevos: number; yaVinculados: number } | null>(null);
  const [procesando, setProcesando] = useState(false);

  function validarFilas(filas: FilaImportacion[]): { errores: string[]; validas: FilaCompeticionValidada[] } {
    const erroresColumnas = validarColumnas(filas, CAMPOS_COMPETICION);
    if (erroresColumnas.length > 0) return { errores: erroresColumnas, validas: [] };

    const listaErrores: string[] = [];
    const validas: FilaCompeticionValidada[] = [];
    const nombresVistos = new Map<string, number>();

    filas.forEach((fila, indice) => {
      const numeroFila = indice + 2;
      const nombre = (fila.nombre ?? '').trim();
      const ambito = (fila.ambito ?? '').trim();
      const esClubes = parsearBooleano(fila.es_clubes);

      if (!nombre) {
        listaErrores.push(`Fila ${numeroFila}: falta el nombre de la competición.`);
      } else if (nombre.length > 150) {
        listaErrores.push(`Fila ${numeroFila}: el nombre supera los 150 caracteres.`);
      }
      if (!ambito) {
        listaErrores.push(`Fila ${numeroFila}: falta el ámbito.`);
      }
      if (esClubes === null) {
        listaErrores.push(`Fila ${numeroFila}: el valor de 'es_clubes' no es válido (usa true/false).`);
      }

      if (nombre) {
        const clave = nombre.toLowerCase();
        if (nombresVistos.has(clave)) {
          listaErrores.push(`Nombre duplicado en el archivo: "${nombre}" (filas ${nombresVistos.get(clave)} y ${numeroFila}).`);
        } else {
          nombresVistos.set(clave, numeroFila);
        }
      }

      if (nombre && ambito && esClubes !== null) {
        const existente = competicionesExistentes.some((c) => c.nombre.toLowerCase() === nombre.toLowerCase());
        validas.push({ numeroFila, nombre, ambito, esClubes, existente });
      }
    });

    return { errores: listaErrores, validas };
  }

  async function handleArchivo(evento: ChangeEvent<HTMLInputElement>) {
    const archivo = evento.target.files?.[0];
    if (!archivo) return;
    setNombreArchivo(archivo.name);
    setResultado(null);
    try {
      const texto = await leerArchivoComoTexto(archivo);
      const esJson = archivo.name.toLowerCase().endsWith('.json');
      const filas = esJson ? jsonAFilas(texto) : filasCSVAObjetos(parsearCSV(texto));
      const { errores: erroresValidacion, validas } = validarFilas(filas);
      setErrores(erroresValidacion);
      setFilasValidas(validas);
      setFase('validado');
    } catch (err) {
      setErrores([extraerMensajeError(err).message]);
      setFilasValidas([]);
      setFase('validado');
    }
    evento.target.value = '';
  }

  function handleDescargarPlantilla(formato: 'csv' | 'json') {
    if (formato === 'csv') {
      descargarArchivo(
        'plantilla-competiciones.csv',
        generarPlantillaCSV(CAMPOS_COMPETICION, FILAS_EJEMPLO_COMPETICION),
        'text/csv;charset=utf-8',
      );
    } else {
      descargarArchivo(
        'plantilla-competiciones.json',
        generarPlantillaJSON(FILAS_EJEMPLO_COMPETICION.map((f) => ({ ...f, es_clubes: f.es_clubes === 'true' }))),
        'application/json',
      );
    }
  }

  async function handleConfirmarImportacion() {
    if (filasValidas.length === 0 || !temporadaId) return;
    setProcesando(true);
    setFase('importando');
    try {
      const temporadaCompeticionesExistentes = await listarTemporadaCompeticiones();
      const paresYaVinculados = new Set(
        temporadaCompeticionesExistentes.filter((tc) => tc.temporada_id === temporadaId).map((tc) => tc.competicion_id),
      );

      let competicionesConocidas = [...competicionesExistentes];
      let creados = 0;
      let vinculadosNuevos = 0;
      let yaVinculados = 0;
      const erroresEjecucion: string[] = [];

      for (const fila of filasValidas) {
        try {
          let competicion = competicionesConocidas.find((c) => c.nombre.toLowerCase() === fila.nombre.toLowerCase());
          if (!competicion) {
            // eslint-disable-next-line no-await-in-loop
            competicion = await crearCompeticion({ nombre: fila.nombre, ambito: fila.ambito, es_clubes: fila.esClubes });
            competicionesConocidas = [...competicionesConocidas, competicion];
            creados += 1;
          }

          if (paresYaVinculados.has(competicion.id)) {
            yaVinculados += 1;
          } else {
            // eslint-disable-next-line no-await-in-loop
            await crearTemporadaCompeticion(temporadaId, competicion.id);
            paresYaVinculados.add(competicion.id);
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

  const puedeImportar = filasValidas.length > 0 && errores.length === 0 && temporadaId > 0;
  const faltanDatosBase = temporadas.length === 0;

  if (faltanDatosBase) {
    return (
      <Modal titulo="Importación masiva de competiciones" onClose={onClose} ancho={480}>
        <p>
          Antes de importar competiciones necesitas tener al menos una <strong>temporada</strong> creada, para poder
          vincular las competiciones importadas a ella.
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
    <Modal titulo="Importación masiva de competiciones" onClose={onClose} ancho={560}>
      <div className="campo">
        <span className="campo__etiqueta">1. Vincular a temporada</span>
        <Select value={temporadaId} onChange={(e) => setTemporadaId(Number(e.target.value))}>
          {temporadas.map((t) => (
            <option key={t.id} value={t.id}>
              {t.nombre}
            </option>
          ))}
        </Select>
        <span className="campo__ayuda">Todas las competiciones importadas quedarán vinculadas a esta temporada.</span>
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
                <strong>{filasValidas.filter((f) => !f.existente).length}</strong> competiciones nuevas y{' '}
                <strong>{filasValidas.filter((f) => f.existente).length}</strong> ya existentes (se reutilizarán y se
                vincularán a esta temporada).
              </p>
            </div>
          ) : null}
          {resultado ? (
            <ResumenResultadoImportacion
              creados={resultado.creados}
              vinculadosNuevos={resultado.vinculadosNuevos}
              yaVinculados={resultado.yaVinculados}
              entidadPlural="competiciones"
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
