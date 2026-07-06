from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.usuario_grupo import UsuarioGrupo
    from app.models.apuesta import Apuesta
    from app.models.columna import Columna
    from app.models.mensaje import Mensaje
    from app.models.audit_log import AuditLog


class Usuario(Base, TimestampMixin):
    __tablename__ = "usuarios"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre_usuario: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)

    usuarios_grupos: Mapped[list["UsuarioGrupo"]] = relationship(
        back_populates="usuario", cascade="all, delete-orphan"
    )
    apuestas_elige8: Mapped[list["Apuesta"]] = relationship(back_populates="usuario_elige8")
    columnas: Mapped[list["Columna"]] = relationship(back_populates="usuario")
    mensajes: Mapped[list["Mensaje"]] = relationship(back_populates="usuario")
    audit_logs: Mapped[list["AuditLog"]] = relationship(back_populates="usuario")

    def __repr__(self) -> str:
        return f"<Usuario id={self.id} nombre_usuario={self.nombre_usuario!r}>"
