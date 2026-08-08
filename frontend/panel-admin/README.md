# Quinielas — Panel de administración (React + Vite + Axios)

Plataforma web independiente para la administración del sistema, en paralelo
a la app móvil (que no se ve modificada). Cubre exactamente lo que en
`frontend.md` corresponde a la sección "Administración del sistema":
gestión de temporadas, jornadas, sus 15 partidos (equipos, fecha/canal,
resultados), premios por categoría de aciertos, y el catálogo global de
equipos. Consume la misma API del `backend/` que usa la app móvil.

## Puesta en marcha

```bash
cd admin-panel
npm install
cp .env.example .env   # ajustar VITE_API_BASE_URL si el backend no está en localhost:8000
npm run dev
```

Por defecto arranca en http://localhost:5173 y apunta a
http://localhost:8000/api/v1 (el backend levantado con
`docker compose up` desde `backend/`).

```bash
npm run build     # build de producción (tsc -b && vite build) -> dist/
npm run preview   # sirve el build de producción localmente
```

## Acceso

Se entra con las mismas credenciales de usuario que en la app móvil
(`POST /auth/login`). El backend restringe todas las operaciones de
administración al usuario con id=1; si inicias sesión con otra cuenta,
el panel lo detecta (`GET /usuarios/me`) y no te deja entrar, mostrando un
aviso claro en vez de dejarte en una pantalla a medias.

## Estructura

```
src/
├── api/            # Una función por endpoint, todas sobre un axios.create() común (api/client.ts)
├── components/      # Layout (sidebar + topbar), Button, Input/Select, Modal, ConfirmDialog,
│                     # TeamPicker (combobox de equipos con creación al vuelo), estados de carga/error/vacío
├── context/          # AuthContext (sesión + guard de admin), ThemeContext (claro/oscuro), ToastContext
├── pages/
│   ├── LoginPage.tsx
│   ├── JornadasPage.tsx          # Jornadas: tabla, filtro por temporada, nueva/importar jornada
│   ├── JornadaDetailPage.tsx    # Tabla de los 15 partidos, edición inline, resultados, premios
│   ├── TemporadasPage.tsx        # Temporadas: tabla, ficha, CRUD (sin importación masiva)
│   ├── CompeticionesPage.tsx     # Competiciones: tabla, filtro, ficha, CRUD, importación masiva
│   └── EquiposPage.tsx           # Equipos: tabla, filtro, ficha, CRUD, importación masiva
├── styles/theme.css  # Variables de color (mismas que la app: fondo, acento #C9A227, aciertos, errores)
└── utils/fechas.ts   # Conversión entre <input datetime-local> y el ISO/UTC que espera el backend
```

## Decisiones de diseño

- Mismo tema que la app móvil: paleta exacta (#F8F7F4 / #121212 /
  acento #C9A227 / aciertos #2E8B57 / errores #C94A4A), con toggle
  claro/oscuro persistido en localStorage (arranca en claro, igual que la
  app).
- Responsive: sidebar fija en escritorio; en pantallas ≤900px se
  convierte en panel deslizante activado por el botón ☰ de la barra
  superior, con overlay para cerrar.
- Flujo intuitivo: la tabla de partidos permite asignar equipos (con
  buscador que también crea el equipo si no existe, igual que en la app) y
  guardar resultados directamente en la fila, sin pasos intermedios. Crear
  una jornada nueva navega automáticamente a su detalle para continuar con
  "Crear 15 partidos".
- Sin duplicar lógica de negocio: todas las validaciones (unicidad,
  permisos de administrador, etc.) las aplica el backend; el panel solo
  se limita a mostrar los mensajes de error tal cual los devuelve la API.

## Verificado

- `npx tsc -b` sin errores.
- `npm run build` genera dist/ correctamente.
- `npm run preview` sirve la build y responde 200 en /.
