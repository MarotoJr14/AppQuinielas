from sqlalchemy.orm import Session

from app.models.premio_jornada import PremioJornada
from app.repositories.premio_jornada_repository import premio_jornada_repository
from app.schemas.premio_jornada import PremioJornadaCreate, PremioJornadaUpdate
from app.utils.permissions import comprobar_admin


class PremioJornadaService:
    def crear(self, db: Session, usuario_id: int, datos: PremioJornadaCreate) -> PremioJornada:
        comprobar_admin(usuario_id)
        return premio_jornada_repository.create(db, datos.model_dump())

    def listar_por_jornada(self, db: Session, jornada_id: int) -> list[PremioJornada]:
        return premio_jornada_repository.list_por_jornada(db, jornada_id)

    def actualizar(self, db: Session, usuario_id: int, premio_id: int, datos: PremioJornadaUpdate) -> PremioJornada:
        comprobar_admin(usuario_id)
        premio = premio_jornada_repository.get_or_404(db, premio_id)
        return premio_jornada_repository.update(db, premio, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, premio_id: int) -> None:
        comprobar_admin(usuario_id)
        premio = premio_jornada_repository.get_or_404(db, premio_id)
        premio_jornada_repository.delete(db, premio)


premio_jornada_service = PremioJornadaService()
