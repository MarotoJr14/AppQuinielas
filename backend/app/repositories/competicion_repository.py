from app.models.competicion import Competicion
from app.repositories.base import BaseRepository


class CompeticionRepository(BaseRepository[Competicion]):
    def __init__(self):
        super().__init__(Competicion)


competicion_repository = CompeticionRepository()
