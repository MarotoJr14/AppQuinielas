from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.equipo_temporada_competicion import (
    EquipoTemporadaCompeticionCreate,
    EquipoTemporadaCompeticionRead,
)
from app.services.equipo_temporada_competicion_service import equipo_temporada_competicion_service

router = APIRouter(prefix="/equipo-temporada-competiciones", tags=["Equipo-Temporada-Competición"])


@router.post("", response_model=EquipoTemporadaCompeticionRead, status_code=status.HTTP_201_CREATED)
def crear(
    datos: EquipoTemporadaCompeticionCreate,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return equipo_temporada_competicion_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[EquipoTemporadaCompeticionRead])
def listar(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return equipo_temporada_competicion_service.listar(db, skip, limit)


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar(id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    equipo_temporada_competicion_service.eliminar(db, usuario_id, id)
