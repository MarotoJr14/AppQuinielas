from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.grupo import GrupoCreate, GrupoJoin, GrupoRead, GrupoUpdate
from app.schemas.usuario_grupo import UsuarioGrupoRead
from app.services.grupo_service import grupo_service

router = APIRouter(prefix="/grupos", tags=["Grupos (peñas)"])


@router.post("", response_model=GrupoRead, status_code=status.HTTP_201_CREATED)
def crear_grupo(datos: GrupoCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return grupo_service.crear(db, usuario_id, datos)


@router.post("/unirse", response_model=UsuarioGrupoRead, status_code=status.HTTP_201_CREATED)
def unirse_a_grupo(datos: GrupoJoin, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return grupo_service.unirse(db, usuario_id, datos)


@router.get("", response_model=list[GrupoRead])
def listar_mis_grupos(
    search: str | None = None, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return grupo_service.listar_de_usuario(db, usuario_id, search)


@router.get("/{grupo_id}", response_model=GrupoRead)
def obtener_grupo(grupo_id: int, db: Session = Depends(get_db)):
    return grupo_service.obtener(db, grupo_id)


@router.patch("/{grupo_id}", response_model=GrupoRead)
def actualizar_grupo(
    grupo_id: int, datos: GrupoUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return grupo_service.actualizar(db, grupo_id, usuario_id, datos)


@router.get("/{grupo_id}/miembros", response_model=list[UsuarioGrupoRead])
def listar_miembros(grupo_id: int, db: Session = Depends(get_db)):
    return grupo_service.listar_miembros(db, grupo_id)


@router.post("/{grupo_id}/lider/{nuevo_lider_id}", status_code=status.HTTP_204_NO_CONTENT)
def cambiar_lider(
    grupo_id: int,
    nuevo_lider_id: int,
    usuario_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    grupo_service.cambiar_lider(db, grupo_id, usuario_id, nuevo_lider_id)
