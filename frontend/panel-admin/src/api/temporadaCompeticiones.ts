import { apiClient } from './client';
import type { TemporadaCompeticion } from '../types/models';

export async function listarTemporadaCompeticiones(): Promise<TemporadaCompeticion[]> {
  const { data } = await apiClient.get<TemporadaCompeticion[]>('/temporada-competiciones', { params: { limit: 1000 } });
  return data;
}

export async function crearTemporadaCompeticion(temporadaId: number, competicionId: number): Promise<TemporadaCompeticion> {
  const { data } = await apiClient.post<TemporadaCompeticion>('/temporada-competiciones', {
    temporada_id: temporadaId,
    competicion_id: competicionId,
  });
  return data;
}

/**
 * Busca una relación Temporada-Competición ya existente en la lista dada; si
 * no existe, la crea. Se usa tanto en la importación masiva como en el
 * filtro, para no depender de que el backend devuelva un 409 amistoso ante
 * duplicados (la relación es única por temporada_id+competicion_id).
 */
export async function obtenerOCrearTemporadaCompeticion(
  existentes: TemporadaCompeticion[],
  temporadaId: number,
  competicionId: number,
): Promise<TemporadaCompeticion> {
  const encontrada = existentes.find((tc) => tc.temporada_id === temporadaId && tc.competicion_id === competicionId);
  if (encontrada) return encontrada;
  return crearTemporadaCompeticion(temporadaId, competicionId);
}
