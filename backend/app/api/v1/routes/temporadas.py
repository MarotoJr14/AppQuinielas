from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.temporada import TemporadaCreate, TemporadaRead, TemporadaUpdate
from app.services.temporada_service import temporada_service

router = APIRouter(prefix="/temporadas", tags=["Temporadas"])


@router.post("", response_model=TemporadaRead, status_code=status.HTTP_201_CREATED)
def crear_temporada(
    datos: TemporadaCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return temporada_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[TemporadaRead])
def listar_temporadas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return temporada_service.listar(db, skip, limit)


@router.get("/{temporada_id}", response_model=TemporadaRead)
def obtener_temporada(temporada_id: int, db: Session = Depends(get_db)):
    return temporada_service.obtener(db, temporada_id)


@router.patch("/{temporada_id}", response_model=TemporadaRead)
def actualizar_temporada(
    temporada_id: int,
    datos: TemporadaUpdate,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return temporada_service.actualizar(db, usuario_id, temporada_id, datos)


@router.delete("/{temporada_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_temporada(
    temporada_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    temporada_service.eliminar(db, usuario_id, temporada_id)
