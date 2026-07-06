from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.usuario import UsuarioRead, UsuarioUpdate
from app.services.usuario_service import usuario_service

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.get("/me", response_model=UsuarioRead)
def obtener_mi_usuario(usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return usuario_service.obtener(db, usuario_id)


@router.get("/{usuario_id}", response_model=UsuarioRead)
def obtener_usuario(usuario_id: int, db: Session = Depends(get_db)):
    return usuario_service.obtener(db, usuario_id)


@router.get("", response_model=list[UsuarioRead])
def listar_usuarios(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return usuario_service.listar(db, skip, limit)


@router.patch("/me", response_model=UsuarioRead)
def actualizar_mi_usuario(
    datos: UsuarioUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return usuario_service.actualizar(db, usuario_id, datos)


@router.delete("/me", status_code=204)
def eliminar_mi_usuario(usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    usuario_service.eliminar(db, usuario_id)
