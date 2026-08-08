from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.enums import EstadoJornadaEnum
from app.models.apuesta import Apuesta
from app.models.jornada import Jornada
from app.repositories.base import BaseRepository


class ApuestaRepository(BaseRepository[Apuesta]):
    def __init__(self):
        super().__init__(Apuesta)

    def get_por_jornada_grupo(self, db: Session, jornada_id: int, grupo_id: int) -> Apuesta | None:
        stmt = select(Apuesta).where(Apuesta.jornada_id == jornada_id, Apuesta.grupo_id == grupo_id)
        return db.scalars(stmt).first()

    def list_por_grupo_estado(self, db: Session, grupo_id: int, estado=None) -> list[Apuesta]:
        stmt = select(Apuesta).where(Apuesta.grupo_id == grupo_id)
        if estado is not None:
            stmt = stmt.where(Apuesta.estado == estado)
        return list(db.scalars(stmt).all())

    def list_por_grupo_estados(self, db: Session, grupo_id: int, estados: list[str]) -> list[Apuesta]:
        stmt = select(Apuesta).join(Jornada, Apuesta.jornada_id == Jornada.id).where(Apuesta.grupo_id == grupo_id, Jornada.estado == EstadoJornadaEnum.pendiente)
        return list(db.scalars(stmt).all())

    def list_por_jornada(self, db: Session, jornada_id: int) -> list[Apuesta]:
        stmt = select(Apuesta).where(Apuesta.jornada_id == jornada_id)
        return list(db.scalars(stmt).all())


apuesta_repository = ApuestaRepository()
