from pydantic import BaseModel

from app.models.enums import CategoriaPremioEnum
from app.schemas.common import TimestampedSchema


class PremioJornadaBase(BaseModel):
    jornada_id: int
    categoria: CategoriaPremioEnum
    valor: float | None = None


class PremioJornadaCreate(PremioJornadaBase):
    pass


class PremioJornadaUpdate(BaseModel):
    valor: float | None = None


class PremioJornadaRead(TimestampedSchema):
    jornada_id: int
    categoria: CategoriaPremioEnum
    valor: float | None
