import 'api_client.dart';
import '../models/partido.dart';

class PartidoService {
  final ApiClient client;
  PartidoService(this.client);

  Future<List<Partido>> listarPorJornada(int jornadaId) async {
    final data = await client.get('/partidos/jornada/$jornadaId');
    return (data as List<dynamic>).map((e) => Partido.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));
  }

  Future<Partido> crear({
    required int jornadaId,
    required int orden,
    DateTime? fechaHora,
    String? canal,
    int? equipoLocalId,
    int? equipoVisitanteId,
  }) async {
    final data = await client.post('/partidos', body: {
      'jornada_id': jornadaId,
      'orden': orden,
      'fecha_hora': fechaHora?.toUtc().toIso8601String(),
      'canal': canal,
      'equipo_local_id': equipoLocalId,
      'equipo_visitante_id': equipoVisitanteId,
    });
    return Partido.fromJson(data as Map<String, dynamic>);
  }

  Future<Partido> registrarResultado(int partidoId, {required int golesLocal, required int golesVisitante}) async {
    final data = await client.post('/partidos/$partidoId/resultado', body: {
      'goles_local': golesLocal,
      'goles_visitante': golesVisitante,
    });
    return Partido.fromJson(data as Map<String, dynamic>);
  }

  Future<Partido> actualizar(
    int partidoId, {
    int? equipoLocalId,
    int? equipoVisitanteId,
    DateTime? fechaHora,
    String? canal,
  }) async {
    final body = <String, dynamic>{};
    if (equipoLocalId != null) body['equipo_local_id'] = equipoLocalId;
    if (equipoVisitanteId != null) body['equipo_visitante_id'] = equipoVisitanteId;
    if (fechaHora != null) body['fecha_hora'] = fechaHora.toUtc().toIso8601String();
    if (canal != null) body['canal'] = canal;
    final data = await client.patch('/partidos/$partidoId', body: body);
    return Partido.fromJson(data as Map<String, dynamic>);
  }
}
