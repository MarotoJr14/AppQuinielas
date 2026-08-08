import '../models/apuesta.dart';
import '../models/partido.dart';
import '../state/auth_provider.dart';

/// El backend mantiene ahora cuatro estados para la apuesta:
/// - pendiente: aun no se ha cerrado la quiniela.
/// - cerrada: se ha cerrado la quiniela pero no hay suficientes resultados para marcarla en curso.
/// - en_curso: la quiniela ya está cerrada y algunos partidos tienen resultados.
/// - finalizada: todos los partidos de la jornada han terminado.
///
/// En el cliente también se comprueba si todos los partidos tienen resultado
/// para derivar la vista de seguimiento / resultados.
Future<bool> apuestaCompletada(AuthProvider auth, Apuesta apuesta) async {
  final partidos = await auth.partidoService.listarPorJornada(apuesta.jornadaId);
  if (partidos.isEmpty) return false;
  return partidos.every((p) => p.tieneResultado);
}

bool partidosCompletados(List<Partido> partidos) {
  if (partidos.isEmpty) return false;
  return partidos.every((p) => p.tieneResultado);
}
