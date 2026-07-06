from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.common import TimestampedSchema


class MensajeCreate(BaseModel):
    grupo_id: int
    contenido: str = Field(min_length=1, max_length=2000)


class MensajeRead(TimestampedSchema):
    grupo_id: int
    usuario_id: int
    enviado_en: datetime
    contenido: str
