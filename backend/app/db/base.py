"""
Importa todos los modelos para que Alembic y SQLAlchemy los registren
en los metadatos de Base antes de generar migraciones.
"""
from app.db.base_class import Base  # noqa
from app.models.usuario import Usuario  # noqa
from app.models.grupo import Grupo  # noqa
from app.models.usuario_grupo import UsuarioGrupo  # noqa
from app.models.temporada import Temporada  # noqa
from app.models.jornada import Jornada  # noqa
from app.models.premio_jornada import PremioJornada  # noqa
from app.models.competicion import Competicion  # noqa
from app.models.temporada_competicion import TemporadaCompeticion  # noqa
from app.models.equipo import Equipo  # noqa
from app.models.equipo_temporada_competicion import EquipoTemporadaCompeticion  # noqa
from app.models.partido import Partido  # noqa
from app.models.apuesta import Apuesta  # noqa
from app.models.columna import Columna  # noqa
from app.models.pronostico import Pronostico  # noqa
from app.models.mensaje import Mensaje  # noqa
from app.models.audit_log import AuditLog  # noqa
