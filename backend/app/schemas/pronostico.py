from pydantic import BaseModel, model_validator

from app.models.enums import GolesEnum, SignoEnum
from app.schemas.common import TimestampedSchema


class PronosticoBase(BaseModel):
    partido_id: int
    signo: SignoEnum | None = None
    pleno15_local: GolesEnum | None = None
    pleno15_visitante: GolesEnum | None = None

    @model_validator(mode="after")
    def comprobar_consistencia(self) -> "PronosticoBase":
        # El pleno al 15 (goles) solo tiene sentido junto al signo correspondiente;
        # la validación de "solo elige8 puede rellenar pleno15" se hace en el servicio,
        # donde se conoce el contexto de la columna.
        return self


class PronosticoCreate(PronosticoBase):
    pass


class PronosticoUpsert(BaseModel):
    """Pronóstico de un partido dentro de un payload de relleno de columna."""
    partido_id: int
    signo: SignoEnum | None = None
    pleno15_local: GolesEnum | None = None
    pleno15_visitante: GolesEnum | None = None


class PronosticoRead(TimestampedSchema):
    columna_id: int
    partido_id: int
    signo: SignoEnum | None
    pleno15_local: GolesEnum | None
    pleno15_visitante: GolesEnum | None
    acertado: bool | None = None
