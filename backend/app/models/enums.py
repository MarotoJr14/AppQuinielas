import enum


class SignoEnum(str, enum.Enum):
    """Pronóstico 1X2 de un partido normal."""
    UNO = "1"
    X = "X"
    DOS = "2"


class GolesEnum(str, enum.Enum):
    """Pronóstico de goles del Pleno al 15 (columna Elige 8)."""
    CERO = "0"
    UNO = "1"
    DOS = "2"
    M = "M"  # 3 o más goles


class EstadoApuestaEnum(str, enum.Enum):
    pendiente = "pendiente"
    cerrada = "cerrada"
    en_curso = "en_curso"
    finalizada = "finalizada"


class CategoriaPremioEnum(str, enum.Enum):
    ACIERTOS_15 = "15 aciertos"
    ACIERTOS_14 = "14 aciertos"
    ACIERTOS_13 = "13 aciertos"
    ACIERTOS_12 = "12 aciertos"
    ACIERTOS_11 = "11 aciertos"
    ACIERTOS_10 = "10 aciertos"
    ELIGE_8 = "elige 8"


class OperacionEnum(str, enum.Enum):
    create = "create"
    update = "update"
    delete = "delete"


class TablaEnum(str, enum.Enum):
    usuario = "usuario"
    grupo = "grupo"
    usuario_grupo = "usuario-grupo"
    temporada = "temporada"
    jornada = "jornada"
    premio = "premio"
    competicion = "competicion"
    temporada_competicion = "temporada-competicion"
    equipo = "equipo"
    equipo_temporada_competicion = "equipo-temporada-competicion"
    partido = "partido"
    apuesta = "apuesta"
    columna = "columna"
    pronostico = "pronostico"
    mensaje = "mensaje"
