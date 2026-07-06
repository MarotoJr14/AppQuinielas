# Quinielas API — Backend

Backend de la aplicación de gestión de quinielas por grupos (peñas), construido con
**FastAPI** + **SQLAlchemy 2.0** + **Alembic** sobre **PostgreSQL**.

## Stack

- **Base de datos:** PostgreSQL 16
- **ORM / Migraciones:** SQLAlchemy 2.0 (estilo `Mapped`/`mapped_column`) + Alembic
- **API:** FastAPI (documentación automática vía Swagger/OpenAPI)
- **Auth:** JWT (OAuth2 Password Flow) + bcrypt para hashes de contraseña

## Estructura del proyecto

```
backend/
├── alembic/                # Migraciones de base de datos
│   └── versions/
├── app/
│   ├── api/v1/
│   │   ├── routes/         # Endpoints REST, uno por entidad
│   │   ├── api.py          # Agregador de routers
│   │   └── deps.py         # Dependencias de autenticación (JWT)
│   ├── core/                # Configuración (settings) y seguridad (JWT, hashing)
│   ├── db/                  # Sesión, clase base declarativa, dependencia get_db
│   ├── models/               # Modelos SQLAlchemy (16 tablas) + enums.py
│   ├── repositories/         # Capa de acceso a datos (CRUD genérico + queries específicas)
│   ├── schemas/               # Esquemas Pydantic (request/response)
│   ├── services/               # Lógica de negocio (permisos, precio/beneficio, scoring...)
│   └── utils/                   # Utilidades (permisos de admin, evaluación de aciertos)
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
└── requirements.txt
```

## Modelo de datos

16 tablas, fieles al diseño acordado en `database.md`:

`usuarios`, `grupos`, `usuarios_grupos`, `temporadas`, `jornadas`, `premios_jornada`,
`competiciones`, `temporadas_competiciones`, `equipos`, `equipos_temporadas_competiciones`,
`partidos`, `apuestas`, `columnas`, `pronosticos`, `mensajes`, `audit_logs`.

Restricciones clave implementadas a nivel de base de datos:
- Un usuario no puede repetirse en un mismo grupo (`UNIQUE(grupo_id, usuario_id)`).
- **Solo puede haber un líder por grupo** (índice único parcial `WHERE es_lider = true`).
- **Solo puede haber una columna Elige 8 por apuesta** (índice único parcial `WHERE es_elige8 = true`).
- Un grupo no puede apostar dos veces a la misma jornada (`UNIQUE(jornada_id, grupo_id)`).
- Un pronóstico es único por columna y partido (`UNIQUE(columna_id, partido_id)`).

## Lógica de negocio implementada

- **Registro/login** con validaciones de usuario (minúsculas/alfanumérico), contraseña
  segura y recuperación de contraseña.
- **Grupos (peñas):** creación (el creador es líder), unión mediante nombre+contraseña,
  cambio de líder, listado de grupos del usuario con búsqueda.
- **Jornadas disponibles para un grupo:** excluye jornadas ya cerradas o ya apostadas.
- **Columnas y pronósticos:**
  - Solo el usuario asignado puede rellenar la columna Elige 8 de una apuesta.
  - Los pronósticos de la columna Elige 8 deben coincidir con los de la columna normal
    del mismo usuario, y se limitan a 8 partidos 1X2 + el Pleno al 15.
  - Una apuesta cerrada no admite más cambios.
- **Cálculo de precio:** 0,50 € (columna Elige 8) + 0,75 € × nº de columnas normales.
- **Cálculo de beneficio:** suma de los premios de categoría según aciertos de cada
  columna normal (10 a 15 aciertos) + premio Elige 8 si esa columna no tiene fallos.
- **Evaluación de aciertos:** signo 1X2 para partidos normales; en el partido 15,
  la columna Elige 8 usa el Pleno al 15 (goles 0/1/2/M) y el resto usa 1X2.
- **Ranking de una quiniela:** Elige 8 primero (verde si 0 fallos), después columnas
  normales ordenadas por aciertos (verde si ≤4 fallos).
- **Chat de grupo:** mensajes visibles solo para miembros del grupo.
- El **usuario con `id=1` es el administrador del sistema** y es el único que puede
  gestionar temporadas, jornadas, partidos, resultados, competiciones, equipos y premios.

## Puesta en marcha

### Con Docker (recomendado)

```bash
cp .env.example .env
docker compose up --build
```

Esto levanta PostgreSQL, aplica las migraciones automáticamente (`entrypoint.sh`) y
arranca la API en `http://localhost:8000`.

- Documentación interactiva (Swagger): `http://localhost:8000/api/v1/docs`
- Redoc: `http://localhost:8000/api/v1/redoc`

### Manualmente

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # y ajustar POSTGRES_HOST=localhost si no usas Docker
alembic upgrade head
uvicorn app.main:app --reload
```

## Migraciones

Tras modificar cualquier modelo en `app/models/`:

```bash
alembic revision --autogenerate -m "descripcion del cambio"
alembic upgrade head
```

## Notas

- El backend ha sido verificado end-to-end (registro, login, creación de grupo,
  jornada, partidos, apuesta, columnas normal y Elige 8, resultados, cálculo de
  aciertos/precio/beneficio, ranking y cierre de quiniela) contra una base de datos
  PostgreSQL real.
- El campo `es_lider` y `es_elige8` usan índices únicos parciales de PostgreSQL, por
  lo que **la base de datos debe ser PostgreSQL** (no es portable a SQLite sin ajustes).
