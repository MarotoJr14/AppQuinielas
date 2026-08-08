import { useState } from 'react';
import type { ReactNode } from 'react';

export interface ColumnaTabla<T> {
  clave: string;
  etiqueta: string;
  render: (fila: T) => ReactNode;
  /** Accesor usado para ordenar por esta columna. Si se omite, la columna no es ordenable. */
  ordenar?: (fila: T) => string | number;
}

interface EntityTableProps<T extends { id: number }> {
  columnas: ColumnaTabla<T>[];
  filas: T[];
  onVerFicha: (fila: T) => void;
  onEditar: (fila: T) => void;
  onEliminar: (fila: T) => void;
}

const FILAS_POR_PAGINA = 20;

type Direccion = 'asc' | 'desc';

/**
 * Tabla genérica reutilizada por Equipos, Competiciones y Temporadas: cada
 * fila representa un registro, con una columna final de Acciones (editar /
 * eliminar). Un click en la fila (fuera de los botones de Acciones) abre la
 * ficha de detalle del registro. Incluye ordenación por columna (click en la
 * cabecera) y paginación de 20 filas por página.
 */
export function EntityTable<T extends { id: number }>({ columnas, filas, onVerFicha, onEditar, onEliminar }: EntityTableProps<T>) {
  const [columnaOrden, setColumnaOrden] = useState<string | null>(null);
  const [direccion, setDireccion] = useState<Direccion>('asc');
  const [paginaActual, setPaginaActual] = useState(1);

  function alternarOrden(columna: ColumnaTabla<T>) {
    if (!columna.ordenar) return;
    if (columnaOrden === columna.clave) {
      setDireccion((actual) => (actual === 'asc' ? 'desc' : 'asc'));
    } else {
      setColumnaOrden(columna.clave);
      setDireccion('asc');
    }
    setPaginaActual(1);
  }

  const columnaActiva = columnas.find((c) => c.clave === columnaOrden);
  const filasOrdenadas = columnaActiva?.ordenar
    ? [...filas].sort((a, b) => {
        const valorA = columnaActiva.ordenar!(a);
        const valorB = columnaActiva.ordenar!(b);
        const comparacion =
          typeof valorA === 'number' && typeof valorB === 'number'
            ? valorA - valorB
            : String(valorA).localeCompare(String(valorB), 'es', { sensitivity: 'base' });
        return direccion === 'asc' ? comparacion : -comparacion;
      })
    : filas;

  const totalPaginas = Math.max(1, Math.ceil(filasOrdenadas.length / FILAS_POR_PAGINA));
  const paginaSegura = Math.min(paginaActual, totalPaginas);
  const inicio = (paginaSegura - 1) * FILAS_POR_PAGINA;
  const filasPagina = filasOrdenadas.slice(inicio, inicio + FILAS_POR_PAGINA);

  return (
    <div>
      <div className="tabla-entidades-envoltorio">
        <table className="tabla-entidades">
          <thead>
            <tr>
              {columnas.map((columna) => {
                const esOrdenable = Boolean(columna.ordenar);
                const activa = columnaOrden === columna.clave;
                return (
                  <th
                    key={columna.clave}
                    className={esOrdenable ? 'th-ordenable' : ''}
                    onClick={() => alternarOrden(columna)}
                  >
                    <span className="th-ordenable__contenido">
                      {columna.etiqueta}
                      {esOrdenable ? (
                        <span className={`th-ordenable__flecha ${activa ? 'activa' : ''}`}>
                          {activa ? (direccion === 'asc' ? '▲' : '▼') : '↕'}
                        </span>
                      ) : null}
                    </span>
                  </th>
                );
              })}
              <th style={{ width: 140 }}>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {filasPagina.map((fila) => (
              <tr key={fila.id} className="tabla-entidades__fila" onClick={() => onVerFicha(fila)}>
                {columnas.map((columna) => (
                  <td key={columna.clave}>{columna.render(fila)}</td>
                ))}
                <td>
                  <div className="fila-acciones" onClick={(evento) => evento.stopPropagation()}>
                    <button className="boton boton--icono" title="Editar" onClick={() => onEditar(fila)}>
                      ✏️
                    </button>
                    <button className="boton boton--icono" title="Eliminar" onClick={() => onEliminar(fila)}>
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {filasOrdenadas.length > 0 ? (
        <div className="paginacion">
          <span className="texto-secundario">
            Mostrando {inicio + 1}-{Math.min(inicio + FILAS_POR_PAGINA, filasOrdenadas.length)} de {filasOrdenadas.length}
          </span>
          <div className="paginacion__controles">
            <button
              className="boton boton--secundario boton--chico"
              disabled={paginaSegura <= 1}
              onClick={() => setPaginaActual(paginaSegura - 1)}
            >
              ← Anterior
            </button>
            <span className="texto-secundario">
              Página {paginaSegura} de {totalPaginas}
            </span>
            <button
              className="boton boton--secundario boton--chico"
              disabled={paginaSegura >= totalPaginas}
              onClick={() => setPaginaActual(paginaSegura + 1)}
            >
              Siguiente →
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
