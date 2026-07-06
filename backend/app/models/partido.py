from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.jornada import Jornada
    from app.models.temporada_competicion import TemporadaCompeticion
    from app.models.equipo import Equipo
    from app.models.pronostico import Pronostico


class Partido(Base, TimestampMixin):
    """Partido de una jornada de quinielas. Una jornada tiene 14 partidos + el Pleno al 15 (orden=15)."""

    __tablename__ = "partidos"
    __table_args__ = (UniqueConstraint("jornada_id", "orden", name="uq_partido_jornada_orden"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    jornada_id: Mapped[int] = mapped_column(ForeignKey("jornadas.id", ondelete="CASCADE"), nullable=False)
    orden: Mapped[int] = mapped_column(Integer, nullable=False)
    competicion_temporada_id: Mapped[int | None] = mapped_column(
        ForeignKey("temporadas_competiciones.id", ondelete="SET NULL"), nullable=True
    )
    fecha_hora: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    canal: Mapped[str | None] = mapped_column(String(100), nullable=True)
    equipo_local_id: Mapped[int | None] = mapped_column(ForeignKey("equipos.id", ondelete="SET NULL"), nullable=True)
    equipo_visitante_id: Mapped[int | None] = mapped_column(
        ForeignKey("equipos.id", ondelete="SET NULL"), nullable=True
    )
    goles_local: Mapped[int | None] = mapped_column(Integer, nullable=True)
    goles_visitante: Mapped[int | None] = mapped_column(Integer, nullable=True)

    jornada: Mapped["Jornada"] = relationship(back_populates="partidos")
    competicion_temporada: Mapped["TemporadaCompeticion | None"] = relationship(back_populates="partidos")
    equipo_local: Mapped["Equipo | None"] = relationship(foreign_keys=[equipo_local_id])
    equipo_visitante: Mapped["Equipo | None"] = relationship(foreign_keys=[equipo_visitante_id])
    pronosticos: Mapped[list["Pronostico"]] = relationship(back_populates="partido", cascade="all, delete-orphan")

    @property
    def es_pleno_al_15(self) -> bool:
        return self.orden == 15

    def __repr__(self) -> str:
        return f"<Partido id={self.id} jornada_id={self.jornada_id} orden={self.orden}>"
