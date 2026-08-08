from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.temporada_competicion import TemporadaCompeticion
from app.repositories.base import BaseRepository


class TemporadaCompeticionRepository(BaseRepository[TemporadaCompeticion]):
    def __init__(self):
        super().__init__(TemporadaCompeticion)

    def list_por_temporada(self, db: Session, temporada_id: int) -> list[TemporadaCompeticion]:
        stmt = select(TemporadaCompeticion).where(TemporadaCompeticion.temporada_id == temporada_id)
        return list(db.scalars(stmt).all())


temporada_competicion_repository = TemporadaCompeticionRepository()
