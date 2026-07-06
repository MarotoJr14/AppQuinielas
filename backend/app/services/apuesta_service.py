from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.apuesta import Apuesta
from app.models.enums import CategoriaPremioEnum, EstadoApuestaEnum
from app.repositories.apuesta_repository import apuesta_repository
from app.repositories.columna_repository import columna_repository
from app.repositories.jornada_repository import jornada_repository
from app.repositories.partido_repository import partido_repository
from app.repositories.premio_jornada_repository import premio_jornada_repository
from app.repositories.pronostico_repository import pronostico_repository
from app.schemas.apuesta import ApuestaCreate, RankingFila
from app.services.grupo_service import grupo_service
from app.utils.scoring import contar_aciertos_fallos_pendientes

PRECIO_COLUMNA_ELIGE8 = 0.50
PRECIO_COLUMNA_NORMAL = 0.75

CATEGORIA_POR_ACIERTOS = {
    15: CategoriaPremioEnum.ACIERTOS_15,
    14: CategoriaPremioEnum.ACIERTOS_14,
    13: CategoriaPremioEnum.ACIERTOS_13,
    12: CategoriaPremioEnum.ACIERTOS_12,
    11: CategoriaPremioEnum.ACIERTOS_11,
    10: CategoriaPremioEnum.ACIERTOS_10,
}


class ApuestaService:
    def crear(self, db: Session, usuario_id: int, datos: ApuestaCreate) -> Apuesta:
        grupo_service.comprobar_lider(db, datos.grupo_id, usuario_id)

        jornada = jornada_repository.get_or_404(db, datos.jornada_id)
        if apuesta_repository.get_por_jornada_grupo(db, datos.jornada_id, datos.grupo_id) is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Este grupo ya tiene una apuesta registrada para esta jornada.",
            )
        disponibles_ids = {j.id for j in jornada_repository.list_disponibles_para_grupo(db, datos.grupo_id)}
        if jornada.id not in disponibles_ids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La jornada no está disponible (ya cerrada o ya apostada por el grupo).",
            )
        grupo_service.comprobar_pertenece(db, datos.grupo_id, datos.usuario_elige8_id)

        apuesta = Apuesta(
            jornada_id=datos.jornada_id,
            grupo_id=datos.grupo_id,
            usuario_elige8_id=datos.usuario_elige8_id,
            estado=EstadoApuestaEnum.pendiente,
        )
        db.add(apuesta)
        db.commit()
        db.refresh(apuesta)
        return apuesta

    def obtener(self, db: Session, apuesta_id: int) -> Apuesta:
        return apuesta_repository.get_or_404(db, apuesta_id)

    def listar_cola_grupo(self, db: Session, grupo_id: int) -> list[Apuesta]:
        apuestas = apuesta_repository.list_por_grupo_estado(db, grupo_id, EstadoApuestaEnum.pendiente)
        return sorted(apuestas, key=lambda a: a.jornada.fecha_cierre)

    def listar_historial_grupo(self, db: Session, grupo_id: int) -> list[Apuesta]:
        apuestas = apuesta_repository.list_por_grupo_estado(db, grupo_id)
        return sorted(apuestas, key=lambda a: a.jornada.fecha_cierre, reverse=True)

    def _calcular_aciertos_columna(self, db: Session, columna) -> tuple[int, int, int]:
        partidos = partido_repository.list_por_jornada(db, columna.apuesta.jornada_id)
        partidos_por_id = {p.id: p for p in partidos}
        pronosticos = pronostico_repository.list_por_columna(db, columna.id)
        return contar_aciertos_fallos_pendientes(pronosticos, partidos_por_id, columna.es_elige8)

    def calcular_precio(self, db: Session, apuesta: Apuesta) -> float:
        columnas = columna_repository.list_por_apuesta(db, apuesta.id)
        normales = sum(1 for c in columnas if not c.es_elige8)
        elige8 = any(c.es_elige8 for c in columnas)
        return round((PRECIO_COLUMNA_ELIGE8 if elige8 else 0.0) + PRECIO_COLUMNA_NORMAL * normales, 2)

    def calcular_beneficio(self, db: Session, apuesta: Apuesta) -> float:
        premios = {p.categoria: (p.valor or 0.0) for p in premio_jornada_repository.list_por_jornada(db, apuesta.jornada_id)}
        columnas = columna_repository.list_por_apuesta(db, apuesta.id)

        beneficio = 0.0
        for columna in columnas:
            aciertos, fallos, _ = self._calcular_aciertos_columna(db, columna)
            if columna.es_elige8:
                if fallos == 0:
                    beneficio += premios.get(CategoriaPremioEnum.ELIGE_8, 0.0)
            else:
                categoria = CATEGORIA_POR_ACIERTOS.get(aciertos)
                if categoria is not None:
                    beneficio += premios.get(categoria, 0.0)
        return round(beneficio, 2)

    def actualizar_precio_y_beneficio(self, db: Session, apuesta_id: int) -> Apuesta:
        apuesta = apuesta_repository.get_or_404(db, apuesta_id)
        apuesta.precio = self.calcular_precio(db, apuesta)
        apuesta.beneficio = self.calcular_beneficio(db, apuesta)
        db.add(apuesta)
        db.commit()
        db.refresh(apuesta)
        return apuesta

    def cerrar(self, db: Session, usuario_id: int, apuesta_id: int) -> Apuesta:
        apuesta = apuesta_repository.get_or_404(db, apuesta_id)
        grupo_service.comprobar_lider(db, apuesta.grupo_id, usuario_id)
        if apuesta.estado != EstadoApuestaEnum.pendiente:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="La quiniela ya está cerrada.")
        apuesta.estado = EstadoApuestaEnum.cerrada
        apuesta.precio = self.calcular_precio(db, apuesta)
        db.add(apuesta)
        db.commit()
        db.refresh(apuesta)
        return apuesta

    def ranking(self, db: Session, apuesta_id: int) -> list[RankingFila]:
        apuesta = apuesta_repository.get_or_404(db, apuesta_id)
        columnas = columna_repository.list_por_apuesta(db, apuesta.id)

        filas: list[RankingFila] = []
        for columna in columnas:
            aciertos, fallos, pendientes = self._calcular_aciertos_columna(db, columna)
            if columna.es_elige8:
                en_racha = fallos == 0
            else:
                en_racha = fallos <= 4
            filas.append(
                RankingFila(
                    columna_id=columna.id,
                    usuario_id=columna.usuario_id,
                    nombre_usuario=columna.usuario.nombre_usuario,
                    es_elige8=columna.es_elige8,
                    aciertos=aciertos,
                    fallos=fallos,
                    pendientes=pendientes,
                    en_racha=en_racha,
                )
            )

        elige8_filas = [f for f in filas if f.es_elige8]
        normales_filas = sorted((f for f in filas if not f.es_elige8), key=lambda f: f.aciertos, reverse=True)
        return elige8_filas + normales_filas

    def obtener_detalle(self, db: Session, apuesta_id: int) -> dict:
        """Construye la vista de detalle de una apuesta: partidos, columnas (con sus
        pronósticos evaluados) y premios de la jornada. Usada tanto en 'Quinielas en
        cola' como en 'Ver quiniela en curso' / 'Últimos resultados'."""
        from app.utils.scoring import evaluar_pronostico

        apuesta = apuesta_repository.get_or_404(db, apuesta_id)
        partidos = partido_repository.list_por_jornada(db, apuesta.jornada_id)
        partidos_por_id = {p.id: p for p in partidos}
        premios = premio_jornada_repository.list_por_jornada(db, apuesta.jornada_id)
        columnas = columna_repository.list_por_apuesta(db, apuesta.id)

        columnas_detalle = []
        for columna in columnas:
            pronosticos = pronostico_repository.list_por_columna(db, columna.id)
            pronosticos_detalle = []
            aciertos = fallos = 0
            for pronostico in pronosticos:
                partido = partidos_por_id.get(pronostico.partido_id)
                acertado = evaluar_pronostico(pronostico, partido, columna.es_elige8) if partido else None
                if acertado is True:
                    aciertos += 1
                elif acertado is False:
                    fallos += 1
                pronosticos_detalle.append(
                    {
                        "id": pronostico.id,
                        "created_at": pronostico.created_at,
                        "updated_at": pronostico.updated_at,
                        "columna_id": pronostico.columna_id,
                        "partido_id": pronostico.partido_id,
                        "signo": pronostico.signo,
                        "pleno15_local": pronostico.pleno15_local,
                        "pleno15_visitante": pronostico.pleno15_visitante,
                        "acertado": acertado,
                    }
                )
            columnas_detalle.append(
                {
                    "id": columna.id,
                    "created_at": columna.created_at,
                    "updated_at": columna.updated_at,
                    "apuesta_id": columna.apuesta_id,
                    "usuario_id": columna.usuario_id,
                    "es_elige8": columna.es_elige8,
                    "pronosticos": pronosticos_detalle,
                    "aciertos": aciertos,
                    "fallos": fallos,
                }
            )

        return {
            "id": apuesta.id,
            "created_at": apuesta.created_at,
            "updated_at": apuesta.updated_at,
            "jornada_id": apuesta.jornada_id,
            "grupo_id": apuesta.grupo_id,
            "usuario_elige8_id": apuesta.usuario_elige8_id,
            "estado": apuesta.estado,
            "precio": apuesta.precio,
            "beneficio": apuesta.beneficio,
            "partidos": partidos,
            "columnas": columnas_detalle,
            "premios": premios,
        }


apuesta_service = ApuestaService()
