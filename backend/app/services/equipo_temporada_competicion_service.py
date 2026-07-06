from sqlalchemy.orm import Session

from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion
from app.repositories.equipo_temporada_competicion_repository import equipo_temporada_competicion_repository
from app.schemas.equipo_temporada_competicion import EquipoTemporadaCompeticionCreate
from app.utils.permissions import comprobar_admin


class EquipoTemporadaCompeticionService:
    def crear(
        self, db: Session, usuario_id: int, datos: EquipoTemporadaCompeticionCreate
    ) -> EquipoTemporadaCompeticion:
        comprobar_admin(usuario_id)
        return equipo_temporada_competicion_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[EquipoTemporadaCompeticion]:
        return equipo_temporada_competicion_repository.list(db, skip, limit)

    def eliminar(self, db: Session, usuario_id: int, id: int) -> None:
        comprobar_admin(usuario_id)
        obj = equipo_temporada_competicion_repository.get_or_404(db, id)
        equipo_temporada_competicion_repository.delete(db, obj)


equipo_temporada_competicion_service = EquipoTemporadaCompeticionService()
