from app.models.equipo import Equipo
from app.repositories.base import BaseRepository


class EquipoRepository(BaseRepository[Equipo]):
    def __init__(self):
        super().__init__(Equipo)


equipo_repository = EquipoRepository()
