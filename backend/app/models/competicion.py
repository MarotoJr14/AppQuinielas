from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.temporada_competicion import TemporadaCompeticion


class Competicion(Base, TimestampMixin):
    __tablename__ = "competiciones"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(150), unique=True, nullable=False)
    ambito: Mapped[str] = mapped_column(String(100), nullable=False)
    es_clubes: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    temporadas_competiciones: Mapped[list["TemporadaCompeticion"]] = relationship(
        back_populates="competicion", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Competicion id={self.id} nombre={self.nombre!r}>"
