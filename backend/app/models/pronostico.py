from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Enum as SAEnum
from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin
from app.models.enums import GolesEnum, SignoEnum

if TYPE_CHECKING:
    from app.models.columna import Columna
    from app.models.partido import Partido


class Pronostico(Base, TimestampMixin):
    """Pronóstico de un usuario (columna) para un partido concreto de una jornada."""

    __tablename__ = "pronosticos"
    __table_args__ = (UniqueConstraint("columna_id", "partido_id", name="uq_pronostico_columna_partido"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    columna_id: Mapped[int] = mapped_column(ForeignKey("columnas.id", ondelete="CASCADE"), nullable=False)
    partido_id: Mapped[int] = mapped_column(ForeignKey("partidos.id", ondelete="CASCADE"), nullable=False)

    # Pronóstico 1X2, usado en los 14 partidos normales (y opcionalmente en el 15 para columnas no-elige8).
    signo: Mapped[SignoEnum | None] = mapped_column(SAEnum(SignoEnum, name="signo_enum"), nullable=True)

    # Pronóstico de goles del Pleno al 15, exclusivo de la columna Elige 8.
    pleno15_local: Mapped[GolesEnum | None] = mapped_column(SAEnum(GolesEnum, name="goles_enum"), nullable=True)
    pleno15_visitante: Mapped[GolesEnum | None] = mapped_column(SAEnum(GolesEnum, name="goles_enum"), nullable=True)

    columna: Mapped["Columna"] = relationship(back_populates="pronosticos")
    partido: Mapped["Partido"] = relationship(back_populates="pronosticos")

    def __repr__(self) -> str:
        return f"<Pronostico columna_id={self.columna_id} partido_id={self.partido_id} signo={self.signo}>"
