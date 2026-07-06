from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class CompeticionBase(BaseModel):
    nombre: str = Field(min_length=2, max_length=150)
    ambito: str = Field(min_length=2, max_length=100)
    es_clubes: bool = True


class CompeticionCreate(CompeticionBase):
    pass


class CompeticionUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=150)
    ambito: str | None = Field(default=None, min_length=2, max_length=100)
    es_clubes: bool | None = None


class CompeticionRead(TimestampedSchema):
    nombre: str
    ambito: str
    es_clubes: bool
