export interface ErrorValidacionPartido {
  mensaje: string;
}

export function validarPartidoParaJornada({
  fechaHora,
  equipoLocalId,
  equipoVisitanteId,
  fechaCierreJornada,
  partidosDeLaJornada,
  partidoActualId,
}: {
  fechaHora: string | null;
  equipoLocalId: number | null;
  equipoVisitanteId: number | null;
  fechaCierreJornada: string | null;
  partidosDeLaJornada: Array<{ id: number; equipo_local_id: number | null; equipo_visitante_id: number | null }>;
  partidoActualId: number;
}): ErrorValidacionPartido | null {
  if (!fechaHora) {
    return { mensaje: 'La fecha y hora del partido es obligatoria.' };
  }

  const fechaPartido = new Date(fechaHora);
  if (Number.isNaN(fechaPartido.getTime())) {
    return { mensaje: 'La fecha y hora del partido no es válida.' };
  }

  if (fechaCierreJornada) {
    const fechaCierre = new Date(fechaCierreJornada);
    if (!Number.isNaN(fechaCierre.getTime()) && fechaPartido.getTime() < fechaCierre.getTime()) {
      return { mensaje: 'La fecha y hora del partido no puede ser anterior a la fecha de cierre de la jornada.' };
    }
  }

  if (equipoLocalId != null && equipoVisitanteId != null && equipoLocalId === equipoVisitanteId) {
    return { mensaje: 'El equipo local y el equipo visitante no pueden ser el mismo.' };
  }

  const equiposUsados = new Set<number>();
  for (const partido of partidosDeLaJornada) {
    if (partido.id === partidoActualId) continue;
    if (partido.equipo_local_id != null) equiposUsados.add(partido.equipo_local_id);
    if (partido.equipo_visitante_id != null) equiposUsados.add(partido.equipo_visitante_id);
  }

  if (equipoLocalId != null && equiposUsados.has(equipoLocalId)) {
    return { mensaje: 'No puede aparecer el mismo equipo más de una vez en la jornada.' };
  }

  if (equipoVisitanteId != null && equiposUsados.has(equipoVisitanteId)) {
    return { mensaje: 'No puede aparecer el mismo equipo más de una vez en la jornada.' };
  }

  return null;
}
