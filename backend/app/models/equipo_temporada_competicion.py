from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.equipo import Equipo
    from app.models.temporada_competicion import TemporadaCompeticion


class EquipoTemporadaCompeticion(Base, TimestampMixin):
    """Tabla de unión Equipo <-> TemporadaCompeticion (equipos participantes en una edición)."""

    __tablename__ = "equipos_temporadas_competiciones"
    __table_args__ = (
        UniqueConstraint("equipo_id", "temporada_competicion_id", name="uq_equipo_temporada_competicion"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    equipo_id: Mapped[int] = mapped_column(ForeignKey("equipos.id", ondelete="CASCADE"), nullable=False)
    temporada_competicion_id: Mapped[int] = mapped_column(
        ForeignKey("temporadas_competiciones.id", ondelete="CASCADE"), nullable=False
    )

    equipo: Mapped["Equipo"] = relationship(back_populates="equipos_temporadas_competiciones")
    temporada_competicion: Mapped["TemporadaCompeticion"] = relationship(
        back_populates="equipos_temporadas_competiciones"
    )

    def __repr__(self) -> str:
        return (
            f"<EquipoTemporadaCompeticion equipo_id={self.equipo_id} "
            f"temporada_competicion_id={self.temporada_competicion_id}>"
        )
