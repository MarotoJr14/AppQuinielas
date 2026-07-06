from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.temporada import Temporada
    from app.models.competicion import Competicion
    from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion
    from app.models.partido import Partido


class TemporadaCompeticion(Base, TimestampMixin):
    """Tabla de unión Temporada <-> Competición (edición de una competición)."""

    __tablename__ = "temporadas_competiciones"
    __table_args__ = (
        UniqueConstraint("temporada_id", "competicion_id", name="uq_temporada_competicion"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    temporada_id: Mapped[int] = mapped_column(ForeignKey("temporadas.id", ondelete="CASCADE"), nullable=False)
    competicion_id: Mapped[int] = mapped_column(ForeignKey("competiciones.id", ondelete="CASCADE"), nullable=False)

    temporada: Mapped["Temporada"] = relationship(back_populates="temporadas_competiciones")
    competicion: Mapped["Competicion"] = relationship(back_populates="temporadas_competiciones")
    equipos_temporadas_competiciones: Mapped[list["EquipoTemporadaCompeticion"]] = relationship(
        back_populates="temporada_competicion", cascade="all, delete-orphan"
    )
    partidos: Mapped[list["Partido"]] = relationship(back_populates="competicion_temporada")

    def __repr__(self) -> str:
        return f"<TemporadaCompeticion temporada_id={self.temporada_id} competicion_id={self.competicion_id}>"
