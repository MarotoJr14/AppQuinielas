import { useCallback, useEffect, useState } from 'react';
import { extraerMensajeError } from '../api/client';
import { listarCompeticiones } from '../api/competiciones';
import { listarEquipoTemporadaCompeticiones } from '../api/equipoTemporadaCompeticiones';
import { listarEquipos } from '../api/equipos';
import { listarTemporadaCompeticiones } from '../api/temporadaCompeticiones';
import { listarTemporadas } from '../api/temporadas';
import type { Competicion, Equipo, EquipoTemporadaCompeticion, Temporada, TemporadaCompeticion } from '../types/models';

export interface CatalogoDatos {
  temporadas: Temporada[];
  competiciones: Competicion[];
  equipos: Equipo[];
  temporadaCompeticiones: TemporadaCompeticion[];
  vinculosEquipo: EquipoTemporadaCompeticion[];
  cargando: boolean;
  error: string | null;
  recargar: () => Promise<void>;
}

/**
 * Carga conjunta de las cinco entidades del catálogo (temporadas,
 * competiciones, equipos y sus tablas de vínculo). Se usa desde las páginas
 * de Equipos, Competiciones y Temporadas, que necesitan las mismas
 * relaciones cruzadas tanto para los filtros como para las fichas de
 * detalle.
 */
export function useCatalogoDatos(): CatalogoDatos {
  const [temporadas, setTemporadas] = useState<Temporada[]>([]);
  const [competiciones, setCompeticiones] = useState<Competicion[]>([]);
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [temporadaCompeticiones, setTemporadaCompeticiones] = useState<TemporadaCompeticion[]>([]);
  const [vinculosEquipo, setVinculosEquipo] = useState<EquipoTemporadaCompeticion[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const recargar = useCallback(async () => {
    setCargando(true);
    setError(null);
    try {
      const [datosTemporadas, datosCompeticiones, datosEquipos, datosTemporadaCompeticiones, datosVinculos] = await Promise.all([
        listarTemporadas(),
        listarCompeticiones(),
        listarEquipos(),
        listarTemporadaCompeticiones(),
        listarEquipoTemporadaCompeticiones(),
      ]);
      setTemporadas(datosTemporadas);
      setCompeticiones(datosCompeticiones);
      setEquipos(datosEquipos.sort((a, b) => a.nombre.localeCompare(b.nombre)));
      setTemporadaCompeticiones(datosTemporadaCompeticiones);
      setVinculosEquipo(datosVinculos);
    } catch (err) {
      setError(extraerMensajeError(err).message);
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => {
    void recargar();
  }, [recargar]);

  return { temporadas, competiciones, equipos, temporadaCompeticiones, vinculosEquipo, cargando, error, recargar };
}
