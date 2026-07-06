from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema
from app.schemas.pronostico import PronosticoRead, PronosticoUpsert


class ColumnaCreate(BaseModel):
    apuesta_id: int
    usuario_id: int
    es_elige8: bool = False
    pronosticos: list[PronosticoUpsert] = Field(default_factory=list)


class ColumnaUpdate(BaseModel):
    pronosticos: list[PronosticoUpsert] = Field(default_factory=list)


class ColumnaRead(TimestampedSchema):
    apuesta_id: int
    usuario_id: int
    es_elige8: bool


class ColumnaReadDetalle(ColumnaRead):
    pronosticos: list[PronosticoRead] = Field(default_factory=list)
    aciertos: int | None = None
    fallos: int | None = None
