from datetime import datetime

from pydantic import BaseModel, Field

from app.models.enums import EstadoJornadaEnum
from app.schemas.common import TimestampedSchema


class JornadaBase(BaseModel):
    temporada_id: int
    nombre: str = Field(min_length=2, max_length=150)
    fecha_cierre: datetime


class JornadaCreate(JornadaBase):
    pass


class JornadaUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=150)
    fecha_cierre: datetime | None = None
    estado: EstadoJornadaEnum | None = None


class JornadaRead(TimestampedSchema):
    temporada_id: int
    nombre: str
    fecha_cierre: datetime
    estado: EstadoJornadaEnum
