from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.mensaje import MensajeCreate, MensajeRead
from app.services.mensaje_service import mensaje_service

router = APIRouter(prefix="/mensajes", tags=["Chat del grupo"])


@router.post("", response_model=MensajeRead, status_code=status.HTTP_201_CREATED)
def enviar_mensaje(datos: MensajeCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return mensaje_service.enviar(db, usuario_id, datos)


@router.get("/grupo/{grupo_id}", response_model=list[MensajeRead])
def listar_mensajes(
    grupo_id: int,
    skip: int = 0,
    limit: int = 50,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    return mensaje_service.listar_por_grupo(db, usuario_id, grupo_id, skip, limit)
