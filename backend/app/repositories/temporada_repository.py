from app.models.temporada import Temporada
from app.repositories.base import BaseRepository


class TemporadaRepository(BaseRepository[Temporada]):
    def __init__(self):
        super().__init__(Temporada)


temporada_repository = TemporadaRepository()
