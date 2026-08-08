from app.models.enums import GolesEnum, SignoEnum


def test_signo_enum_usa_valores_cortos() -> None:
    assert [m.value for m in SignoEnum] == ["1", "X", "2"]


def test_goles_enum_usa_valores_cortos() -> None:
    assert [m.value for m in GolesEnum] == ["0", "1", "2", "M"]
