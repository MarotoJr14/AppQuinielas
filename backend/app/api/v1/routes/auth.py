from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user
from app.db.deps import get_db
from app.models.usuario import Usuario
from app.schemas.auth import LoginRequest, LogoutRequest, RefreshTokenRequest, Token
from app.schemas.usuario import UsuarioCreate, UsuarioRead, UsuarioResetPassword
from app.services.auth_service import auth_service

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post("/registro", response_model=UsuarioRead, status_code=status.HTTP_201_CREATED)
def registro(datos: UsuarioCreate, db: Session = Depends(get_db)):
    return auth_service.registrar(db, datos)


@router.post("/login", response_model=Token)
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    return auth_service.autenticar(db, datos)


@router.post("/refresh", response_model=Token)
def refresh(datos: RefreshTokenRequest, db: Session = Depends(get_db)):
    return auth_service.refrescar_sesion(db, datos.refresh_token)


@router.post("/logout")
def logout(
    datos: LogoutRequest,
    usuario_actual: Usuario = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    auth_service.cerrar_sesion(db, usuario_actual.id, datos.refresh_token)
    return {"detail": "Sesión cerrada correctamente."}


@router.post("/recuperar-password", response_model=UsuarioRead)
def solicitar_recuperacion(email: str, db: Session = Depends(get_db)):
    return auth_service.solicitar_recuperacion(db, email)


@router.post("/restablecer-password", response_model=UsuarioRead)
def restablecer_password(datos: UsuarioResetPassword, db: Session = Depends(get_db)):
    return auth_service.restablecer_password(db, datos)
