"""Lógica de evaluación de pronósticos (aciertos/fallos) de una quiniela."""
from app.models.enums import GolesEnum, SignoEnum
from app.models.partido import Partido
from app.models.pronostico import Pronostico


def evaluar_signo(partido: Partido, signo: SignoEnum | None) -> bool | None:
    """Devuelve True (acierto), False (fallo) o None (pendiente de resolver)."""
    if partido.goles_local is None or partido.goles_visitante is None:
        return None
    if signo is None:
        return False
    if signo == SignoEnum.UNO:
        return partido.goles_local > partido.goles_visitante
    if signo == SignoEnum.X:
        return partido.goles_local == partido.goles_visitante
    if signo == SignoEnum.DOS:
        return partido.goles_local < partido.goles_visitante
    return False


def _goles_equivalen(goles_reales: int, pronostico: GolesEnum | None) -> bool:
    if pronostico is None:
        return False
    if goles_reales >= 3:
        return pronostico == GolesEnum.M
    return pronostico == GolesEnum(str(goles_reales))


def evaluar_pleno_al_15(
    partido: Partido,
    pleno_local: GolesEnum | None,
    pleno_visitante: GolesEnum | None,
) -> bool | None:
    """El Pleno al 15 (Elige 8) se acierta solo si aciertan ambos marcadores."""
    if partido.goles_local is None or partido.goles_visitante is None:
        return None
    acierto_local = _goles_equivalen(partido.goles_local, pleno_local)
    acierto_visitante = _goles_equivalen(partido.goles_visitante, pleno_visitante)
    return acierto_local and acierto_visitante


def evaluar_pronostico(pronostico: Pronostico, partido: Partido, es_elige8: bool) -> bool | None:
    """Evalúa un pronóstico individual. En el partido 15 de la columna Elige 8 se usa
    el pleno al 15 (goles); en el resto (incluido el 15 de columnas normales) se usa el signo 1X2."""
    if es_elige8 and partido.es_pleno_al_15:
        return evaluar_pleno_al_15(partido, pronostico.pleno15_local, pronostico.pleno15_visitante)
    return evaluar_signo(partido, pronostico.signo)


def contar_aciertos_fallos_pendientes(
    pronosticos: list[Pronostico],
    partidos_por_id: dict[int, Partido],
    es_elige8: bool,
) -> tuple[int, int, int]:
    aciertos = fallos = pendientes = 0
    for pronostico in pronosticos:
        partido = partidos_por_id.get(pronostico.partido_id)
        if partido is None:
            continue
        resultado = evaluar_pronostico(pronostico, partido, es_elige8)
        if resultado is None:
            pendientes += 1
        elif resultado:
            aciertos += 1
        else:
            fallos += 1
    return aciertos, fallos, pendientes
