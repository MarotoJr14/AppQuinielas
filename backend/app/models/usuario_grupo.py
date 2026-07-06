from __future__ import annotations

from sqlalchemy import Boolean, ForeignKey, Index, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin
from app.models.usuario import Usuario
from app.models.grupo import Grupo


class UsuarioGrupo(Base, TimestampMixin):
    """Tabla de unión Usuario <-> Grupo (pertenencia a una peña)."""

    __tablename__ = "usuarios_grupos"
    __table_args__ = (
        UniqueConstraint("grupo_id", "usuario_id", name="uq_usuario_grupo"),
        # Solo puede existir un líder por grupo (índice único parcial).
        Index(
            "uq_grupo_lider",
            "grupo_id",
            unique=True,
            postgresql_where="es_lider = true",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    grupo_id: Mapped[int] = mapped_column(ForeignKey("grupos.id", ondelete="CASCADE"), nullable=False)
    usuario_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    es_lider: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    grupo: Mapped["Grupo"] = relationship(back_populates="usuarios_grupos")
    usuario: Mapped["Usuario"] = relationship(back_populates="usuarios_grupos")

    def __repr__(self) -> str:
        return f"<UsuarioGrupo grupo_id={self.grupo_id} usuario_id={self.usuario_id} es_lider={self.es_lider}>"
