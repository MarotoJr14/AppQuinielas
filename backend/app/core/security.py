from datetime import datetime, timedelta, timezone
from uuid import uuid4

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def _create_token(subject: str, token_type: str, expires_delta: timedelta) -> str:
    issued_at = datetime.now(timezone.utc)
    expire = issued_at + expires_delta
    to_encode = {
        "exp": expire,
        "iat": issued_at,
        "jti": str(uuid4()),
        "sub": subject,
        "token_type": token_type,
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_access_token(subject: str, expires_delta: timedelta | None = None, token_type: str = "access") -> str:
    return _create_token(
        subject,
        token_type,
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )


def create_refresh_token(subject: str, expires_delta: timedelta | None = None, token_type: str = "refresh") -> str:
    return _create_token(
        subject,
        token_type,
        expires_delta or timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )


def decode_token(token: str, expected_type: str | None = None) -> dict | None:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None

    if expected_type and payload.get("token_type") != expected_type:
        return None
    return payload


def decode_access_token(token: str) -> dict | None:
    return decode_token(token, expected_type="access")
