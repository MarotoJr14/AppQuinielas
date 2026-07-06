from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.columna import Columna
from app.repositories.base import BaseRepository


class ColumnaRepository(BaseRepository[Columna]):
    def __init__(self):
        super().__init__(Columna)

    def get_por_apuesta_usuario(self, db: Session, apuesta_id: int, usuario_id: int) -> Columna | None:
        stmt = select(Columna).where(Columna.apuesta_id == apuesta_id, Columna.usuario_id == usuario_id)
        return db.scalars(stmt).first()

    def get_elige8(self, db: Session, apuesta_id: int) -> Columna | None:
        stmt = select(Columna).where(Columna.apuesta_id == apuesta_id, Columna.es_elige8.is_(True))
        return db.scalars(stmt).first()

    def list_por_apuesta(self, db: Session, apuesta_id: int) -> list[Columna]:
        stmt = select(Columna).where(Columna.apuesta_id == apuesta_id).order_by(Columna.created_at)
        return list(db.scalars(stmt).all())


columna_repository = ColumnaRepository()
