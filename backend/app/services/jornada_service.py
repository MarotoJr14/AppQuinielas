from sqlalchemy.orm import Session

from app.models.jornada import Jornada
from app.repositories.jornada_repository import jornada_repository
from app.schemas.jornada import JornadaCreate, JornadaUpdate
from app.utils.permissions import comprobar_admin


class JornadaService:
    def crear(self, db: Session, usuario_id: int, datos: JornadaCreate) -> Jornada:
        comprobar_admin(usuario_id)
        return jornada_repository.create(db, datos.model_dump())

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[Jornada]:
        return jornada_repository.list(db, skip, limit)

    def obtener(self, db: Session, jornada_id: int) -> Jornada:
        return jornada_repository.get_or_404(db, jornada_id)

    def listar_disponibles_para_grupo(self, db: Session, grupo_id: int) -> list[Jornada]:
        return jornada_repository.list_disponibles_para_grupo(db, grupo_id)

    def actualizar(self, db: Session, usuario_id: int, jornada_id: int, datos: JornadaUpdate) -> Jornada:
        comprobar_admin(usuario_id)
        jornada = jornada_repository.get_or_404(db, jornada_id)
        return jornada_repository.update(db, jornada, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, jornada_id: int) -> None:
        comprobar_admin(usuario_id)
        jornada = jornada_repository.get_or_404(db, jornada_id)
        jornada_repository.delete(db, jornada)


jornada_service = JornadaService()
