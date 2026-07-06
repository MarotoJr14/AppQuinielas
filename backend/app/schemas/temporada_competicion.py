from pydantic import BaseModel

from app.schemas.common import TimestampedSchema


class TemporadaCompeticionCreate(BaseModel):
    temporada_id: int
    competicion_id: int


class TemporadaCompeticionRead(TimestampedSchema):
    temporada_id: int
    competicion_id: int
