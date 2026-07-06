from app.models.temporada_competicion import TemporadaCompeticion
from app.repositories.base import BaseRepository


class TemporadaCompeticionRepository(BaseRepository[TemporadaCompeticion]):
    def __init__(self):
        super().__init__(TemporadaCompeticion)


temporada_competicion_repository = TemporadaCompeticionRepository()
