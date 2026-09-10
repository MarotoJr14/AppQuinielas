from types import SimpleNamespace

from app.models.enums import EstadoApuestaEnum
from app.repositories.apuesta_repository import apuesta_repository
from app.repositories.columna_repository import columna_repository
from app.services.apuesta_service import ApuestaService
from app.services.grupo_service import grupo_service


class _DbFake:
    def __init__(self) -> None:
        self.deleted = []
        self.added = []
        self.flush_count = 0
        self.commit_count = 0
        self.refreshed = []

    def delete(self, value) -> None:
        self.deleted.append(value)

    def add(self, value) -> None:
        self.added.append(value)

    def flush(self) -> None:
        self.flush_count += 1

    def commit(self) -> None:
        self.commit_count += 1

    def refresh(self, value) -> None:
        self.refreshed.append(value)


def _apuesta() -> SimpleNamespace:
    return SimpleNamespace(
        id=12,
        grupo_id=4,
        jornada_id=8,
        usuario_elige8_id=7,
        estado=EstadoApuestaEnum.abierta,
        precio=1.25,
        beneficio=0.0,
    )


def test_cambiar_usuario_elige8_elimina_columna_anterior(monkeypatch) -> None:
    db = _DbFake()
    apuesta = _apuesta()
    columna_elige8 = SimpleNamespace(id=33)
    service = ApuestaService()

    monkeypatch.setattr(apuesta_repository, "get_or_404", lambda _db, _id: apuesta)
    monkeypatch.setattr(grupo_service, "comprobar_lider", lambda *_args: None)
    monkeypatch.setattr(grupo_service, "comprobar_pertenece", lambda *_args: None)
    monkeypatch.setattr(columna_repository, "get_elige8", lambda _db, _id: columna_elige8)
    monkeypatch.setattr(service, "calcular_precio", lambda _db, _apuesta: 0.75)
    monkeypatch.setattr(service, "calcular_beneficio", lambda _db, _apuesta: 0.0)

    resultado = service.cambiar_usuario_elige8(db, usuario_id=1, apuesta_id=12, nuevo_usuario_id=9)

    assert resultado is apuesta
    assert apuesta.usuario_elige8_id == 9
    assert apuesta.precio == 0.75
    assert db.deleted == [columna_elige8]
    assert db.flush_count == 1
    assert db.commit_count == 1


def test_eliminar_apuesta_abierta(monkeypatch) -> None:
    db = _DbFake()
    apuesta = _apuesta()
    service = ApuestaService()

    monkeypatch.setattr(apuesta_repository, "get_or_404", lambda _db, _id: apuesta)
    monkeypatch.setattr(grupo_service, "comprobar_lider", lambda *_args: None)

    service.eliminar(db, usuario_id=1, apuesta_id=12)

    assert db.deleted == [apuesta]
    assert db.commit_count == 1
