from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.temporada_competicion import TemporadaCompeticionCreate, TemporadaCompeticionRead
from app.services.temporada_competicion_service import temporada_competicion_service

router = APIRouter(prefix="/temporada-competiciones", tags=["Temporada-Competición"])


@router.post("", response_model=TemporadaCompeticionRead, status_code=status.HTTP_201_CREATED)
def crear(
    datos: TemporadaCompeticionCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return temporada_competicion_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[TemporadaCompeticionRead])
def listar(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return temporada_competicion_service.listar(db, skip, limit)


@router.get("/{id}", response_model=TemporadaCompeticionRead)
def obtener(id: int, db: Session = Depends(get_db)):
    return temporada_competicion_service.obtener(db, id)


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar(id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    temporada_competicion_service.eliminar(db, usuario_id, id)
