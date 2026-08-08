import { apiClient } from './client';
import type { Competicion } from '../types/models';

export async function listarCompeticiones(): Promise<Competicion[]> {
  const { data } = await apiClient.get<Competicion[]>('/competiciones', { params: { limit: 1000 } });
  return data;
}

export interface CrearCompeticionPayload {
  nombre: string;
  ambito: string;
  es_clubes: boolean;
}

export async function crearCompeticion(payload: CrearCompeticionPayload): Promise<Competicion> {
  const { data } = await apiClient.post<Competicion>('/competiciones', payload);
  return data;
}

export async function actualizarCompeticion(id: number, payload: Partial<CrearCompeticionPayload>): Promise<Competicion> {
  const { data } = await apiClient.patch<Competicion>(`/competiciones/${id}`, payload);
  return data;
}

export async function eliminarCompeticion(id: number): Promise<void> {
  await apiClient.delete(`/competiciones/${id}`);
}
