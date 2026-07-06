from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion


class Equipo(Base, TimestampMixin):
    __tablename__ = "equipos"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(150), unique=True, nullable=False)
    es_club: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    pais: Mapped[str] = mapped_column(String(100), nullable=False)

    equipos_temporadas_competiciones: Mapped[list["EquipoTemporadaCompeticion"]] = relationship(
        back_populates="equipo", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Equipo id={self.id} nombre={self.nombre!r}>"
