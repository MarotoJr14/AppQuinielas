from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.usuario_grupo import UsuarioGrupo
    from app.models.apuesta import Apuesta
    from app.models.mensaje import Mensaje


class Grupo(Base, TimestampMixin):
    __tablename__ = "grupos"

    id: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    usuarios_grupos: Mapped[list["UsuarioGrupo"]] = relationship(
        back_populates="grupo", cascade="all, delete-orphan"
    )
    apuestas: Mapped[list["Apuesta"]] = relationship(back_populates="grupo", cascade="all, delete-orphan")
    mensajes: Mapped[list["Mensaje"]] = relationship(back_populates="grupo", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Grupo id={self.id} nombre={self.nombre!r}>"
