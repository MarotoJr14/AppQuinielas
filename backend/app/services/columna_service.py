from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.columna import Columna
from app.models.enums import EstadoApuestaEnum
from app.models.pronostico import Pronostico
from app.repositories.apuesta_repository import apuesta_repository
from app.repositories.columna_repository import columna_repository
from app.repositories.partido_repository import partido_repository
from app.repositories.pronostico_repository import pronostico_repository
from app.schemas.columna import ColumnaCreate, ColumnaUpdate
from app.schemas.pronostico import PronosticoUpsert

MAX_PRONOSTICOS_ELIGE8_NORMALES = 8


class ColumnaService:
    def _comprobar_apuesta_editable(self, apuesta) -> None:
        if apuesta.estado != EstadoApuestaEnum.pendiente:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="La quiniela ya está cerrada y no admite más cambios.",
            )

    def _validar_pronosticos_elige8(
        self, db: Session, apuesta_id: int, usuario_id: int, pronosticos: list[PronosticoUpsert], partidos_por_id
    ) -> None:
        columna_normal = columna_repository.get_por_apuesta_usuario(db, apuesta_id, usuario_id)
        pronosticos_normales_por_partido: dict[int, str | None] = {}
        if columna_normal is not None:
            for p in pronostico_repository.list_por_columna(db, columna_normal.id):
                pronosticos_normales_por_partido[p.partido_id] = p.signo.value if p.signo else None

        normales_en_elige8 = 0
        for p in pronosticos:
            partido = partidos_por_id.get(p.partido_id)
            if partido is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"El partido {p.partido_id} no pertenece a esta jornada.",
                )
            if partido.orden == 15:
                continue
            normales_en_elige8 += 1
            signo_columna = pronosticos_normales_por_partido.get(p.partido_id)
            signo_elige8 = p.signo.value if p.signo else None
            if signo_columna is not None and signo_elige8 is not None and signo_columna != signo_elige8:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=(
                        "El pronóstico del Elige 8 debe coincidir con el de tu columna normal "
                        f"para el partido {p.partido_id}."
                    ),
                )

        if normales_en_elige8 > MAX_PRONOSTICOS_ELIGE8_NORMALES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"La columna Elige 8 admite como máximo {MAX_PRONOSTICOS_ELIGE8_NORMALES} pronósticos 1X2.",
            )

    def rellenar_columna(self, db: Session, solicitante_id: int, datos: ColumnaCreate) -> Columna:
        apuesta = apuesta_repository.get_or_404(db, datos.apuesta_id)
        self._comprobar_apuesta_editable(apuesta)

        if datos.usuario_id != solicitante_id:
            from app.utils.permissions import comprobar_admin

            comprobar_admin(solicitante_id)  # Solo el admin puede rellenar la columna de otro usuario.

        if datos.es_elige8 and datos.usuario_id != apuesta.usuario_elige8_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Solo el usuario asignado puede rellenar la columna Elige 8 de esta apuesta.",
            )

        existente = columna_repository.get_por_apuesta_usuario(db, datos.apuesta_id, datos.usuario_id)
        if existente is not None and existente.es_elige8 == datos.es_elige8:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT, detail="Esa columna ya ha sido rellenada."
            )

        if datos.es_elige8:
            ya_elige8 = columna_repository.get_elige8(db, datos.apuesta_id)
            if ya_elige8 is not None:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT, detail="La columna Elige 8 ya ha sido rellenada."
                )

        partidos = partido_repository.list_por_jornada(db, apuesta.jornada_id)
        partidos_por_id = {p.id: p for p in partidos}

        if datos.es_elige8:
            self._validar_pronosticos_elige8(db, datos.apuesta_id, datos.usuario_id, datos.pronosticos, partidos_por_id)

        columna = Columna(apuesta_id=datos.apuesta_id, usuario_id=datos.usuario_id, es_elige8=datos.es_elige8)
        db.add(columna)
        db.flush()

        for p in datos.pronosticos:
            if p.partido_id not in partidos_por_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"El partido {p.partido_id} no pertenece a esta jornada.",
                )
            pronostico = Pronostico(
                columna_id=columna.id,
                partido_id=p.partido_id,
                signo=p.signo,
                pleno15_local=p.pleno15_local,
                pleno15_visitante=p.pleno15_visitante,
            )
            db.add(pronostico)

        db.commit()
        db.refresh(columna)
        return columna

    def editar_columna(self, db: Session, solicitante_id: int, columna_id: int, datos: ColumnaUpdate) -> Columna:
        columna = columna_repository.get_or_404(db, columna_id)
        apuesta = apuesta_repository.get_or_404(db, columna.apuesta_id)
        self._comprobar_apuesta_editable(apuesta)

        if columna.usuario_id != solicitante_id:
            from app.utils.permissions import comprobar_admin

            comprobar_admin(solicitante_id)

        partidos = partido_repository.list_por_jornada(db, apuesta.jornada_id)
        partidos_por_id = {p.id: p for p in partidos}

        if columna.es_elige8:
            self._validar_pronosticos_elige8(db, apuesta.id, columna.usuario_id, datos.pronosticos, partidos_por_id)

        for p in datos.pronosticos:
            if p.partido_id not in partidos_por_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"El partido {p.partido_id} no pertenece a esta jornada.",
                )
            existente = pronostico_repository.get_por_columna_partido(db, columna.id, p.partido_id)
            if existente is None:
                db.add(
                    Pronostico(
                        columna_id=columna.id,
                        partido_id=p.partido_id,
                        signo=p.signo,
                        pleno15_local=p.pleno15_local,
                        pleno15_visitante=p.pleno15_visitante,
                    )
                )
            else:
                existente.signo = p.signo
                existente.pleno15_local = p.pleno15_local
                existente.pleno15_visitante = p.pleno15_visitante
                db.add(existente)

        db.commit()
        db.refresh(columna)
        return columna

    def listar_por_apuesta(self, db: Session, apuesta_id: int) -> list[Columna]:
        return columna_repository.list_por_apuesta(db, apuesta_id)


columna_service = ColumnaService()
