from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.competicion import CompeticionCreate, CompeticionRead, CompeticionUpdate
from app.services.competicion_service import competicion_service

router = APIRouter(prefix="/competiciones", tags=["Competiciones"])


@router.post("", response_model=CompeticionRead, status_code=status.HTTP_201_CREATED)
def crear_competicion(
    datos: CompeticionCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return competicion_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[CompeticionRead])
def listar_competiciones(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return competicion_service.listar(db, skip, limit)


@router.get("/{competicion_id}", response_model=CompeticionRead)
def obtener_competicion(competicion_id: int, db: Session = Depends(get_db)):
    return competicion_service.obtener(db, competicion_id)


@router.patch("/{competicion_id}", response_model=CompeticionRead)
def actualizar_competicion(
    competicion_id: int,
    datos: CompeticionUpdate,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return competicion_service.actualizar(db, usuario_id, competicion_id, datos)


@router.delete("/{competicion_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_competicion(
    competicion_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    competicion_service.eliminar(db, usuario_id, competicion_id)
