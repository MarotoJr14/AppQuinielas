from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.partido import Partido
from app.repositories.base import BaseRepository


class PartidoRepository(BaseRepository[Partido]):
    def __init__(self):
        super().__init__(Partido)

    def list_por_jornada(self, db: Session, jornada_id: int) -> list[Partido]:
        stmt = select(Partido).where(Partido.jornada_id == jornada_id).order_by(Partido.orden)
        return list(db.scalars(stmt).all())


partido_repository = PartidoRepository()
