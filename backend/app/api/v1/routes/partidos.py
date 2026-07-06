from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.partido import PartidoCreate, PartidoRead, PartidoResultado, PartidoUpdate
from app.services.partido_service import partido_service

router = APIRouter(prefix="/partidos", tags=["Partidos"])


@router.post("", response_model=PartidoRead, status_code=status.HTTP_201_CREATED)
def crear_partido(datos: PartidoCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return partido_service.crear(db, usuario_id, datos)


@router.get("/jornada/{jornada_id}", response_model=list[PartidoRead])
def listar_partidos_de_jornada(jornada_id: int, db: Session = Depends(get_db)):
    return partido_service.listar_por_jornada(db, jornada_id)


@router.get("/{partido_id}", response_model=PartidoRead)
def obtener_partido(partido_id: int, db: Session = Depends(get_db)):
    return partido_service.obtener(db, partido_id)


@router.patch("/{partido_id}", response_model=PartidoRead)
def actualizar_partido(
    partido_id: int, datos: PartidoUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return partido_service.actualizar(db, usuario_id, partido_id, datos)


@router.post("/{partido_id}/resultado", response_model=PartidoRead)
def registrar_resultado(
    partido_id: int,
    datos: PartidoResultado,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return partido_service.registrar_resultado(db, usuario_id, partido_id, datos)


@router.delete("/{partido_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_partido(partido_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    partido_service.eliminar(db, usuario_id, partido_id)
