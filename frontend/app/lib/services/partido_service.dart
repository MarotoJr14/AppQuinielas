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

  Future<List<TemporadaCompeticion>> listarCompeticionesPorTemporada(int temporadaId) async {
    final data = await client.get('/temporada-competiciones/por-temporada/$temporadaId');
    return (data as List<dynamic>).map((e) => TemporadaCompeticion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Equipo>> listarEquiposPorCompeticionTemporada(int competicionTemporadaId) async {
    final data = await client.get('/equipo-temporada-competiciones/por-competicion-temporada/$competicionTemporadaId');
    return (data as List<dynamic>).map((e) {
      final json = e as Map<String, dynamic>;
      // Traemos los datos del equipo desde la relación
      final equipoData = json['equipo'] as Map<String, dynamic>?;
      if (equipoData != null) {
        return Equipo.fromJson(equipoData);
      }
      // Si no hay relación, intentamos obtener desde equipo_id
      return Equipo(
        id: json['equipo_id'] as int,
        nombre: 'Equipo',
        esClub: true,
        pais: '',
      );
    }).toList();
  }

  Future<Partido> crear({
    required int jornadaId,
    required int orden,
    String estado = 'pendiente',
    int? competicionTemporadaId,
    DateTime? fechaHora,
    String? canal,
    int? equipoLocalId,
    int? equipoVisitanteId,
  }) async {
    final data = await client.post('/partidos', body: {
      'jornada_id': jornadaId,
      'orden': orden,
      'estado': estado,
      'competicion_temporada_id': competicionTemporadaId,
      'fecha_hora': fechaHora?.toUtc().toIso8601String(),
      'canal': canal,
      'equipo_local_id': equipoLocalId,
      'equipo_visitante_id': equipoVisitanteId,
    });
    return Partido.fromJson(data as Map<String, dynamic>);
  }

  Future<Partido> registrarResultado(int partidoId, {required int golesLocal, required int golesVisitante, String? estado}) async {
    final body = <String, dynamic>{
      'goles_local': golesLocal,
      'goles_visitante': golesVisitante,
    };
    if (estado != null) body['estado'] = estado;
    final data = await client.post('/partidos/$partidoId/resultado', body: body);
    return Partido.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Competicion>> listarCompeticionesGlobales() async {
    final data = await client.get('/competiciones');
    return (data as List<dynamic>).map((e) => Competicion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Competicion> crearCompeticion({required String nombre, required String ambito, bool esClubs = true}) async {
    final data = await client.post('/competiciones', body: {
      'nombre': nombre,
      'ambito': ambito,
      'es_clubes': esClubs,
    });
    return Competicion.fromJson(data as Map<String, dynamic>);
  }

  Future<TemporadaCompeticion> vincularCompeticionATemporada({required int temporadaId, required int competicionId}) async {
    final data = await client.post('/temporada-competiciones', body: {
      'temporada_id': temporadaId,
      'competicion_id': competicionId,
    });
    return TemporadaCompeticion.fromJson(data as Map<String, dynamic>);
  }

  Future<Partido> actualizar(
    int partidoId, {
    String? estado,
    int? competicionTemporadaId,
    int? equipoLocalId,
    int? equipoVisitanteId,
    DateTime? fechaHora,
    String? canal,
  }) async {
    final body = <String, dynamic>{};
    if (estado != null) body['estado'] = estado;
    if (competicionTemporadaId != null) body['competicion_temporada_id'] = competicionTemporadaId;
    if (equipoLocalId != null) body['equipo_local_id'] = equipoLocalId;
    if (equipoVisitanteId != null) body['equipo_visitante_id'] = equipoVisitanteId;
    if (fechaHora != null) body['fecha_hora'] = fechaHora.toUtc().toIso8601String();
    if (canal != null) body['canal'] = canal;
    final data = await client.patch('/partidos/$partidoId', body: body);
    return Partido.fromJson(data as Map<String, dynamic>);
  }
}
