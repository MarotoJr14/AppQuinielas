import { useEffect, useRef, useState } from 'react';
import type { Equipo } from '../types/models';

interface TeamPickerProps {
  equipos: Equipo[];
  valor: number | null;
  onSeleccionar: (equipoId: number) => void;
  onCrear: (nombre: string) => Promise<Equipo>;
  placeholder?: string;
}

/**
 * Combobox de equipo: permite buscar entre los equipos existentes o crear
 * uno nuevo al vuelo (igual que el selector de la app móvil), sin salir de
 * la tabla de partidos.
 */
export function TeamPicker({ equipos, valor, onSeleccionar, onCrear, placeholder }: TeamPickerProps) {
  const [abierto, setAbierto] = useState(false);
  const [busqueda, setBusqueda] = useState('');
  const [creando, setCreando] = useState(false);
  const contenedorRef = useRef<HTMLDivElement>(null);

  const equipoActual = equipos.find((e) => e.id === valor) ?? null;

  useEffect(() => {
    function alClicarFuera(evento: MouseEvent) {
      if (contenedorRef.current && !contenedorRef.current.contains(evento.target as Node)) {
        setAbierto(false);
        setBusqueda('');
      }
    }
    document.addEventListener('mousedown', alClicarFuera);
    return () => document.removeEventListener('mousedown', alClicarFuera);
  }, []);

  const filtrados = equipos
    .filter((e) => e.nombre.toLowerCase().includes(busqueda.toLowerCase()))
    .slice(0, 40);

  const coincidenciaExacta = equipos.some((e) => e.nombre.toLowerCase() === busqueda.trim().toLowerCase());

  async function handleCrear() {
    const nombre = busqueda.trim();
    if (!nombre || creando) return;
    setCreando(true);
    try {
      const nuevo = await onCrear(nombre);
      onSeleccionar(nuevo.id);
      setAbierto(false);
      setBusqueda('');
    } finally {
      setCreando(false);
    }
  }

  return (
    <div className="combobox" ref={contenedorRef}>
      <button
        type="button"
        className="celda-equipo__boton"
        onClick={() => {
          setAbierto((actual) => !actual);
          setBusqueda('');
        }}
      >
        {equipoActual ? equipoActual.nombre : placeholder ?? 'Seleccionar equipo'}
      </button>
      {abierto ? (
        <div className="combobox__lista">
          <div style={{ padding: 8 }}>
            <input
              autoFocus
              className="input"
              placeholder="Buscar o crear equipo..."
              value={busqueda}
              onChange={(evento) => setBusqueda(evento.target.value)}
              onKeyDown={(evento) => {
                if (evento.key === 'Enter' && filtrados.length === 0 && busqueda.trim()) {
                  void handleCrear();
                }
              }}
            />
          </div>
          {filtrados.map((equipo) => (
            <div
              key={equipo.id}
              className="combobox__opcion"
              onClick={() => {
                onSeleccionar(equipo.id);
                setAbierto(false);
                setBusqueda('');
              }}
            >
              <span>{equipo.nombre}</span>
              <span className="combobox__opcion-pais">{equipo.pais}</span>
            </div>
          ))}
          {busqueda.trim().length > 1 && !coincidenciaExacta ? (
            <div className="combobox__opcion combobox__crear" onClick={() => void handleCrear()}>
              {creando ? 'Creando…' : `+ Crear "${busqueda.trim()}"`}
            </div>
          ) : null}
          {filtrados.length === 0 && busqueda.trim().length <= 1 ? (
            <div className="combobox__opcion texto-secundario">Escribe para buscar o crear un equipo.</div>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
