import { apiClient } from './client';
import type { Partido } from '../types/models';

export async function listarPartidosDeJornada(jornadaId: number): Promise<Partido[]> {
  const { data } = await apiClient.get<Partido[]>(`/partidos/jornada/${jornadaId}`);
  return [...data].sort((a, b) => a.orden - b.orden);
}

export interface CrearPartidoPayload {
  jornada_id: number;
  orden: number;
  competicion_temporada_id?: number | null;
  fecha_hora?: string | null;
  canal?: string | null;
  equipo_local_id?: number | null;
  equipo_visitante_id?: number | null;
}

export async function crearPartido(payload: CrearPartidoPayload): Promise<Partido> {
  const { data } = await apiClient.post<Partido>('/partidos', payload);
  return data;
}

export interface ActualizarPartidoPayload {
  estado?: string;
  fecha_hora?: string | null;
  canal?: string | null;
  equipo_local_id?: number | null;
  equipo_visitante_id?: number | null;
  competicion_temporada_id?: number | null;
}

export async function actualizarPartido(id: number, payload: ActualizarPartidoPayload): Promise<Partido> {
  const { data } = await apiClient.patch<Partido>(`/partidos/${id}`, payload);
  return data;
}

export async function registrarResultado(id: number, golesLocal: number, golesVisitante: number): Promise<Partido> {
  const { data } = await apiClient.post<Partido>(`/partidos/${id}/resultado`, {
    goles_local: golesLocal,
    goles_visitante: golesVisitante,
  });
  return data;
}

/** Crea los 15 partidos (14 normales + Pleno al 15) de una jornada recién creada. */
export async function generarQuincePartidos(jornadaId: number): Promise<Partido[]> {
  const creados: Partido[] = [];
  for (let orden = 1; orden <= 15; orden += 1) {
    // Secuencial a propósito: el backend exige unicidad de (jornada_id, orden)
    // y preferimos mantener el orden de creación predecible.
    // eslint-disable-next-line no-await-in-loop
    const partido = await crearPartido({ jornada_id: jornadaId, orden });
    creados.push(partido);
  }
  return creados;
}
