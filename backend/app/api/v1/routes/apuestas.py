from typing import Any

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.apuesta import ApuestaCreate, ApuestaRead, ApuestaReadDetalle, RankingFila
from app.services.apuesta_service import apuesta_service

router = APIRouter(prefix="/apuestas", tags=["Apuestas (quinielas)"])


@router.post("", response_model=ApuestaRead, status_code=status.HTTP_201_CREATED)
def crear_apuesta(datos: ApuestaCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return apuesta_service.crear(db, usuario_id, datos)


@router.get("/grupo/{grupo_id}/en-cola", response_model=list[ApuestaRead])
def listar_cola(grupo_id: int, db: Session = Depends(get_db)):
    return apuesta_service.listar_cola_grupo(db, grupo_id)


@router.get("/grupo/{grupo_id}/historial", response_model=list[ApuestaRead])
def listar_historial(grupo_id: int, db: Session = Depends(get_db)):
    return apuesta_service.listar_historial_grupo(db, grupo_id)


@router.get("/{apuesta_id}", response_model=ApuestaRead)
def obtener_apuesta(apuesta_id: int, db: Session = Depends(get_db)):
    return apuesta_service.obtener(db, apuesta_id)


@router.get("/{apuesta_id}/detalle", response_model=ApuestaReadDetalle)
def obtener_detalle_apuesta(apuesta_id: int, db: Session = Depends(get_db)) -> Any:
    return apuesta_service.obtener_detalle(db, apuesta_id)


@router.get("/{apuesta_id}/ranking", response_model=list[RankingFila])
def obtener_ranking(apuesta_id: int, db: Session = Depends(get_db)):
    return apuesta_service.ranking(db, apuesta_id)


@router.post("/{apuesta_id}/recalcular", response_model=ApuestaRead)
def recalcular_precio_beneficio(apuesta_id: int, db: Session = Depends(get_db)):
    return apuesta_service.actualizar_precio_y_beneficio(db, apuesta_id)


@router.post("/{apuesta_id}/cerrar", response_model=ApuestaRead)
def cerrar_apuesta(apuesta_id: int, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    return apuesta_service.cerrar(db, usuario_id, apuesta_id)
