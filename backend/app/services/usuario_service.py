from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models.usuario import Usuario
from app.repositories.usuario_repository import usuario_repository
from app.schemas.usuario import UsuarioUpdate


class UsuarioService:
    def obtener(self, db: Session, usuario_id: int) -> Usuario:
        return usuario_repository.get_or_404(db, usuario_id)

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[Usuario]:
        return usuario_repository.list(db, skip, limit)

    def actualizar(self, db: Session, usuario_id: int, datos: UsuarioUpdate) -> Usuario:
        usuario = usuario_repository.get_or_404(db, usuario_id)
        if datos.nombre_usuario and datos.nombre_usuario != usuario.nombre_usuario:
            existente = usuario_repository.get_by_nombre_usuario(db, datos.nombre_usuario)
            if existente is not None:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT, detail="El nombre de usuario ya está en uso."
                )
            usuario.nombre_usuario = datos.nombre_usuario
        if datos.password:
            usuario.password_hash = hash_password(datos.password)
        db.add(usuario)
        db.commit()
        db.refresh(usuario)
        return usuario

    def eliminar(self, db: Session, usuario_id: int) -> None:
        usuario = usuario_repository.get_or_404(db, usuario_id)
        usuario_repository.delete(db, usuario)


usuario_service = UsuarioService()
