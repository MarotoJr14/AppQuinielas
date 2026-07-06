import 'api_client.dart';
import '../models/apuesta.dart';
import '../models/pronostico.dart';

class ColumnaService {
  final ApiClient client;
  ColumnaService(this.client);

  Future<Columna> rellenar({
    required int apuestaId,
    required int usuarioId,
    required bool esElige8,
    required List<Pronostico> pronosticos,
  }) async {
    final data = await client.post('/columnas', body: {
      'apuesta_id': apuestaId,
      'usuario_id': usuarioId,
      'es_elige8': esElige8,
      'pronosticos': pronosticos.map((p) => p.toJson()).toList(),
    });
    return Columna.fromJson(data as Map<String, dynamic>);
  }

  Future<Columna> editar({
    required int columnaId,
    required List<Pronostico> pronosticos,
  }) async {
    final data = await client.patch('/columnas/$columnaId', body: {
      'pronosticos': pronosticos.map((p) => p.toJson()).toList(),
    });
    return Columna.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Columna>> listarPorApuesta(int apuestaId) async {
    final data = await client.get('/columnas/apuesta/$apuestaId');
    return (data as List<dynamic>).map((e) => Columna.fromJson(e as Map<String, dynamic>)).toList();
  }
}
