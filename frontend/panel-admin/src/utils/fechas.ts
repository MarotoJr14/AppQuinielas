const formateador = new Intl.DateTimeFormat('es-ES', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
});

/** Formatea una fecha ISO (UTC) al formato DD/MM/AAAA HH:mm en hora local. */
export function formatearFecha(iso: string | null | undefined): string {
  if (!iso) return '-';
  const fecha = new Date(iso);
  if (Number.isNaN(fecha.getTime())) return '-';
  return formateador.format(fecha);
}

/** Convierte una fecha ISO a valor válido para <input type="datetime-local">. */
export function isoAInputLocal(iso: string | null | undefined): string {
  if (!iso) return '';
  const fecha = new Date(iso);
  if (Number.isNaN(fecha.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  const y = fecha.getFullYear();
  const m = pad(fecha.getMonth() + 1);
  const d = pad(fecha.getDate());
  const h = pad(fecha.getHours());
  const min = pad(fecha.getMinutes());
  return `${y}-${m}-${d}T${h}:${min}`;
}

/** Convierte el valor de un <input type="datetime-local"> (hora local) a ISO UTC. */
export function inputLocalAIso(valor: string): string | null {
  if (!valor) return null;
  const fecha = new Date(valor);
  if (Number.isNaN(fecha.getTime())) return null;
  return fecha.toISOString();
}
