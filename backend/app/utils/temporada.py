from fastapi import HTTPException, status

from app.models.enums import EstadoTemporadaEnum


def validar_temporada_activa(temporada: object) -> None:
    """Valida que la temporada no esté finalizada."""
    if getattr(temporada, "estado", None) == EstadoTemporadaEnum.finalizada:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="La temporada está finalizada.",
        )
