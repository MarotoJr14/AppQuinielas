from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Enum as SAEnum
from sqlalchemy import Float, ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin
from app.models.enums import CategoriaPremioEnum

if TYPE_CHECKING:
    from app.models.jornada import Jornada


class PremioJornada(Base, TimestampMixin):
    """Premio asociado a una categoría de aciertos (o Elige 8) de una jornada."""

    __tablename__ = "premios_jornada"
    __table_args__ = (UniqueConstraint("jornada_id", "categoria", name="uq_premio_jornada_categoria"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    jornada_id: Mapped[int] = mapped_column(ForeignKey("jornadas.id", ondelete="CASCADE"), nullable=False)
    categoria: Mapped[CategoriaPremioEnum] = mapped_column(
        SAEnum(CategoriaPremioEnum, name="categoria_premio_enum"), nullable=False
    )
    valor: Mapped[float | None] = mapped_column(Float, nullable=True)

    jornada: Mapped["Jornada"] = relationship(back_populates="premios")

    def __repr__(self) -> str:
        return f"<PremioJornada jornada_id={self.jornada_id} categoria={self.categoria} valor={self.valor}>"
