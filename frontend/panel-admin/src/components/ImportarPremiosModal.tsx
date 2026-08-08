import { useState } from 'react';
import type { ChangeEvent } from 'react';
import { Button } from './Button';
import { Modal } from './Modal';
import { ListaErroresImportacion } from './ResumenImportacion';
import { extraerMensajeError } from '../api/client';
import { actualizarPremio, crearPremio } from '../api/jornadas';
import {
  descargarArchivo,
  filasCSVAObjetos,
  generarPlantillaCSV,
  generarPlantillaJSON,
  jsonAFilas,
  leerArchivoComoTexto,
  parsearCSV,
  validarColumnas,
  type CampoPlantilla,
  type FilaImportacion,
} from '../utils/importacion';
import { CATEGORIAS_PREMIO } from '../types/models';
import type { CategoriaPremio, PremioJornada } from '../types/models';

const CAMPOS_PREMIO: CampoPlantilla[] = [
  { clave: 'categoria', etiqueta: 'Categoría', tipo: 'texto', requerido: true },
  { clave: 'valor', etiqueta: 'Valor (€)', tipo: 'texto', requerido: true },
];

const FILAS_EJEMPLO_PREMIO = CATEGORIAS_PREMIO.map((categoria, indice) => ({
  categoria,
  valor: [500000, 20000, 500, 80, 15, 3, 200][indice]?.toFixed(2) ?? '0.00',
}));

interface FilaPremioValidada {
  numeroFila: number;
  categoria: CategoriaPremio;
  valor: number;
  existente: boolean;
}

type Fase = 'seleccion' | 'validado' | 'importando' | 'resultado';

interface Props {
  jornadaId: number;
  premiosExistentes: PremioJornada[];
  onClose: () => void;
  onCompletado: (premios: PremioJornada[]) => void;
}

export function ImportarPremiosModal({ jornadaId, premiosExistentes, onClose, onCompletado }: Props) {
  const [nombreArchivo, setNombreArchivo] = useState('');
  const [fase, setFase] = useState<Fase>('seleccion');
  const [errores, setErrores] = useState<string[]>([]);
  const [filasValidas, setFilasValidas] = useState<FilaPremioValidada[]>([]);
  const [resultado, setResultado] = useState<{ creados: number; actualizados: number } | null>(null);
  const [procesando, setProcesando] = useState(false);

  function validarFilas(filas: FilaImportacion[]): { errores: string[]; validas: FilaPremioValidada[] } {
    const erroresColumnas = validarColumnas(filas, CAMPOS_PREMIO);
    if (erroresColumnas.length > 0) return { errores: erroresColumnas, validas: [] };

    const listaErrores: string[] = [];
    const validas: FilaPremioValidada[] = [];
    const categoriasVistas = new Map<string, number>();

    filas.forEach((fila, indice) => {
      const numeroFila = indice + 2;
      const categoriaTexto = (fila.categoria ?? '').trim();
      const valorTexto = (fila.valor ?? '').trim();

      const categoria = CATEGORIAS_PREMIO.find((c) => c.toLowerCase() === categoriaTexto.toLowerCase());
      if (!categoriaTexto) {
        listaErrores.push(`Fila ${numeroFila}: falta la categoría del premio.`);
      } else if (!categoria) {
        listaErrores.push(
          `Fila ${numeroFila}: la categoría "${categoriaTexto}" no es válida. Usa una de: ${CATEGORIAS_PREMIO.join(', ')}.`,
        );
      }

      let valor: number | null = null;
      if (!valorTexto) {
        listaErrores.push(`Fila ${numeroFila}: falta el valor del premio.`);
      } else {
        const numero = Number(valorTexto.replace(',', '.'));
        if (Number.isNaN(numero)) {
          listaErrores.push(`Fila ${numeroFila}: "${valorTexto}" no es un número válido.`);
        } else if (numero < 0) {
          listaErrores.push(`Fila ${numeroFila}: el valor del premio no puede ser menor que 0,00 €.`);
        } else {
          valor = numero;
        }
      }

      if (categoria) {
        const clave = categoria.toLowerCase();
        if (categoriasVistas.has(clave)) {
          listaErrores.push(`Categoría duplicada en el archivo: "${categoria}" (filas ${categoriasVistas.get(clave)} y ${numeroFila}).`);
        } else {
          categoriasVistas.set(clave, numeroFila);
        }
      }

      if (categoria && valor !== null) {
        const existente = premiosExistentes.some((p) => p.categoria === categoria);
        validas.push({ numeroFila, categoria, valor, existente });
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
      descargarArchivo('plantilla-premios.csv', generarPlantillaCSV(CAMPOS_PREMIO, FILAS_EJEMPLO_PREMIO), 'text/csv;charset=utf-8');
    } else {
      descargarArchivo(
        'plantilla-premios.json',
        generarPlantillaJSON(FILAS_EJEMPLO_PREMIO.map((f) => ({ categoria: f.categoria, valor: Number(f.valor) }))),
        'application/json',
      );
    }
  }

  async function handleConfirmarImportacion() {
    if (filasValidas.length === 0) return;
    setProcesando(true);
    setFase('importando');
    try {
      let creados = 0;
      let actualizados = 0;
      const erroresEjecucion: string[] = [];
      const premiosActuales = [...premiosExistentes];

      for (const fila of filasValidas) {
        try {
          const existente = premiosActuales.find((p) => p.categoria === fila.categoria);
          if (existente) {
            // eslint-disable-next-line no-await-in-loop
            const actualizado = await actualizarPremio(existente.id, fila.valor);
            const idx = premiosActuales.findIndex((p) => p.id === existente.id);
            premiosActuales[idx] = actualizado;
            actualizados += 1;
          } else {
            // eslint-disable-next-line no-await-in-loop
            const creado = await crearPremio(jornadaId, fila.categoria, fila.valor);
            premiosActuales.push(creado);
            creados += 1;
          }
        } catch (err) {
          erroresEjecucion.push(`Fila ${fila.numeroFila} ("${fila.categoria}"): ${extraerMensajeError(err).message}`);
        }
      }

      if (erroresEjecucion.length > 0) {
        setErrores(erroresEjecucion);
      }
      setResultado({ creados, actualizados });
      setFase('resultado');
      onCompletado(premiosActuales);
    } catch (err) {
      setErrores([extraerMensajeError(err).message]);
      setFase('validado');
    } finally {
      setProcesando(false);
    }
  }

  const puedeImportar = filasValidas.length > 0 && errores.length === 0;

  return (
    <Modal titulo="Importación masiva de premios" onClose={onClose} ancho={540}>
      <div className="campo">
        <span className="campo__etiqueta">1. Descargar plantilla</span>
        <div className="fila-acciones">
          <Button variante="secundario" chico onClick={() => handleDescargarPlantilla('csv')}>
            ⬇ Plantilla CSV
          </Button>
          <Button variante="secundario" chico onClick={() => handleDescargarPlantilla('json')}>
            ⬇ Plantilla JSON
          </Button>
        </div>
        <span className="campo__ayuda">Ningún valor de premio puede ser menor que 0,00 €.</span>
      </div>

      <div className="campo">
        <span className="campo__etiqueta">2. Adjuntar archivo relleno (.csv o .json)</span>
        <input type="file" accept=".csv,.json,application/json,text/csv" className="input" onChange={handleArchivo} />
        {nombreArchivo ? <span className="campo__ayuda">Archivo seleccionado: {nombreArchivo}</span> : null}
      </div>

      {fase === 'validado' || fase === 'resultado' ? (
        <>
          <ListaErroresImportacion errores={errores} />
          {errores.length === 0 && filasValidas.length > 0 && fase === 'validado' ? (
            <div className="tarjeta" style={{ background: 'var(--color-superficie-alt)', marginBottom: 16 }}>
              <p>
                Se han validado <strong>{filasValidas.length}</strong> premios:{' '}
                <strong>{filasValidas.filter((f) => !f.existente).length}</strong> nuevos y{' '}
                <strong>{filasValidas.filter((f) => f.existente).length}</strong> que sustituirán el valor ya existente.
              </p>
            </div>
          ) : null}
          {resultado ? (
            <div className="tarjeta" style={{ background: 'var(--color-superficie-alt)' }}>
              <p>
                ✅ Importación completada: <strong>{resultado.creados}</strong> premios nuevos creados,{' '}
                <strong>{resultado.actualizados}</strong> actualizados.
              </p>
            </div>
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
