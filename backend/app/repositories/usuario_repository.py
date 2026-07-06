from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.usuario import Usuario
from app.repositories.base import BaseRepository


class UsuarioRepository(BaseRepository[Usuario]):
    def __init__(self):
        super().__init__(Usuario)

    def get_by_nombre_usuario(self, db: Session, nombre_usuario: str) -> Usuario | None:
        stmt = select(Usuario).where(Usuario.nombre_usuario == nombre_usuario)
        return db.scalars(stmt).first()

    def get_by_email(self, db: Session, email: str) -> Usuario | None:
        stmt = select(Usuario).where(Usuario.email == email)
        return db.scalars(stmt).first()


usuario_repository = UsuarioRepository()
