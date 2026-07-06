from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Boolean, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.apuesta import Apuesta
    from app.models.usuario import Usuario
    from app.models.pronostico import Pronostico


class Columna(Base, TimestampMixin):
    """Columna (apuesta individual) de un usuario dentro de una apuesta/quiniela."""

    __tablename__ = "columnas"
    __table_args__ = (
        # Solo puede existir una columna Elige 8 por apuesta (índice único parcial).
        Index(
            "uq_apuesta_elige8",
            "apuesta_id",
            unique=True,
            postgresql_where="es_elige8 = true",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    apuesta_id: Mapped[int] = mapped_column(ForeignKey("apuestas.id", ondelete="CASCADE"), nullable=False)
    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)
    es_elige8: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    apuesta: Mapped["Apuesta"] = relationship(back_populates="columnas")
    usuario: Mapped["Usuario"] = relationship(back_populates="columnas")
    pronosticos: Mapped[list["Pronostico"]] = relationship(back_populates="columna", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Columna id={self.id} apuesta_id={self.apuesta_id} usuario_id={self.usuario_id} es_elige8={self.es_elige8}>"
