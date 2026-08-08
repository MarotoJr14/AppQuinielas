export type EstadoJornadaPanel = 'pendiente' | 'en_curso' | 'finalizada';

export function obtenerInfoEstadoJornada(estado?: EstadoJornadaPanel) {
  switch (estado) {
    case 'en_curso':
      return { texto: 'En curso', clase: 'circulo-estado--en-juego' };
    case 'finalizada':
      return { texto: 'Finalizada', clase: 'circulo-estado--finalizado' };
    case 'pendiente':
    default:
      return { texto: 'Pendiente', clase: 'circulo-estado--pendiente' };
  }
}
