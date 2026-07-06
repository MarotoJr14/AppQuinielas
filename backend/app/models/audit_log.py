from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import Enum as SAEnum
from sqlalchemy import ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin
from app.models.enums import OperacionEnum, TablaEnum

if TYPE_CHECKING:
    from app.models.usuario import Usuario


class AuditLog(Base, TimestampMixin):
    """Registro de auditoría de las operaciones realizadas en la aplicación."""

    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(primary_key=True)
    operacion: Mapped[OperacionEnum] = mapped_column(SAEnum(OperacionEnum, name="operacion_enum"), nullable=False)
    tabla: Mapped[TablaEnum] = mapped_column(SAEnum(TablaEnum, name="tabla_enum"), nullable=False)
    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)
    observaciones: Mapped[str | None] = mapped_column(Text, nullable=True)

    usuario: Mapped["Usuario"] = relationship(back_populates="audit_logs")

    def __repr__(self) -> str:
        return f"<AuditLog id={self.id} operacion={self.operacion} tabla={self.tabla}>"
