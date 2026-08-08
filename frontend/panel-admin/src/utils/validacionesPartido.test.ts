import { describe, expect, it } from 'vitest';
import { validarPartidoParaJornada } from './validacionesPartido';

describe('validarPartidoParaJornada', () => {
  it('rechaza una fecha anterior a la fecha de cierre', () => {
    const error = validarPartidoParaJornada({
      fechaHora: '2024-01-01T10:00:00.000Z',
      equipoLocalId: 1,
      equipoVisitanteId: 2,
      fechaCierreJornada: '2024-01-01T11:00:00.000Z',
      partidosDeLaJornada: [],
      partidoActualId: 10,
    });

    expect(error?.mensaje).toContain('fecha y hora');
  });

  it('rechaza equipos iguales', () => {
    const error = validarPartidoParaJornada({
      fechaHora: '2024-01-01T12:00:00.000Z',
      equipoLocalId: 1,
      equipoVisitanteId: 1,
      fechaCierreJornada: '2024-01-01T11:00:00.000Z',
      partidosDeLaJornada: [],
      partidoActualId: 10,
    });

    expect(error?.mensaje).toContain('mismo');
  });

  it('rechaza un equipo repetido en la jornada', () => {
    const error = validarPartidoParaJornada({
      fechaHora: '2024-01-01T12:00:00.000Z',
      equipoLocalId: 3,
      equipoVisitanteId: 4,
      fechaCierreJornada: '2024-01-01T11:00:00.000Z',
      partidosDeLaJornada: [{ id: 1, equipo_local_id: 3, equipo_visitante_id: 2 }],
      partidoActualId: 10,
    });

    expect(error?.mensaje).toContain('más de una vez');
  });
});
