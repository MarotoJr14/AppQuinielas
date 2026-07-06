from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.jornada import JornadaCreate, JornadaRead, JornadaUpdate
from app.services.jornada_service import jornada_service

router = APIRouter(prefix="/jornadas", tags=["Jornadas"])


@router.post("", response_model=JornadaRead, status_code=status.HTTP_201_CREATED)
def crear_jornada(datos: JornadaCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return jornada_service.crear(db, usuario_id, datos)


@router.get("", response_model=list[JornadaRead])
def listar_jornadas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return jornada_service.listar(db, skip, limit)


@router.get("/disponibles/{grupo_id}", response_model=list[JornadaRead])
def listar_jornadas_disponibles(grupo_id: int, db: Session = Depends(get_db)):
    return jornada_service.listar_disponibles_para_grupo(db, grupo_id)


@router.get("/{jornada_id}", response_model=JornadaRead)
def obtener_jornada(jornada_id: int, db: Session = Depends(get_db)):
    return jornada_service.obtener(db, jornada_id)


@router.patch("/{jornada_id}", response_model=JornadaRead)
def actualizar_jornada(
    jornada_id: int, datos: JornadaUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return jornada_service.actualizar(db, usuario_id, jornada_id, datos)


@router.delete("/{jornada_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_jornada(jornada_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    jornada_service.eliminar(db, usuario_id, jornada_id)
