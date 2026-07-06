import '../models/apuesta.dart';
import '../models/partido.dart';
import '../state/auth_provider.dart';

/// El backend solo distingue explícitamente entre los estados "pendiente"
/// (aún no pagada / en fase de rellenar columnas) y "cerrada" (el líder ha
/// cerrado la quiniela y ya no admite cambios). Los estados "en_curso" y
/// "finalizada" del modelo de datos se derivan aquí, en el cliente, en
/// función de si los 15 partidos de la jornada ya tienen resultado o no:
/// - cerrada + no todos los partidos resueltos -> "en curso"
/// - cerrada + todos los partidos resueltos -> "finalizada"
Future<bool> apuestaCompletada(AuthProvider auth, Apuesta apuesta) async {
  final partidos = await auth.partidoService.listarPorJornada(apuesta.jornadaId);
  if (partidos.isEmpty) return false;
  return partidos.every((p) => p.tieneResultado);
}

bool partidosCompletados(List<Partido> partidos) {
  if (partidos.isEmpty) return false;
  return partidos.every((p) => p.tieneResultado);
}
