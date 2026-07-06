from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.pronostico import Pronostico
from app.repositories.base import BaseRepository


class PronosticoRepository(BaseRepository[Pronostico]):
    def __init__(self):
        super().__init__(Pronostico)

    def get_por_columna_partido(self, db: Session, columna_id: int, partido_id: int) -> Pronostico | None:
        stmt = select(Pronostico).where(Pronostico.columna_id == columna_id, Pronostico.partido_id == partido_id)
        return db.scalars(stmt).first()

    def list_por_columna(self, db: Session, columna_id: int) -> list[Pronostico]:
        stmt = select(Pronostico).where(Pronostico.columna_id == columna_id)
        return list(db.scalars(stmt).all())


pronostico_repository = PronosticoRepository()
