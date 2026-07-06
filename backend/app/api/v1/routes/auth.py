from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.db.deps import get_db
from app.schemas.auth import LoginRequest, Token
from app.schemas.usuario import UsuarioCreate, UsuarioRead, UsuarioResetPassword
from app.services.auth_service import auth_service

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post("/registro", response_model=UsuarioRead, status_code=status.HTTP_201_CREATED)
def registro(datos: UsuarioCreate, db: Session = Depends(get_db)):
    return auth_service.registrar(db, datos)


@router.post("/login", response_model=Token)
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    return auth_service.autenticar(db, datos)


@router.post("/recuperar-password", response_model=UsuarioRead)
def solicitar_recuperacion(email: str, db: Session = Depends(get_db)):
    return auth_service.solicitar_recuperacion(db, email)


@router.post("/restablecer-password", response_model=UsuarioRead)
def restablecer_password(datos: UsuarioResetPassword, db: Session = Depends(get_db)):
    return auth_service.restablecer_password(db, datos)
