from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from app.core.security import create_access_token, decode_token
from app.schemas.auth import LoginRequest
from app.services.auth_service import auth_service


def test_create_access_token_incluye_tipo_y_sujeto() -> None:
    token = create_access_token(subject="42", token_type="access")
    payload = decode_token(token)

    assert payload is not None
    assert payload["sub"] == "42"
    assert payload["token_type"] == "access"


def test_login_devuelve_access_y_refresh_tokens(monkeypatch) -> None:
    usuario = SimpleNamespace(id=7, password_hash="hashed")

    monkeypatch.setattr(
        "app.repositories.usuario_repository.usuario_repository.get_by_nombre_usuario",
        lambda _db, _nombre: usuario,
    )
    monkeypatch.setattr("app.services.auth_service.verify_password", lambda _plain, _hashed: True)

    token = auth_service.autenticar(object(), LoginRequest(nombre_usuario="demo", password="secret"))

    assert token.access_token
    assert token.refresh_token
    assert token.token_type == "bearer"


def test_login_incorrecto_sigue_rechazando_credenciales(monkeypatch) -> None:
    monkeypatch.setattr(
        "app.repositories.usuario_repository.usuario_repository.get_by_nombre_usuario",
        lambda _db, _nombre: None,
    )

    with pytest.raises(HTTPException) as exc_info:
        auth_service.autenticar(object(), LoginRequest(nombre_usuario="demo", password="bad"))

    assert exc_info.value.status_code == 401
