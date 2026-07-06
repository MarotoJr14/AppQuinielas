from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class EquipoBase(BaseModel):
    nombre: str = Field(min_length=2, max_length=150)
    es_club: bool = True
    pais: str = Field(min_length=2, max_length=100)


class EquipoCreate(EquipoBase):
    pass


class EquipoUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=150)
    es_club: bool | None = None
    pais: str | None = Field(default=None, min_length=2, max_length=100)


class EquipoRead(TimestampedSchema):
    nombre: str
    es_club: bool
    pais: str
