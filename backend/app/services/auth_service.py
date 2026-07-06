from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password, verify_password
from app.models.usuario import Usuario
from app.repositories.usuario_repository import usuario_repository
from app.schemas.auth import LoginRequest, Token
from app.schemas.usuario import UsuarioCreate, UsuarioResetPassword


class AuthService:
    def registrar(self, db: Session, usuario_in: UsuarioCreate) -> Usuario:
        if usuario_repository.get_by_nombre_usuario(db, usuario_in.nombre_usuario):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT, detail="El nombre de usuario ya está en uso."
            )
        if usuario_repository.get_by_email(db, usuario_in.email):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT, detail="El correo electrónico ya está en uso."
            )
        data = usuario_in.model_dump(exclude={"password"})
        data["password_hash"] = hash_password(usuario_in.password)
        return usuario_repository.create(db, data)

    def autenticar(self, db: Session, credenciales: LoginRequest) -> Token:
        usuario = usuario_repository.get_by_nombre_usuario(db, credenciales.nombre_usuario)
        if usuario is None or not verify_password(credenciales.password, usuario.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Nombre de usuario o contraseña incorrectos.",
            )
        token = create_access_token(subject=str(usuario.id))
        return Token(access_token=token)

    def solicitar_recuperacion(self, db: Session, email: str) -> Usuario:
        usuario = usuario_repository.get_by_email(db, email)
        if usuario is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No existe ningún usuario con ese correo electrónico.",
            )
        return usuario

    def restablecer_password(self, db: Session, datos: UsuarioResetPassword) -> Usuario:
        usuario = self.solicitar_recuperacion(db, datos.email)
        usuario.password_hash = hash_password(datos.nueva_password)
        db.add(usuario)
        db.commit()
        db.refresh(usuario)
        return usuario


auth_service = AuthService()
