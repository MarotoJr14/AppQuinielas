from pydantic import BaseModel

from app.models.enums import OperacionEnum, TablaEnum
from app.schemas.common import TimestampedSchema


class AuditLogCreate(BaseModel):
    operacion: OperacionEnum
    tabla: TablaEnum
    usuario_id: int
    observaciones: str | None = None


class AuditLogRead(TimestampedSchema):
    operacion: OperacionEnum
    tabla: TablaEnum
    usuario_id: int
    observaciones: str | None
