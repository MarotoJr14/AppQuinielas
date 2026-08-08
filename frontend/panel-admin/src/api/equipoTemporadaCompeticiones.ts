import { apiClient } from './client';
import type { EquipoTemporadaCompeticion } from '../types/models';

export async function listarEquipoTemporadaCompeticiones(): Promise<EquipoTemporadaCompeticion[]> {
  const { data } = await apiClient.get<EquipoTemporadaCompeticion[]>('/equipo-temporada-competiciones', {
    params: { limit: 2000 },
  });
  return data;
}

export async function vincularEquipoATemporadaCompeticion(
  equipoId: number,
  temporadaCompeticionId: number,
): Promise<EquipoTemporadaCompeticion> {
  const { data } = await apiClient.post<EquipoTemporadaCompeticion>('/equipo-temporada-competiciones', {
    equipo_id: equipoId,
    temporada_competicion_id: temporadaCompeticionId,
  });
  return data;
}
