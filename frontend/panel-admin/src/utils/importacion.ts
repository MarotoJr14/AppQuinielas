// Utilidades genéricas para la importación masiva de Equipos y Competiciones
// desde CSV o JSON. Toda la validación ocurre en el navegador ANTES de
// llamar a la API: si se detecta cualquier error, no se realiza ninguna
// petición de escritura, y se muestran todos los errores encontrados.

export interface CampoPlantilla {
  clave: string;
  etiqueta: string;
  tipo: 'texto' | 'booleano';
  requerido: boolean;
  maxLength?: number;
  ayuda?: string;
}

export type FilaImportacion = Record<string, string>;

/** Parser CSV sencillo pero robusto: admite campos entre comillas con comas o comillas escapadas ("" -> "). */
export function parsearCSV(texto: string): string[][] {
  const filas: string[][] = [];
  let fila: string[] = [];
  let campo = '';
  let entreComillas = false;
  const limpio = texto.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

  for (let i = 0; i < limpio.length; i += 1) {
    const char = limpio[i];
    const siguiente = limpio[i + 1];

    if (entreComillas) {
      if (char === '"' && siguiente === '"') {
        campo += '"';
        i += 1;
      } else if (char === '"') {
        entreComillas = false;
      } else {
        campo += char;
      }
      continue;
    }

    if (char === '"') {
      entreComillas = true;
    } else if (char === ',') {
      fila.push(campo);
      campo = '';
    } else if (char === '\n') {
      fila.push(campo);
      filas.push(fila);
      fila = [];
      campo = '';
    } else {
      campo += char;
    }
  }
  // Última celda/fila pendiente (si el archivo no termina en salto de línea).
  if (campo.length > 0 || fila.length > 0) {
    fila.push(campo);
    filas.push(fila);
  }

  return filas.filter((f) => f.some((valor) => valor.trim() !== ''));
}

/** Convierte las filas de un CSV ya parseado (con cabecera) en objetos clave/valor. */
export function filasCSVAObjetos(filas: string[][]): FilaImportacion[] {
  if (filas.length === 0) return [];
  const cabeceras = filas[0].map((c) => c.trim().toLowerCase());
  return filas.slice(1).map((fila) => {
    const objeto: FilaImportacion = {};
    cabeceras.forEach((cabecera, indice) => {
      objeto[cabecera] = (fila[indice] ?? '').trim();
    });
    return objeto;
  });
}

const VALORES_VERDADEROS = ['true', '1', 'si', 'sí', 'club', 'x'];
const VALORES_FALSOS = ['false', '0', 'no', 'seleccion', 'selección'];

/** Interpreta representaciones habituales de booleano en CSV/JSON (true/false, 1/0, sí/no, club/selección...). */
export function parsearBooleano(valor: unknown): boolean | null {
  if (typeof valor === 'boolean') return valor;
  if (typeof valor === 'number') return valor !== 0;
  if (typeof valor === 'string') {
    const normalizado = valor.trim().toLowerCase();
    if (VALORES_VERDADEROS.includes(normalizado)) return true;
    if (VALORES_FALSOS.includes(normalizado)) return false;
  }
  return null;
}

export function generarPlantillaCSV(campos: CampoPlantilla[], filasEjemplo: Record<string, string>[]): string {
  const cabecera = campos.map((c) => c.clave).join(',');
  const filas = filasEjemplo.map((fila) =>
    campos
      .map((c) => {
        const valor = fila[c.clave] ?? '';
        return valor.includes(',') ? `"${valor.replace(/"/g, '""')}"` : valor;
      })
      .join(','),
  );
  return [cabecera, ...filas].join('\n');
}

export function generarPlantillaJSON(filasEjemplo: Record<string, unknown>[]): string {
  return JSON.stringify(filasEjemplo, null, 2);
}

export function descargarArchivo(nombre: string, contenido: string, mime: string): void {
  const blob = new Blob([contenido], { type: mime });
  const url = URL.createObjectURL(blob);
  const enlace = document.createElement('a');
  enlace.href = url;
  enlace.download = nombre;
  document.body.appendChild(enlace);
  enlace.click();
  document.body.removeChild(enlace);
  URL.revokeObjectURL(url);
}

export function leerArchivoComoTexto(archivo: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const lector = new FileReader();
    lector.onload = () => resolve(String(lector.result ?? ''));
    lector.onerror = () => reject(new Error('No se ha podido leer el archivo.'));
    lector.readAsText(archivo, 'utf-8');
  });
}

/** Convierte el contenido de un archivo JSON en una lista de filas clave/valor (strings), para reutilizar el mismo validador que el CSV. */
export function jsonAFilas(contenidoJson: string): FilaImportacion[] {
  let datos: unknown;
  try {
    datos = JSON.parse(contenidoJson);
  } catch {
    throw new Error('El archivo no contiene un JSON válido.');
  }
  if (!Array.isArray(datos)) {
    throw new Error('El JSON debe ser una lista de objetos (un objeto por equipo/competición).');
  }
  return datos.map((item) => {
    if (typeof item !== 'object' || item === null) {
      throw new Error('Cada elemento del JSON debe ser un objeto.');
    }
    const objeto: FilaImportacion = {};
    for (const [clave, valor] of Object.entries(item as Record<string, unknown>)) {
      objeto[clave.toLowerCase()] = typeof valor === 'boolean' ? (valor ? 'true' : 'false') : String(valor ?? '');
    }
    return objeto;
  });
}

export interface ResultadoValidacion<T> {
  errores: string[];
  filasValidas: T[];
}

/** Valida que todas las columnas requeridas de la plantilla estén presentes en la cabecera detectada. */
export function validarColumnas(filas: FilaImportacion[], campos: CampoPlantilla[]): string[] {
  if (filas.length === 0) return ['El archivo no contiene ninguna fila de datos.'];
  const columnasPresentes = new Set(Object.keys(filas[0]));
  const faltantes = campos.filter((c) => c.requerido && !columnasPresentes.has(c.clave));
  if (faltantes.length > 0) {
    return [`Faltan columnas obligatorias: ${faltantes.map((c) => c.clave).join(', ')}.`];
  }
  return [];
}
