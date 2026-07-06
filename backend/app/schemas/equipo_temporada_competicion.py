from pydantic import BaseModel

from app.schemas.common import TimestampedSchema


class EquipoTemporadaCompeticionCreate(BaseModel):
    equipo_id: int
    temporada_competicion_id: int


class EquipoTemporadaCompeticionRead(TimestampedSchema):
    equipo_id: int
    temporada_competicion_id: int
