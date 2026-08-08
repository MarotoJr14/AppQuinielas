import pytest
from fastapi import HTTPException

from app.models.enums import EstadoTemporadaEnum
from app.utils.temporada import validar_temporada_activa


class _TemporadaDummy:
    def __init__(self, estado: EstadoTemporadaEnum) -> None:
        self.estado = estado


def test_estado_temporada_usa_valores_actual_y_finalizada() -> None:
    assert [m.value for m in EstadoTemporadaEnum] == ["actual", "finalizada"]


def test_validar_temporada_activa_permite_temporada_actual() -> None:
    validar_temporada_activa(_TemporadaDummy(EstadoTemporadaEnum.actual))


def test_validar_temporada_activa_rechaza_temporada_finalizada() -> None:
    with pytest.raises(HTTPException) as exc_info:
        validar_temporada_activa(_TemporadaDummy(EstadoTemporadaEnum.finalizada))

    assert exc_info.value.status_code == 409
    assert "finalizada" in str(exc_info.value.detail).lower()
