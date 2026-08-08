import { EstadoVacio } from '../Estados';
import { ETIQUETA_CATEGORIA } from '../../types/models';
import type { Competicion, Equipo, Jornada, Partido, PremioJornada, Temporada, TemporadaCompeticion } from '../../types/models';
import { formatearFecha } from '../../utils/fechas';
import { obtenerInfoEstadoJornada } from '../../utils/estadosJornada';

interface Props {
  jornada: Jornada;
  temporada: Temporada | undefined;
  partidos: Partido[];
  premios: PremioJornada[];
  equipos: Equipo[];
  competiciones: Competicion[];
  temporadaCompeticiones: TemporadaCompeticion[];
}

export function JornadaFicha({ jornada, temporada, partidos, premios, equipos, competiciones, temporadaCompeticiones }: Props) {
  function nombreEquipo(equipoId: number | null): string {
    if (equipoId === null) return 'Por confirmar';
    return equipos.find((e) => e.id === equipoId)?.nombre ?? `Equipo #${equipoId}`;
  }

  const idsCompeticionPresentes = new Set(
    partidos
      .map((p) => p.competicion_temporada_id)
      .filter((id): id is number => id !== null)
      .map((temporadaCompeticionId) => temporadaCompeticiones.find((tc) => tc.id === temporadaCompeticionId)?.competicion_id)
      .filter((id): id is number => id !== undefined),
  );
  const competicionesPresentes = competiciones
    .filter((c) => idsCompeticionPresentes.has(c.id))
    .sort((a, b) => a.nombre.localeCompare(b.nombre));

  const partidosOrdenados = [...partidos].sort((a, b) => a.orden - b.orden);

  return (
    <div>
      <div className="ficha-datos">
        <div className="ficha-dato">
          <span className="campo__etiqueta">Temporada</span>
          <span>{temporada?.nombre ?? `Temporada #${jornada.temporada_id}`}</span>
        </div>
        <div className="ficha-dato">
          <span className="campo__etiqueta">Nombre</span>
          <span>{jornada.nombre}</span>
        </div>
        <div className="ficha-dato">
          <span className="campo__etiqueta">Fecha de cierre</span>
          <span>{formatearFecha(jornada.fecha_cierre)}</span>
        </div>
        <div className="ficha-dato">
          <span className="campo__etiqueta">Estado</span>
          <span>{obtenerInfoEstadoJornada(jornada.estado).texto}</span>
        </div>
      </div>

      <h3 className="ficha-seccion__titulo">Competiciones presentes</h3>
      {competicionesPresentes.length === 0 ? (
        <EstadoVacio icono="🏆" titulo="Sin competiciones asignadas" subtitulo="Los partidos de esta jornada aún no tienen competición asociada." />
      ) : (
        <div className="fila-acciones" style={{ marginBottom: 20 }}>
          {competicionesPresentes.map((c) => (
            <span key={c.id} className="etiqueta etiqueta--acento">
              {c.nombre}
            </span>
          ))}
        </div>
      )}

      <h3 className="ficha-seccion__titulo">Partidos</h3>
      {partidosOrdenados.length === 0 ? (
        <EstadoVacio icono="⚽" titulo="Sin partidos todavía" />
      ) : (
        <ul className="ficha-lista-simple" style={{ marginBottom: 20 }}>
          {partidosOrdenados.map((partido) => (
            <li key={partido.id}>
              {partido.orden}. {nombreEquipo(partido.equipo_local_id)} - {nombreEquipo(partido.equipo_visitante_id)}
            </li>
          ))}
        </ul>
      )}

      <h3 className="ficha-seccion__titulo">Premios</h3>
      {premios.length === 0 ? (
        <EstadoVacio icono="💶" titulo="Sin premios registrados" />
      ) : (
        <ul className="ficha-lista-simple">
          {premios.map((premio) => (
            <li key={premio.id}>
              {ETIQUETA_CATEGORIA[premio.categoria]}: {premio.valor != null ? `${premio.valor.toFixed(2)} €` : '-'}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
