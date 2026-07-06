from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.db.deps import get_db
from app.models.usuario import Usuario
from app.repositories.usuario_repository import usuario_repository

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> Usuario:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar la credencial.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    usuario_id = payload.get("sub")
    if usuario_id is None:
        raise credentials_exception
    usuario = usuario_repository.get(db, int(usuario_id))
    if usuario is None:
        raise credentials_exception
    return usuario


def get_current_user_id(usuario: Usuario = Depends(get_current_user)) -> int:
    return usuario.id
