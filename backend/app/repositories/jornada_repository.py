from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.apuesta import Apuesta
from app.models.jornada import Jornada
from app.repositories.base import BaseRepository


class JornadaRepository(BaseRepository[Jornada]):
    def __init__(self):
        super().__init__(Jornada)

    def list_disponibles_para_grupo(self, db: Session, grupo_id: int) -> list[Jornada]:
        """Jornadas con fecha_cierre futura y sin apuesta ya registrada para ese grupo."""
        subq = select(Apuesta.jornada_id).where(Apuesta.grupo_id == grupo_id)
        stmt = (
            select(Jornada)
            .where(Jornada.fecha_cierre > datetime.now(timezone.utc))
            .where(Jornada.id.not_in(subq))
            .order_by(Jornada.fecha_cierre.asc())
        )
        return list(db.scalars(stmt).all())


jornada_repository = JornadaRepository()
