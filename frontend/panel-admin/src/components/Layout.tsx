import { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';

const ENLACES = [
  { to: '/', etiqueta: 'Jornadas', icono: '🗓️', fin: true },
  { to: '/temporadas', etiqueta: 'Temporadas', icono: '📅' },
  { to: '/competiciones', etiqueta: 'Competiciones', icono: '🏆' },
  { to: '/equipos', etiqueta: 'Equipos', icono: '⚽' },
];

export function Layout() {
  const [sidebarAbierta, setSidebarAbierta] = useState(false);
  const { usuario, cerrarSesion } = useAuth();
  const { tema, alternarTema } = useTheme();

  function cerrarSidebar() {
    setSidebarAbierta(false);
  }

  return (
    <div className="app-shell">
      <div className={`overlay-sidebar ${sidebarAbierta ? 'abierta' : ''}`} onClick={cerrarSidebar} />
      <aside className={`sidebar ${sidebarAbierta ? 'abierta' : ''}`}>
        <div className="sidebar__logo">
          <div className="sidebar__logo-icono">Q</div>
          <div>
            <div className="sidebar__logo-texto">Quinielas</div>
            <div className="sidebar__logo-subtexto">Administración</div>
          </div>
        </div>
        <nav className="sidebar__nav">
          {ENLACES.map((enlace) => (
            <NavLink
              key={enlace.to}
              to={enlace.to}
              end={enlace.fin}
              className={({ isActive }) => `sidebar__link ${isActive ? 'activo' : ''}`}
              onClick={cerrarSidebar}
            >
              <span>{enlace.icono}</span>
              <span>{enlace.etiqueta}</span>
            </NavLink>
          ))}
        </nav>
        <div className="sidebar__pie">
          <div className="texto-secundario">Sesión de {usuario?.nombre_usuario}</div>
          <button className="boton boton--secundario boton--chico" onClick={cerrarSesion}>
            Cerrar sesión
          </button>
        </div>
      </aside>

      <div className="contenido">
        <header className="topbar">
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <button
              className="boton boton--icono topbar__menu-boton"
              onClick={() => setSidebarAbierta(true)}
              aria-label="Abrir menú"
            >
              ☰
            </button>
            <span className="topbar__titulo">Panel de administración</span>
          </div>
          <div className="topbar__acciones">
            <button
              className="boton boton--icono"
              onClick={alternarTema}
              title={tema === 'oscuro' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'}
            >
              {tema === 'oscuro' ? '☀️' : '🌙'}
            </button>
          </div>
        </header>
        <main className="pagina">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
