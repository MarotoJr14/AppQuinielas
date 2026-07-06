from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class TemporadaBase(BaseModel):
    nombre: str = Field(min_length=2, max_length=50)


class TemporadaCreate(TemporadaBase):
    pass


class TemporadaUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=50)


class TemporadaRead(TimestampedSchema):
    nombre: str
