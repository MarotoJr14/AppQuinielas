from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion
from app.repositories.base import BaseRepository


class EquipoTemporadaCompeticionRepository(BaseRepository[EquipoTemporadaCompeticion]):
    def __init__(self):
        super().__init__(EquipoTemporadaCompeticion)

    def list_por_competicion_temporada(
        self, db: Session, temporada_competicion_id: int
    ) -> list[EquipoTemporadaCompeticion]:
        stmt = select(EquipoTemporadaCompeticion).where(
            EquipoTemporadaCompeticion.temporada_competicion_id == temporada_competicion_id
        )
        return list(db.scalars(stmt).all())


equipo_temporada_competicion_repository = EquipoTemporadaCompeticionRepository()
