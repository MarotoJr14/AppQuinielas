from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.premio_jornada import PremioJornada
from app.repositories.jornada_repository import jornada_repository
from app.repositories.partido_repository import partido_repository
from app.repositories.premio_jornada_repository import premio_jornada_repository
from app.schemas.premio_jornada import PremioJornadaCreate, PremioJornadaUpdate
from app.utils.permissions import comprobar_admin
from app.services.apuesta_service import apuesta_service


class PremioJornadaService:
    def _comprobar_jornada_finalizada(self, db: Session, jornada_id: int) -> None:
        jornada = jornada_repository.get_or_404(db, jornada_id)
        partidos = partido_repository.list_por_jornada(db, jornada_id)
        if not partidos or any(p.estado != 'finalizado' for p in partidos):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail='Solo se pueden asignar o modificar premios cuando todos los partidos de la jornada están finalizados.',
            )

    def crear(self, db: Session, usuario_id: int, datos: PremioJornadaCreate) -> PremioJornada:
        comprobar_admin(usuario_id)
        self._comprobar_jornada_finalizada(db, datos.jornada_id)
        premio = premio_jornada_repository.create(db, datos.model_dump())
        apuesta_service.actualizar_beneficios_jornada(
            db,
            premio.jornada_id,
        )
        return premio

    def listar_por_jornada(self, db: Session, jornada_id: int) -> list[PremioJornada]:
        return premio_jornada_repository.list_por_jornada(db, jornada_id)

    def actualizar(self, db: Session, usuario_id: int, premio_id: int, datos: PremioJornadaUpdate) -> PremioJornada:
        comprobar_admin(usuario_id)
        premio = premio_jornada_repository.get_or_404(db, premio_id)
        self._comprobar_jornada_finalizada(db, premio.jornada_id)
        premio = premio_jornada_repository.update(
            db,
            premio,
            datos.model_dump(exclude_unset=True),
        )
        apuesta_service.actualizar_beneficios_jornada(
            db,
            premio.jornada_id,
        )
        return premio

    def eliminar(self, db: Session, usuario_id: int, premio_id: int) -> None:
        comprobar_admin(usuario_id)
        premio = premio_jornada_repository.get_or_404(db, premio_id)
        jornada_id = premio.jornada_id
        premio_jornada_repository.delete(db, premio)
        apuesta_service.actualizar_beneficios_jornada(
            db,
            jornada_id,
        )



premio_jornada_service = PremioJornadaService()
