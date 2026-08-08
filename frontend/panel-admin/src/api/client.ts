import axios, { AxiosError } from 'axios';

// URL base de la API. En desarrollo, Vite expone las variables que empiezan
// por VITE_ a través de import.meta.env. Ver .env.example.
const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL as string | undefined) ?? 'http://localhost:8000/api/v1';

export const TOKEN_STORAGE_KEY = 'quinielas_admin_token';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem(TOKEN_STORAGE_KEY);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

/**
 * Error normalizado a partir de una respuesta de error de la API (FastAPI
 * devuelve el mensaje en el campo `detail`, que puede ser un string o una
 * lista de errores de validación de Pydantic).
 */
export class ApiError extends Error {
  status: number | null;

  constructor(message: string, status: number | null) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

export function extraerMensajeError(error: unknown): ApiError {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<{ detail?: unknown }>;
    const status = axiosError.response?.status ?? null;
    const detail = axiosError.response?.data?.detail;

    if (typeof detail === 'string') {
      return new ApiError(detail, status);
    }
    if (Array.isArray(detail)) {
      const mensaje = detail
        .map((item) => (typeof item === 'object' && item !== null && 'msg' in item ? String((item as { msg: unknown }).msg) : String(item)))
        .join(' · ');
      return new ApiError(mensaje || 'Error de validación.', status);
    }
    if (axiosError.message === 'Network Error') {
      return new ApiError('No se ha podido conectar con el servidor. Comprueba que el backend esté en marcha.', status);
    }
    return new ApiError(axiosError.message || 'Ha ocurrido un error inesperado.', status);
  }
  if (error instanceof Error) {
    return new ApiError(error.message, null);
  }
  return new ApiError('Ha ocurrido un error inesperado.', null);
}
