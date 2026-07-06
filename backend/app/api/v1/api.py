from fastapi import APIRouter

from app.api.v1.routes import (
    apuestas,
    audit_logs,
    auth,
    columnas,
    competiciones,
    equipo_temporada_competiciones,
    equipos,
    grupos,
    jornadas,
    mensajes,
    partidos,
    premios,
    temporada_competiciones,
    temporadas,
    users,
)

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(grupos.router)
api_router.include_router(temporadas.router)
api_router.include_router(jornadas.router)
api_router.include_router(premios.router)
api_router.include_router(competiciones.router)
api_router.include_router(temporada_competiciones.router)
api_router.include_router(equipos.router)
api_router.include_router(equipo_temporada_competiciones.router)
api_router.include_router(partidos.router)
api_router.include_router(apuestas.router)
api_router.include_router(columnas.router)
api_router.include_router(mensajes.router)
api_router.include_router(audit_logs.router)
