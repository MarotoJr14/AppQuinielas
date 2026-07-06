from sqlalchemy.orm import Session

from app.models.competicion import Competicion
from app.repositories.competicion_repository import competicion_repository
from app.schemas.competicion import CompeticionCreate, CompeticionUpdate
from app.utils.permissions import comprobar_admin


class CompeticionService:
    def crear(self, db: Session, usuario_id: int, datos: CompeticionCreate) -> Competicion:
        comprobar_admin(usuario_id)
        return competicion_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[Competicion]:
        return competicion_repository.list(db, skip, limit)

    def obtener(self, db: Session, competicion_id: int) -> Competicion:
        return competicion_repository.get_or_404(db, competicion_id)

    def actualizar(self, db: Session, usuario_id: int, competicion_id: int, datos: CompeticionUpdate) -> Competicion:
        comprobar_admin(usuario_id)
        competicion = competicion_repository.get_or_404(db, competicion_id)
        return competicion_repository.update(db, competicion, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, competicion_id: int) -> None:
        comprobar_admin(usuario_id)
        competicion = competicion_repository.get_or_404(db, competicion_id)
        competicion_repository.delete(db, competicion)


competicion_service = CompeticionService()
