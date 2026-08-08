from sqlalchemy.orm import Session

from app.models.temporada_competicion import TemporadaCompeticion
from app.repositories.temporada_competicion_repository import temporada_competicion_repository
from app.schemas.temporada_competicion import TemporadaCompeticionCreate
from app.utils.permissions import comprobar_admin


class TemporadaCompeticionService:
    def crear(self, db: Session, usuario_id: int, datos: TemporadaCompeticionCreate) -> TemporadaCompeticion:
        comprobar_admin(usuario_id)
        return temporada_competicion_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[TemporadaCompeticion]:
        return temporada_competicion_repository.list(db, skip, limit)

    def obtener(self, db: Session, id: int) -> TemporadaCompeticion:
        return temporada_competicion_repository.get_or_404(db, id)

    def listar_por_temporada(self, db: Session, temporada_id: int) -> list[TemporadaCompeticion]:
        return temporada_competicion_repository.list_por_temporada(db, temporada_id)

    def eliminar(self, db: Session, usuario_id: int, id: int) -> None:
        comprobar_admin(usuario_id)
        obj = temporada_competicion_repository.get_or_404(db, id)
        temporada_competicion_repository.delete(db, obj)


temporada_competicion_service = TemporadaCompeticionService()
