from sqlalchemy.orm import Session

from app.models.equipo import Equipo
from app.repositories.equipo_repository import equipo_repository
from app.schemas.equipo import EquipoCreate, EquipoUpdate
from app.utils.permissions import comprobar_admin


class EquipoService:
    def crear(self, db: Session, usuario_id: int, datos: EquipoCreate) -> Equipo:
        comprobar_admin(usuario_id)
        return equipo_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[Equipo]:
        return equipo_repository.list(db, skip, limit)

    def obtener(self, db: Session, equipo_id: int) -> Equipo:
        return equipo_repository.get_or_404(db, equipo_id)

    def actualizar(self, db: Session, usuario_id: int, equipo_id: int, datos: EquipoUpdate) -> Equipo:
        comprobar_admin(usuario_id)
        equipo = equipo_repository.get_or_404(db, equipo_id)
        return equipo_repository.update(db, equipo, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, equipo_id: int) -> None:
        comprobar_admin(usuario_id)
        equipo = equipo_repository.get_or_404(db, equipo_id)
        equipo_repository.delete(db, equipo)


equipo_service = EquipoService()
