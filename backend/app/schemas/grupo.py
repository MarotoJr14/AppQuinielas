from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class GrupoBase(BaseModel):
    nombre: str = Field(min_length=3, max_length=100)


class GrupoCreate(GrupoBase):
    password: str = Field(min_length=4)


class GrupoUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=3, max_length=100)
    password: str | None = Field(default=None, min_length=4)


class GrupoRead(TimestampedSchema):
    nombre: str


class GrupoJoin(BaseModel):
    nombre: str
    password: str
