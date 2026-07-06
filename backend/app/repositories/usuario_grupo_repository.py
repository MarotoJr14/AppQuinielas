from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.usuario_grupo import UsuarioGrupo
from app.repositories.base import BaseRepository


class UsuarioGrupoRepository(BaseRepository[UsuarioGrupo]):
    def __init__(self):
        super().__init__(UsuarioGrupo)

    def get_by_grupo_usuario(self, db: Session, grupo_id: int, usuario_id: int) -> UsuarioGrupo | None:
        stmt = select(UsuarioGrupo).where(
            UsuarioGrupo.grupo_id == grupo_id, UsuarioGrupo.usuario_id == usuario_id
        )
        return db.scalars(stmt).first()

    def get_lider(self, db: Session, grupo_id: int) -> UsuarioGrupo | None:
        stmt = select(UsuarioGrupo).where(UsuarioGrupo.grupo_id == grupo_id, UsuarioGrupo.es_lider.is_(True))
        return db.scalars(stmt).first()

    def list_por_grupo(self, db: Session, grupo_id: int) -> list[UsuarioGrupo]:
        stmt = select(UsuarioGrupo).where(UsuarioGrupo.grupo_id == grupo_id)
        return list(db.scalars(stmt).all())


usuario_grupo_repository = UsuarioGrupoRepository()
