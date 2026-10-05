from datetime import datetime, timedelta, timezone
from hashlib import sha256

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, create_refresh_token, decode_token, hash_password, verify_password
from app.models.refresh_token import RefreshToken
from app.models.usuario import Usuario
from app.repositories.refresh_token_repository import refresh_token_repository
from app.repositories.usuario_repository import usuario_repository
from app.schemas.auth import LoginRequest, Token
from app.schemas.usuario import UsuarioCreate, UsuarioResetPassword


class AuthService:
    @staticmethod
    def _hash_token(token: str) -> str:
        return sha256(token.encode("utf-8")).hexdigest()

    def _guardar_refresh_token(self, db: Session, usuario_id: int, refresh_token: str) -> None:
        payload = decode_token(refresh_token, expected_type="refresh")
        if payload is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token inválido.")

        expires_at = datetime.fromtimestamp(payload["exp"], tz=timezone.utc)
        token_record = RefreshToken(
            user_id=usuario_id,
            jti=payload["jti"],
            token_hash=self._hash_token(refresh_token),
            expires_at=expires_at,
        )

        if not hasattr(db, "add"):
            return

        db.add(token_record)
        db.commit()
        db.refresh(token_record)

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

        access_token = create_access_token(subject=str(usuario.id))
        refresh_token = create_refresh_token(subject=str(usuario.id))
        self._guardar_refresh_token(db, usuario.id, refresh_token)
        return Token(access_token=access_token, refresh_token=refresh_token, token_type="bearer")

    def refrescar_sesion(self, db: Session, refresh_token: str) -> Token:
        payload = decode_token(refresh_token, expected_type="refresh")
        if payload is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token inválido.")

        usuario_id = int(payload.get("sub"))
        usuario = usuario_repository.get(db, usuario_id)
        if usuario is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Usuario no encontrado.")

        token_record = refresh_token_repository.get_by_jti(db, payload.get("jti"))
        now = datetime.now(timezone.utc)
        if token_record is None or token_record.user_id != usuario_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token inválido o revocado.")
        if token_record.revoked_at is not None or token_record.expires_at <= now:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token expirado o revocado.")
        if token_record.token_hash != self._hash_token(refresh_token):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token no coincide con la sesión actual.")

        nuevo_access_token = create_access_token(subject=str(usuario.id))
        nuevo_refresh_token = create_refresh_token(subject=str(usuario.id))

        token_record.revoked_at = now
        nuevo_registro = RefreshToken(
            user_id=usuario.id,
            jti=decode_token(nuevo_refresh_token, expected_type="refresh")["jti"],
            token_hash=self._hash_token(nuevo_refresh_token),
            expires_at=datetime.fromtimestamp(decode_token(nuevo_refresh_token, expected_type="refresh")["exp"], tz=timezone.utc),
        )
        db.add(nuevo_registro)
        db.flush()
        token_record.replaced_by_token_id = nuevo_registro.id
        db.add(token_record)
        db.commit()
        db.refresh(nuevo_registro)

        return Token(access_token=nuevo_access_token, refresh_token=nuevo_refresh_token, token_type="bearer")

    def cerrar_sesion(self, db: Session, usuario_id: int, refresh_token: str | None = None) -> None:
        if refresh_token:
            payload = decode_token(refresh_token, expected_type="refresh")
            if payload is not None:
                token_record = refresh_token_repository.get_by_jti(db, payload.get("jti"))
                if token_record and token_record.user_id == usuario_id:
                    token_record.revoked_at = datetime.now(timezone.utc)
                    db.add(token_record)
                    db.commit()
                    return
                return

        refresh_token_repository.revoke_for_user(db, usuario_id)
        db.commit()

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
