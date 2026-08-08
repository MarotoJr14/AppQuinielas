import { EstadoVacio } from '../Estados';
import type { Competicion, Temporada, TemporadaCompeticion } from '../../types/models';

interface Props {
  temporada: Temporada;
  competiciones: Competicion[];
  temporadaCompeticiones: TemporadaCompeticion[];
}

export function TemporadaFicha({ temporada, competiciones, temporadaCompeticiones }: Props) {
  const idsCompeticion = new Set(
    temporadaCompeticiones.filter((tc) => tc.temporada_id === temporada.id).map((tc) => tc.competicion_id),
  );
  const competicionesVinculadas = competiciones
    .filter((c) => idsCompeticion.has(c.id))
    .sort((a, b) => a.nombre.localeCompare(b.nombre));

  return (
    <div>
      <h3 className="ficha-seccion__titulo">Competiciones vinculadas</h3>
      {competicionesVinculadas.length === 0 ? (
        <EstadoVacio icono="🔗" titulo="Sin vínculos todavía" subtitulo="Esta temporada no tiene competiciones vinculadas." />
      ) : (
        <ul className="ficha-lista-simple">
          {competicionesVinculadas.map((competicion) => (
            <li key={competicion.id}>
              {competicion.nombre}
              <span className="texto-secundario"> · {competicion.ambito}</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
