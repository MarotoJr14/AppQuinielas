from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class PartidoBase(BaseModel):
    jornada_id: int
    orden: int = Field(ge=1, le=15)
    competicion_temporada_id: int | None = None
    fecha_hora: datetime | None = None
    canal: str | None = Field(default=None, max_length=100)
    equipo_local_id: int | None = None
    equipo_visitante_id: int | None = None


class PartidoCreate(PartidoBase):
    pass


class PartidoUpdate(BaseModel):
    fecha_hora: datetime | None = None
    canal: str | None = None
    equipo_local_id: int | None = None
    equipo_visitante_id: int | None = None
    goles_local: int | None = Field(default=None, ge=0)
    goles_visitante: int | None = Field(default=None, ge=0)


class PartidoResultado(BaseModel):
    goles_local: int = Field(ge=0)
    goles_visitante: int = Field(ge=0)


class PartidoRead(TimestampedSchema):
    jornada_id: int
    orden: int
    competicion_temporada_id: int | None
    fecha_hora: datetime | None
    canal: str | None
    equipo_local_id: int | None
    equipo_visitante_id: int | None
    goles_local: int | None
    goles_visitante: int | None
