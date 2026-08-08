// Tipos de dominio, alineados 1:1 con los esquemas Pydantic del backend
// (ver backend/app/schemas y backend/app/models/enums.py).

export interface Usuario {
  id: number;
  nombre_usuario: string;
  email: string;
}

export interface Temporada {
  id: number;
  nombre: string;
}

export interface Jornada {
  id: number;
  temporada_id: number;
  nombre: string;
  fecha_cierre: string; // ISO datetime
  estado?: EstadoJornada;
}

export type CategoriaPremio =
  | '15 aciertos'
  | '14 aciertos'
  | '13 aciertos'
  | '12 aciertos'
  | '11 aciertos'
  | '10 aciertos'
  | 'elige 8';

export const CATEGORIAS_PREMIO: CategoriaPremio[] = [
  '15 aciertos',
  '14 aciertos',
  '13 aciertos',
  '12 aciertos',
  '11 aciertos',
  '10 aciertos',
  'elige 8',
];

export const ETIQUETA_CATEGORIA: Record<CategoriaPremio, string> = {
  '15 aciertos': 'Pleno (15 aciertos)',
  '14 aciertos': '14 aciertos',
  '13 aciertos': '13 aciertos',
  '12 aciertos': '12 aciertos',
  '11 aciertos': '11 aciertos',
  '10 aciertos': '10 aciertos',
  'elige 8': 'Elige 8',
};

export interface PremioJornada {
  id: number;
  jornada_id: number;
  categoria: CategoriaPremio;
  valor: number | null;
}

export interface Competicion {
  id: number;
  nombre: string;
  ambito: string;
  es_clubes: boolean;
}

export interface TemporadaCompeticion {
  id: number;
  temporada_id: number;
  competicion_id: number;
}

export interface EquipoTemporadaCompeticion {
  id: number;
  equipo_id: number;
  temporada_competicion_id: number;
}

export interface Equipo {
  id: number;
  nombre: string;
  es_club: boolean;
  pais: string;
}

export interface Partido {
  id: number;
  jornada_id: number;
  orden: number;
  estado: EstadoPartido;
  competicion_temporada_id: number | null;
  fecha_hora: string | null;
  canal: string | null;
  equipo_local_id: number | null;
  equipo_visitante_id: number | null;
  goles_local: number | null;
  goles_visitante: number | null;
}

export type EstadoApuesta = 'abierta' | 'cerrada';
export type EstadoJornada = 'pendiente' | 'en_curso' | 'finalizada';
export type EstadoPartido = 'pendiente' | 'en_juego' | 'finalizado';

export interface Apuesta {
  id: number;
  jornada_id: number;
  grupo_id: number;
  usuario_elige8_id: number;
  estado: EstadoApuesta;
  precio: number | null;
  beneficio: number | null;
}
