import { apiClient } from './client';
import type { Temporada } from '../types/models';

export async function listarTemporadas(): Promise<Temporada[]> {
  const { data } = await apiClient.get<Temporada[]>('/temporadas', { params: { limit: 200 } });
  return data;
}

export async function crearTemporada(nombre: string): Promise<Temporada> {
  const { data } = await apiClient.post<Temporada>('/temporadas', { nombre });
  return data;
}

export async function actualizarTemporada(id: number, nombre: string): Promise<Temporada> {
  const { data } = await apiClient.patch<Temporada>(`/temporadas/${id}`, { nombre });
  return data;
}

export async function eliminarTemporada(id: number): Promise<void> {
  await apiClient.delete(`/temporadas/${id}`);
}
