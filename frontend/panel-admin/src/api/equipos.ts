import { apiClient } from './client';
import type { Equipo } from '../types/models';

export async function listarEquipos(): Promise<Equipo[]> {
  const { data } = await apiClient.get<Equipo[]>('/equipos', { params: { limit: 1000 } });
  return data;
}

export interface CrearEquipoPayload {
  nombre: string;
  es_club: boolean;
  pais: string;
}

export async function crearEquipo(payload: CrearEquipoPayload): Promise<Equipo> {
  const { data } = await apiClient.post<Equipo>('/equipos', payload);
  return data;
}

export async function actualizarEquipo(id: number, payload: Partial<CrearEquipoPayload>): Promise<Equipo> {
  const { data } = await apiClient.patch<Equipo>(`/equipos/${id}`, payload);
  return data;
}

export async function eliminarEquipo(id: number): Promise<void> {
  await apiClient.delete(`/equipos/${id}`);
}
