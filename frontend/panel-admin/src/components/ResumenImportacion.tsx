interface ResumenImportacionProps {
  errores: string[];
}

/** Lista de errores de validación de una importación masiva (bloqueantes: si hay alguno, no se importa nada). */
export function ListaErroresImportacion({ errores }: ResumenImportacionProps) {
  if (errores.length === 0) return null;
  return (
    <div className="banner-error" style={{ flexDirection: 'column', alignItems: 'stretch', gap: 8 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span>⚠️</span>
        <strong>
          Se {errores.length === 1 ? 'ha encontrado 1 error' : `han encontrado ${errores.length} errores`}. No se ha
          importado nada.
        </strong>
      </div>
      <ul style={{ margin: 0, paddingLeft: 20 }}>
        {errores.map((error, indice) => (
          <li key={indice}>{error}</li>
        ))}
      </ul>
    </div>
  );
}

interface ResultadoImportacion {
  creados: number;
  vinculadosNuevos: number;
  yaVinculados: number;
  entidadPlural: string;
}

export function ResumenResultadoImportacion({ creados, vinculadosNuevos, yaVinculados, entidadPlural }: ResultadoImportacion) {
  return (
    <div className="tarjeta" style={{ background: 'var(--color-superficie-alt)' }}>
      <p style={{ marginBottom: 8 }}>
        ✅ Importación completada: <strong>{creados}</strong> {entidadPlural} nuevos creados, <strong>{vinculadosNuevos}</strong>{' '}
        vinculados a esta edición, <strong>{yaVinculados}</strong> que ya estaban vinculados y se han omitido.
      </p>
    </div>
  );
}
