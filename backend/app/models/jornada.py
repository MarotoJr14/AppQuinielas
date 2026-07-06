from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.temporada import Temporada
    from app.models.premio_jornada import PremioJornada
    from app.models.partido import Partido
    from app.models.apuesta import Apuesta


class Jornada(Base, TimestampMixin):
    __tablename__ = "jornadas"
    __table_args__ = (UniqueConstraint("temporada_id", "nombre", name="uq_jornada_temporada_nombre"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    temporada_id: Mapped[int] = mapped_column(ForeignKey("temporadas.id", ondelete="CASCADE"), nullable=False)
    nombre: Mapped[str] = mapped_column(String(150), nullable=False)
    fecha_cierre: Mapped[datetime] = mapped_column(DateTime(timezone=True), unique=True, nullable=False)

    temporada: Mapped["Temporada"] = relationship(back_populates="jornadas")
    premios: Mapped[list["PremioJornada"]] = relationship(back_populates="jornada", cascade="all, delete-orphan")
    partidos: Mapped[list["Partido"]] = relationship(
        back_populates="jornada", cascade="all, delete-orphan", order_by="Partido.orden"
    )
    apuestas: Mapped[list["Apuesta"]] = relationship(back_populates="jornada", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Jornada id={self.id} nombre={self.nombre!r}>"
