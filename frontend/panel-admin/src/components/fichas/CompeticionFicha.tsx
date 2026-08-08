import { useMemo, useState } from 'react';
import { Select } from '../FormField';
import { EstadoVacio } from '../Estados';
import type { Competicion, Equipo, EquipoTemporadaCompeticion, Temporada, TemporadaCompeticion } from '../../types/models';

interface Props {
  competicion: Competicion;
  temporadas: Temporada[];
  equipos: Equipo[];
  temporadaCompeticiones: TemporadaCompeticion[];
  vinculosEquipo: EquipoTemporadaCompeticion[];
}

export function CompeticionFicha({ competicion, temporadas, equipos, temporadaCompeticiones, vinculosEquipo }: Props) {
  const relaciones = useMemo(
    () => temporadaCompeticiones.filter((tc) => tc.competicion_id === competicion.id),
    [temporadaCompeticiones, competicion.id],
  );

  const temporadasVinculadas = useMemo(() => {
    return temporadas
      .filter((t) => relaciones.some((r) => r.temporada_id === t.id))
      .sort((a, b) => b.nombre.localeCompare(a.nombre));
  }, [temporadas, relaciones]);

  const [temporadaSeleccionadaId, setTemporadaSeleccionadaId] = useState<number | ''>(temporadasVinculadas[0]?.id ?? '');

  const equiposDeLaTemporada = useMemo(() => {
    if (temporadaSeleccionadaId === '') return [];
    const relacion = relaciones.find((r) => r.temporada_id === temporadaSeleccionadaId);
    if (!relacion) return [];
    const idsEquipo = new Set(
      vinculosEquipo.filter((v) => v.temporada_competicion_id === relacion.id).map((v) => v.equipo_id),
    );
    return equipos.filter((e) => idsEquipo.has(e.id)).sort((a, b) => a.nombre.localeCompare(b.nombre));
  }, [temporadaSeleccionadaId, relaciones, vinculosEquipo, equipos]);

  return (
    <div>
      <div className="ficha-datos">
        <div className="ficha-dato">
          <span className="campo__etiqueta">Ámbito</span>
          <span>{competicion.ambito}</span>
        </div>
        <div className="ficha-dato">
          <span className="campo__etiqueta">Tipo</span>
          <span className={`etiqueta ${competicion.es_clubes ? 'etiqueta--acento' : ''}`}>
            {competicion.es_clubes ? 'Clubes' : 'Selecciones'}
          </span>
        </div>
      </div>

      <h3 className="ficha-seccion__titulo">Temporadas vinculadas</h3>
      {temporadasVinculadas.length === 0 ? (
        <EstadoVacio icono="🔗" titulo="Sin vínculos todavía" subtitulo="Esta competición no está vinculada a ninguna temporada." />
      ) : (
        <div className="fila-acciones" style={{ marginBottom: 20 }}>
          {temporadasVinculadas.map((t) => (
            <span key={t.id} className="etiqueta etiqueta--acento">
              {t.nombre}
            </span>
          ))}
        </div>
      )}

      {temporadasVinculadas.length > 0 ? (
        <>
          <h3 className="ficha-seccion__titulo">Equipos por temporada</h3>
          <Select
            value={temporadaSeleccionadaId}
            onChange={(evento) => setTemporadaSeleccionadaId(evento.target.value === '' ? '' : Number(evento.target.value))}
          >
            {temporadasVinculadas.map((t) => (
              <option key={t.id} value={t.id}>
                {t.nombre}
              </option>
            ))}
          </Select>
          {equiposDeLaTemporada.length === 0 ? (
            <EstadoVacio icono="⚽" titulo="Sin equipos todavía" subtitulo="Esta edición no tiene equipos vinculados." />
          ) : (
            <ul className="ficha-lista-simple">
              {equiposDeLaTemporada.map((equipo) => (
                <li key={equipo.id}>{equipo.nombre}</li>
              ))}
            </ul>
          )}
        </>
      ) : null}
    </div>
  );
}
