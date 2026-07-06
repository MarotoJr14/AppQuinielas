from sqlalchemy.orm import Session

from app.models.temporada import Temporada
from app.repositories.temporada_repository import temporada_repository
from app.schemas.temporada import TemporadaCreate, TemporadaUpdate
from app.utils.permissions import comprobar_admin


class TemporadaService:
    def crear(self, db: Session, usuario_id: int, datos: TemporadaCreate) -> Temporada:
        comprobar_admin(usuario_id)
        return temporada_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[Temporada]:
        return temporada_repository.list(db, skip, limit)

    def obtener(self, db: Session, temporada_id: int) -> Temporada:
        return temporada_repository.get_or_404(db, temporada_id)

    def actualizar(self, db: Session, usuario_id: int, temporada_id: int, datos: TemporadaUpdate) -> Temporada:
        comprobar_admin(usuario_id)
        temporada = temporada_repository.get_or_404(db, temporada_id)
        return temporada_repository.update(db, temporada, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, temporada_id: int) -> None:
        comprobar_admin(usuario_id)
        temporada = temporada_repository.get_or_404(db, temporada_id)
        temporada_repository.delete(db, temporada)


temporada_service = TemporadaService()
