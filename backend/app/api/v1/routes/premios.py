from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.premio_jornada import PremioJornadaCreate, PremioJornadaRead, PremioJornadaUpdate
from app.services.premio_jornada_service import premio_jornada_service

router = APIRouter(prefix="/premios", tags=["Premios"])


@router.post("", response_model=PremioJornadaRead, status_code=status.HTTP_201_CREATED)
def crear_premio(
    datos: PremioJornadaCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return premio_jornada_service.crear(db, usuario_id, datos)


@router.get("/jornada/{jornada_id}", response_model=list[PremioJornadaRead])
def listar_premios_de_jornada(jornada_id: int, db: Session = Depends(get_db)):
    return premio_jornada_service.listar_por_jornada(db, jornada_id)


@router.patch("/{premio_id}", response_model=PremioJornadaRead)
def actualizar_premio(
    premio_id: int,
    datos: PremioJornadaUpdate,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return premio_jornada_service.actualizar(db, usuario_id, premio_id, datos)


@router.delete("/{premio_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_premio(premio_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    premio_jornada_service.eliminar(db, usuario_id, premio_id)
