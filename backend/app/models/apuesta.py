from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Enum as SAEnum
from sqlalchemy import Float, ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin
from app.models.enums import EstadoApuestaEnum

if TYPE_CHECKING:
    from app.models.jornada import Jornada
    from app.models.grupo import Grupo
    from app.models.usuario import Usuario
    from app.models.columna import Columna


class Apuesta(Base, TimestampMixin):
    """Quiniela que realiza un grupo sobre una jornada concreta."""

    __tablename__ = "apuestas"
    __table_args__ = (UniqueConstraint("jornada_id", "grupo_id", name="uq_apuesta_jornada_grupo"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    jornada_id: Mapped[int] = mapped_column(ForeignKey("jornadas.id", ondelete="CASCADE"), nullable=False)
    grupo_id: Mapped[int] = mapped_column(ForeignKey("grupos.id", ondelete="CASCADE"), nullable=False)
    usuario_elige8_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)
    estado: Mapped[EstadoApuestaEnum] = mapped_column(
        SAEnum(EstadoApuestaEnum, name="estado_apuesta_enum"),
        nullable=False,
        default=EstadoApuestaEnum.pendiente,
    )
    precio: Mapped[float | None] = mapped_column(Float, nullable=True)
    beneficio: Mapped[float | None] = mapped_column(Float, nullable=True)

    jornada: Mapped["Jornada"] = relationship(back_populates="apuestas")
    grupo: Mapped["Grupo"] = relationship(back_populates="apuestas")
    usuario_elige8: Mapped["Usuario"] = relationship(back_populates="apuestas_elige8")
    columnas: Mapped[list["Columna"]] = relationship(back_populates="apuesta", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Apuesta id={self.id} jornada_id={self.jornada_id} grupo_id={self.grupo_id} estado={self.estado}>"
