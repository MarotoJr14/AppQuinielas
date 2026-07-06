from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.equipo import EquipoCreate, EquipoRead, EquipoUpdate
from app.services.equipo_service import equipo_service

router = APIRouter(prefix="/equipos", tags=["Equipos"])


@router.post("", response_model=EquipoRead, status_code=status.HTTP_201_CREATED)
def crear_equipo(datos: EquipoCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return equipo_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[EquipoRead])
def listar_equipos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return equipo_service.listar(db, skip, limit)


@router.get("/{equipo_id}", response_model=EquipoRead)
def obtener_equipo(equipo_id: int, db: Session = Depends(get_db)):
    return equipo_service.obtener(db, equipo_id)


@router.patch("/{equipo_id}", response_model=EquipoRead)
def actualizar_equipo(
    equipo_id: int, datos: EquipoUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return equipo_service.actualizar(db, usuario_id, equipo_id, datos)


@router.delete("/{equipo_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_equipo(equipo_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    equipo_service.eliminar(db, usuario_id, equipo_id)
