from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.premio_jornada import PremioJornada
from app.repositories.base import BaseRepository


class PremioJornadaRepository(BaseRepository[PremioJornada]):
    def __init__(self):
        super().__init__(PremioJornada)

    def list_por_jornada(self, db: Session, jornada_id: int) -> list[PremioJornada]:
        stmt = select(PremioJornada).where(PremioJornada.jornada_id == jornada_id)
        return list(db.scalars(stmt).all())


premio_jornada_repository = PremioJornadaRepository()
