from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status

from app.models.enums import EstadoJornadaEnum
from app.models.jornada import Jornada
from app.repositories.jornada_repository import jornada_repository
from app.schemas.jornada import JornadaCreate, JornadaUpdate
from app.utils.permissions import comprobar_admin


class JornadaService:
    def crear(self, db: Session, usuario_id: int, datos: JornadaCreate) -> Jornada:
        comprobar_admin(usuario_id)
        now = datetime.now(timezone.utc)
        max_date = now + timedelta(days=30)
        fecha_cierre = datos.fecha_cierre
        if fecha_cierre.tzinfo is None:
            fecha_cierre = fecha_cierre.replace(tzinfo=timezone.utc)
        else:
            fecha_cierre = fecha_cierre.astimezone(timezone.utc)
        # fecha_cierre must be within next 30 days
        if not (now <= fecha_cierre <= max_date):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='La fecha de cierre debe estar dentro de los próximos 30 días')
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
        if datos.estado is not None and datos.estado == EstadoJornadaEnum.finalizada:
            partidos = jornada.partidos
            if not partidos or any(p.estado != 'finalizado' for p in partidos):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail='No se puede marcar una jornada como finalizada si no todos sus partidos están finalizados.',
                )
        return jornada_repository.update(db, jornada, datos.model_dump(exclude_unset=True))

    def eliminar(self, db: Session, usuario_id: int, jornada_id: int) -> None:
        comprobar_admin(usuario_id)
        jornada = jornada_repository.get_or_404(db, jornada_id)
        jornada_repository.delete(db, jornada)


jornada_service = JornadaService()
