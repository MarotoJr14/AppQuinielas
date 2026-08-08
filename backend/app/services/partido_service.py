from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.enums import EstadoApuestaEnum, EstadoJornadaEnum
from app.models.partido import Partido
from app.repositories.apuesta_repository import apuesta_repository
from app.repositories.jornada_repository import jornada_repository
from app.repositories.partido_repository import partido_repository
from app.schemas.partido import PartidoCreate, PartidoResultado, PartidoUpdate
from app.utils.permissions import comprobar_admin


def _actualizar_estado_apuestas_y_jornada(db: Session, jornada_id: int) -> None:
    partidos = partido_repository.list_por_jornada(db, jornada_id)
    if not partidos:
        return

    todos_finalizados = all(p.estado == 'finalizado' for p in partidos)
    alguno_no_pendiente = any(p.estado != 'pendiente' for p in partidos)

    jornada = jornada_repository.get_or_404(db, jornada_id)

    if todos_finalizados:
        jornada.estado = EstadoJornadaEnum.finalizada
    elif alguno_no_pendiente:
        jornada.estado = EstadoJornadaEnum.en_curso
    else:
        jornada.estado = EstadoJornadaEnum.pendiente
    db.add(jornada)

    apuestas = apuesta_repository.list_por_jornada(db, jornada_id)
    for apuesta in apuestas:
        if apuesta.estado == EstadoApuestaEnum.abierta and alguno_no_pendiente:
            apuesta.estado = EstadoApuestaEnum.cerrada
            db.add(apuesta)
        elif apuesta.estado == EstadoApuestaEnum.cerrada and todos_finalizados:
            apuesta.estado = EstadoApuestaEnum.cerrada
            db.add(apuesta)

    if apuestas or jornada:
        db.commit()


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
        partido = partido_repository.update(db, partido, datos.model_dump(exclude_unset=True))
        if datos.estado is not None:
            _actualizar_estado_apuestas_y_jornada(db, partido.jornada_id)
        return partido

    def registrar_resultado(self, db: Session, usuario_id: int, partido_id: int, datos: PartidoResultado) -> Partido:
        comprobar_admin(usuario_id)
        partido = partido_repository.get_or_404(db, partido_id)
        # Validate and apply estado transition if provided
        if datos.estado is not None:
            actual = partido.estado
            nuevo = datos.estado
            # allowed transitions:
            # pendiente -> en_juego | finalizado
            # en_juego -> finalizado
            # finalizado -> (no changes allowed)
            if actual == 'pendiente':
                if nuevo not in ('pendiente', 'en_juego', 'finalizado'):
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Estado inválido')
            elif actual == 'en_juego':
                if nuevo not in ('en_juego', 'finalizado'):
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Transición de estado no permitida')
            else:  # actual == 'finalizado' or other
                if nuevo != actual:
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='No se puede cambiar el estado de un partido finalizado')
            partido.estado = nuevo

        partido.goles_local = datos.goles_local
        partido.goles_visitante = datos.goles_visitante
        db.add(partido)
        db.commit()
        _actualizar_estado_apuestas_y_jornada(db, partido.jornada_id)
        db.refresh(partido)
        return partido

    def eliminar(self, db: Session, usuario_id: int, partido_id: int) -> None:
        comprobar_admin(usuario_id)
        partido = partido_repository.get_or_404(db, partido_id)
        partido_repository.delete(db, partido)


partido_service = PartidoService()
