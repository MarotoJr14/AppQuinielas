import { describe, expect, it } from 'vitest';
import { obtenerInfoEstadoJornada } from './estadosJornada';

describe('obtenerInfoEstadoJornada', () => {
  it('devuelve la etiqueta y clase para cada estado de jornada', () => {
    expect(obtenerInfoEstadoJornada('pendiente')).toEqual({ texto: 'Pendiente', clase: 'circulo-estado--pendiente' });
    expect(obtenerInfoEstadoJornada('en_curso')).toEqual({ texto: 'En curso', clase: 'circulo-estado--en-juego' });
    expect(obtenerInfoEstadoJornada('finalizada')).toEqual({ texto: 'Finalizada', clase: 'circulo-estado--finalizado' });
  });

  it('devuelve pendiente como valor por defecto', () => {
    expect(obtenerInfoEstadoJornada(undefined)).toEqual({ texto: 'Pendiente', clase: 'circulo-estado--pendiente' });
  });
});
