from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.jornada import Jornada
    from app.models.temporada_competicion import TemporadaCompeticion


class Temporada(Base, TimestampMixin):
    __tablename__ = "temporadas"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)

    jornadas: Mapped[list["Jornada"]] = relationship(back_populates="temporada", cascade="all, delete-orphan")
    temporadas_competiciones: Mapped[list["TemporadaCompeticion"]] = relationship(
        back_populates="temporada", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Temporada id={self.id} nombre={self.nombre!r}>"
