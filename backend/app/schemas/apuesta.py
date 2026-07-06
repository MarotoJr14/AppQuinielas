from pydantic import BaseModel

from app.models.enums import EstadoApuestaEnum
from app.schemas.columna import ColumnaReadDetalle
from app.schemas.common import TimestampedSchema
from app.schemas.partido import PartidoRead
from app.schemas.premio_jornada import PremioJornadaRead


class ApuestaCreate(BaseModel):
    jornada_id: int
    grupo_id: int
    usuario_elige8_id: int


class ApuestaUpdate(BaseModel):
    estado: EstadoApuestaEnum | None = None
    usuario_elige8_id: int | None = None


class ApuestaRead(TimestampedSchema):
    jornada_id: int
    grupo_id: int
    usuario_elige8_id: int
    estado: EstadoApuestaEnum
    precio: float | None
    beneficio: float | None


class ApuestaReadDetalle(ApuestaRead):
    partidos: list[PartidoRead] = []
    columnas: list[ColumnaReadDetalle] = []
    premios: list[PremioJornadaRead] = []


class RankingFila(BaseModel):
    columna_id: int
    usuario_id: int
    nombre_usuario: str
    es_elige8: bool
    aciertos: int
    fallos: int
    pendientes: int
    en_racha: bool  # verde: elige8 sin fallos, o normal con <=4 fallos
