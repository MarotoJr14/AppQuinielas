from sqlalchemy.orm import Session

from app.models.partido import Partido
from app.repositories.partido_repository import partido_repository
from app.schemas.partido import PartidoCreate, PartidoResultado, PartidoUpdate
from app.utils.permissions import comprobar_admin


class PartidoService:
    def crear(self, db: Session, usuario_id: int, datos: PartidoCreate) -> Partido:
        comprobar_admin(usuario_id)
        return partido_repository.create(db, datos.model_dump())

    def listar_por_jornada(self, db: Session, jornada_id: int) -> list[Partido]:
        return partido_repository.list_por_jornada(db, jornada_id)

    def obtener(self, db: Session, partido_id: int) -> Partido:
        return partido_repository.get_or_404(db, partido_id)

    def actualizar(self, db: Session, usuario_id: int, partido_id: int, datos: PartidoUpdate) -> Partido:
        comprobar_admin(usuario_id)
        partido = partido_repository.get_or_404(db, partido_id)
        return partido_repository.update(db, partido, datos.model_dump(exclude_unset=True))

    def registrar_resultado(self, db: Session, usuario_id: int, partido_id: int, datos: PartidoResultado) -> Partido:
        comprobar_admin(usuario_id)
        partido = partido_repository.get_or_404(db, partido_id)
        partido.goles_local = datos.goles_local
        partido.goles_visitante = datos.goles_visitante
        db.add(partido)
        db.commit()
        db.refresh(partido)
        return partido

    def eliminar(self, db: Session, usuario_id: int, partido_id: int) -> None:
        comprobar_admin(usuario_id)
        partido = partido_repository.get_or_404(db, partido_id)
        partido_repository.delete(db, partido)


partido_service = PartidoService()
