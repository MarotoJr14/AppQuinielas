# Quinielas App — Frontend (Flutter)

Aplicación Flutter para la gestión de quinielas por grupos (peñas), que consume
la API del backend (`backend/`). Cubre **todas las pantallas** descritas en
`frontend.md`.

## Puesta en marcha

Este entregable contiene el código fuente (`lib/`, `pubspec.yaml`,
`analysis_options.yaml`). Como aquí no se dispone del SDK de Flutter para
generar los proyectos nativos, hay que scaffoldear las carpetas de
plataforma la primera vez:

```bash
cd frontend
flutter create --org com.quinielas --project-name quinielas_app .
```

Esto generará `android/`, `ios/`, `web/`, etc. **sin sobrescribir** `lib/`,
`pubspec.yaml` ni `analysis_options.yaml` (Flutter detecta que ya existen y
solo añade lo que falta). Después:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

- **Emulador Android**: si el backend corre en tu máquina, usa
  `http://10.0.2.2:8000/api/v1` en lugar de `localhost`.
- **Web/escritorio**: `http://localhost:8000/api/v1` funciona directamente
  si el backend está levantado con `docker compose up` (ver `backend/README.md`).
- Si no se pasa `--dart-define`, se usa por defecto `http://localhost:8000/api/v1`
  (ver `lib/core/constants.dart`).

## Estructura

```
lib/
├── main.dart                  # Providers, tema y rutas
├── core/
│   ├── constants.dart         # URL de la API, id del admin, claves de SharedPreferences
│   └── theme/                 # Colores y ThemeData claro/oscuro (paleta de frontend.md)
├── models/                    # Modelos de dominio (Usuario, Grupo, Jornada, Apuesta...)
├── services/                  # Un servicio por entidad, todos sobre un ApiClient común
├── state/                     # AuthProvider (sesión + servicios), GroupProvider (peña activa), ThemeProvider
├── widgets/                   # AppScaffold, AppHeader, AppDrawer, selectores 1X2/goles, estados comunes
├── utils/                     # Lógica de clasificación pendiente/en curso/finalizada
└── screens/
    ├── auth/                  # Login, Registro, Recuperar contraseña
    ├── home/                  # Home, Crear/Unirse grupo, Mi cuenta, Administración (temporadas/jornadas/partidos/premios)
    └── group/                 # Dashboard, Nueva quiniela, Cola, En curso, Resultados, Estadísticas, Chat, Configuración
```

## Decisiones y simplificaciones de esta primera versión

- **Estado "en curso" / "finalizada" derivado en cliente.** El backend solo
  transiciona `pendiente -> cerrada` (vía "Cerrar quiniela"). Para distinguir
  "en curso" de "finalizada" tal y como pide `frontend.md`, el frontend
  comprueba si los 15 partidos de la jornada ya tienen resultado
  (`lib/utils/apuesta_utils.dart`): cerrada + incompleta = en curso; cerrada +
  completa = finalizada. Si en el futuro se añade lógica de negocio en el
  backend para fijar esos estados explícitamente, bastaría con leer
  `apuesta.estado` directamente.
- **Tabla de quiniela.** Una única pantalla (`queue_detail_screen.dart`) sirve
  para "Quinielas en cola", "Ver quiniela en curso" y "Últimos resultados":
  se vuelve de solo lectura (con coloreado verde/rojo de aciertos) en cuanto
  la apuesta deja de estar pendiente, y añade la tabla de premios cuando la
  jornada está completa.
- **Columna Elige 8.** Al crearla, cada uno de los 14 partidos normales se
  "activa" copiando el pronóstico ya guardado en la columna normal del mismo
  usuario (no se puede introducir un valor distinto, tal y como exige el
  backend), con un límite de 8 activaciones. El partido 15 usa el selector de
  goles (0/1/2/M) por separado para local y visitante.
- **Notificaciones** al crear una quiniela (mencionadas en `frontend.md`) no
  están implementadas todavía (requieren un canal push/WebSocket en el
  backend); queda como trabajo pendiente.
- El **refresco del chat** se hace por *polling* cada 5 segundos, no por
  WebSocket, para mantener el frontend simple en esta primera versión.

## Temas

Se respeta la paleta de `frontend.md` (`lib/core/theme/app_colors.dart`):
fondo claro `#F8F7F4`, fondo oscuro `#121212`, acento `#C9A227`, aciertos
`#2E8B57`, errores `#C94A4A`. La app arranca en tema claro y el usuario puede
alternarlo desde el icono de sol/luna en la cabecera; la elección se persiste
con `shared_preferences`.
