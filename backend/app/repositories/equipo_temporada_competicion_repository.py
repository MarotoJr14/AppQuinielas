from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion
from app.repositories.base import BaseRepository


class EquipoTemporadaCompeticionRepository(BaseRepository[EquipoTemporadaCompeticion]):
    def __init__(self):
        super().__init__(EquipoTemporadaCompeticion)


equipo_temporada_competicion_repository = EquipoTemporadaCompeticionRepository()
