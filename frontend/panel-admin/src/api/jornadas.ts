import { apiClient } from './client';
import type { CategoriaPremio, Jornada, PremioJornada } from '../types/models';

export async function listarJornadas(): Promise<Jornada[]> {
  const { data } = await apiClient.get<Jornada[]>('/jornadas', { params: { limit: 300 } });
  return data;
}

export async function obtenerJornada(id: number): Promise<Jornada> {
  const { data } = await apiClient.get<Jornada>(`/jornadas/${id}`);
  return data;
}

export interface CrearJornadaPayload {
  temporada_id: number;
  nombre: string;
  fecha_cierre: string; // ISO datetime en UTC
}

export async function crearJornada(payload: CrearJornadaPayload): Promise<Jornada> {
  const { data } = await apiClient.post<Jornada>('/jornadas', payload);
  return data;
}

export async function actualizarJornada(id: number, payload: Partial<CrearJornadaPayload>): Promise<Jornada> {
  const { data } = await apiClient.patch<Jornada>(`/jornadas/${id}`, payload);
  return data;
}

export async function eliminarJornada(id: number): Promise<void> {
  await apiClient.delete(`/jornadas/${id}`);
}

export async function listarPremiosDeJornada(jornadaId: number): Promise<PremioJornada[]> {
  const { data } = await apiClient.get<PremioJornada[]>(`/premios/jornada/${jornadaId}`);
  return data;
}

export async function crearPremio(jornadaId: number, categoria: CategoriaPremio, valor: number | null): Promise<PremioJornada> {
  const { data } = await apiClient.post<PremioJornada>('/premios', {
    jornada_id: jornadaId,
    categoria,
    valor,
  });
  return data;
}

export async function actualizarPremio(premioId: number, valor: number | null): Promise<PremioJornada> {
  const { data } = await apiClient.patch<PremioJornada>(`/premios/${premioId}`, { valor });
  return data;
}
