import type { EquipoTemporadaCompeticion, TemporadaCompeticion } from '../types/models';

/**
 * Devuelve el conjunto de ids de TemporadaCompeticion que pertenecen a una
 * temporada dada (y, opcionalmente, a una competición concreta dentro de
 * ella).
 */
export function idsTemporadaCompeticion(
  temporadaCompeticiones: TemporadaCompeticion[],
  temporadaId: number | null,
  competicionId: number | null,
): Set<number> {
  return new Set(
    temporadaCompeticiones
      .filter((tc) => (temporadaId ? tc.temporada_id === temporadaId : true))
      .filter((tc) => (competicionId ? tc.competicion_id === competicionId : true))
      .map((tc) => tc.id),
  );
}

/** Ids de equipo vinculados a cualquiera de los TemporadaCompeticion indicados. */
export function idsEquiposVinculados(
  equipoTemporadaCompeticiones: EquipoTemporadaCompeticion[],
  temporadaCompeticionIds: Set<number>,
): Set<number> {
  return new Set(
    equipoTemporadaCompeticiones.filter((v) => temporadaCompeticionIds.has(v.temporada_competicion_id)).map((v) => v.equipo_id),
  );
}

/** Ids de competición vinculadas a una temporada dada. */
export function idsCompeticionesDeTemporada(temporadaCompeticiones: TemporadaCompeticion[], temporadaId: number | null): Set<number> {
  return new Set(
    temporadaCompeticiones.filter((tc) => (temporadaId ? tc.temporada_id === temporadaId : true)).map((tc) => tc.competicion_id),
  );
}
