import { EstadoVacio } from '../Estados';
import type { Competicion, Equipo, EquipoTemporadaCompeticion, Temporada, TemporadaCompeticion } from '../../types/models';

interface Props {
  equipo: Equipo;
  temporadas: Temporada[];
  competiciones: Competicion[];
  temporadaCompeticiones: TemporadaCompeticion[];
  vinculosEquipo: EquipoTemporadaCompeticion[];
}

export function EquipoFicha({ equipo, temporadas, competiciones, temporadaCompeticiones, vinculosEquipo }: Props) {
  const idsTemporadaCompeticion = new Set(
    vinculosEquipo.filter((v) => v.equipo_id === equipo.id).map((v) => v.temporada_competicion_id),
  );
  const relaciones = temporadaCompeticiones.filter((tc) => idsTemporadaCompeticion.has(tc.id));

  const porTemporada = new Map<number, number[]>();
  for (const relacion of relaciones) {
    const lista = porTemporada.get(relacion.temporada_id) ?? [];
    lista.push(relacion.competicion_id);
    porTemporada.set(relacion.temporada_id, lista);
  }

  const temporadasOrdenadas = temporadas
    .filter((t) => porTemporada.has(t.id))
    .sort((a, b) => b.nombre.localeCompare(a.nombre));

  return (
    <div>
      <div className="ficha-datos">
        <div className="ficha-dato">
          <span className="campo__etiqueta">País</span>
          <span>{equipo.pais}</span>
        </div>
        <div className="ficha-dato">
          <span className="campo__etiqueta">Tipo</span>
          <span className={`etiqueta ${equipo.es_club ? 'etiqueta--acento' : ''}`}>{equipo.es_club ? 'Club' : 'Selección'}</span>
        </div>
      </div>

      <h3 className="ficha-seccion__titulo">Competiciones por temporada</h3>
      {temporadasOrdenadas.length === 0 ? (
        <EstadoVacio icono="🔗" titulo="Sin vínculos todavía" subtitulo="Este equipo no está vinculado a ninguna competición." />
      ) : (
        <div className="ficha-lista-temporadas">
          {temporadasOrdenadas.map((temporada) => (
            <div key={temporada.id} className="ficha-grupo-temporada">
              <div className="ficha-grupo-temporada__titulo">{temporada.nombre}</div>
              <div className="fila-acciones">
                {(porTemporada.get(temporada.id) ?? []).map((competicionId) => {
                  const competicion = competiciones.find((c) => c.id === competicionId);
                  return (
                    <span key={competicionId} className="etiqueta etiqueta--acento">
                      {competicion?.nombre ?? `Competición #${competicionId}`}
                    </span>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
