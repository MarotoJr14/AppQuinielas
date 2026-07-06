from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.columna import ColumnaCreate, ColumnaRead, ColumnaUpdate
from app.services.columna_service import columna_service

router = APIRouter(prefix="/columnas", tags=["Columnas"])


@router.post("", response_model=ColumnaRead, status_code=status.HTTP_201_CREATED)
def rellenar_columna(
    datos: ColumnaCreate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return columna_service.rellenar_columna(db, usuario_id, datos)


@router.get("/apuesta/{apuesta_id}", response_model=list[ColumnaRead])
def listar_columnas_de_apuesta(apuesta_id: int, db: Session = Depends(get_db)):
    return columna_service.listar_por_apuesta(db, apuesta_id)


@router.patch("/{columna_id}", response_model=ColumnaRead)
def editar_columna(
    columna_id: int, datos: ColumnaUpdate, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    return columna_service.editar_columna(db, usuario_id, columna_id, datos)
