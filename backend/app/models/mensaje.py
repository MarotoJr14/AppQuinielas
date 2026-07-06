from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.grupo import Grupo
    from app.models.usuario import Usuario


class Mensaje(Base, TimestampMixin):
    """Mensaje enviado por un usuario al chat interno de un grupo."""

    __tablename__ = "mensajes"

    id: Mapped[int] = mapped_column(primary_key=True)
    grupo_id: Mapped[int] = mapped_column(ForeignKey("grupos.id", ondelete="CASCADE"), nullable=False)
    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)
    enviado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    contenido: Mapped[str] = mapped_column(Text, nullable=False)

    grupo: Mapped["Grupo"] = relationship(back_populates="mensajes")
    usuario: Mapped["Usuario"] = relationship(back_populates="mensajes")

    def __repr__(self) -> str:
        return f"<Mensaje id={self.id} grupo_id={self.grupo_id} usuario_id={self.usuario_id}>"
