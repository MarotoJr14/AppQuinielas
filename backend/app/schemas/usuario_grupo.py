from pydantic import BaseModel

from app.schemas.common import TimestampedSchema


class UsuarioGrupoCreate(BaseModel):
    grupo_id: int
    usuario_id: int
    es_lider: bool = False


class UsuarioGrupoUpdate(BaseModel):
    es_lider: bool | None = None


class UsuarioGrupoRead(TimestampedSchema):
    grupo_id: int
    usuario_id: int
    es_lider: bool
