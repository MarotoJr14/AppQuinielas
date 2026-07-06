from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.grupo import Grupo
from app.repositories.base import BaseRepository


class GrupoRepository(BaseRepository[Grupo]):
    def __init__(self):
        super().__init__(Grupo)

    def get_by_nombre(self, db: Session, nombre: str) -> Grupo | None:
        stmt = select(Grupo).where(Grupo.nombre == nombre)
        return db.scalars(stmt).first()

    def list_por_usuario(self, db: Session, usuario_id: int, search: str | None = None) -> list[Grupo]:
        from app.models.usuario_grupo import UsuarioGrupo

        stmt = select(Grupo).join(UsuarioGrupo, UsuarioGrupo.grupo_id == Grupo.id).where(
            UsuarioGrupo.usuario_id == usuario_id
        )
        if search:
            stmt = stmt.where(Grupo.nombre.ilike(f"%{search}%"))
        return list(db.scalars(stmt).all())


grupo_repository = GrupoRepository()
