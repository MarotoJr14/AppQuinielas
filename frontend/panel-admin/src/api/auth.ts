import { apiClient } from './client';
import type { Usuario } from '../types/models';

export interface LoginPayload {
  nombre_usuario: string;
  password: string;
}

export interface TokenResponse {
  access_token: string;
  token_type: string;
}

export async function login(payload: LoginPayload): Promise<TokenResponse> {
  const { data } = await apiClient.post<TokenResponse>('/auth/login', payload);
  return data;
}

export async function obtenerMiUsuario(): Promise<Usuario> {
  const { data } = await apiClient.get<Usuario>('/usuarios/me');
  return data;
}
