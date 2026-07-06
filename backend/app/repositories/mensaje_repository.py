from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.mensaje import Mensaje
from app.repositories.base import BaseRepository


class MensajeRepository(BaseRepository[Mensaje]):
    def __init__(self):
        super().__init__(Mensaje)

    def list_por_grupo(self, db: Session, grupo_id: int, skip: int = 0, limit: int = 50) -> list[Mensaje]:
        stmt = (
            select(Mensaje)
            .where(Mensaje.grupo_id == grupo_id)
            .order_by(Mensaje.enviado_en.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(db.scalars(stmt).all())


mensaje_repository = MensajeRepository()
