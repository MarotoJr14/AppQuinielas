import 'api_client.dart';
import '../models/temporada_jornada.dart';

class JornadaService {
  final ApiClient client;
  JornadaService(this.client);

  Future<List<Temporada>> listarTemporadas() async {
    final data = await client.get('/temporadas');
    return (data as List<dynamic>).map((e) => Temporada.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Temporada> crearTemporada(String nombre) async {
    final data = await client.post('/temporadas', body: {'nombre': nombre});
    return Temporada.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Jornada>> listarTodas({int skip = 0, int limit = 200}) async {
    final data = await client.get('/jornadas', query: {'skip': skip, 'limit': limit});
    return (data as List<dynamic>).map((e) => Jornada.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Jornada>> listarDisponibles(int grupoId) async {
    final data = await client.get('/jornadas/disponibles/$grupoId');
    return (data as List<dynamic>).map((e) => Jornada.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Jornada> obtener(int jornadaId) async {
    final data = await client.get('/jornadas/$jornadaId');
    return Jornada.fromJson(data as Map<String, dynamic>);
  }

  Future<Jornada> crear({
    required int temporadaId,
    required String nombre,
    required DateTime fechaCierre,
  }) async {
    final data = await client.post('/jornadas', body: {
      'temporada_id': temporadaId,
      'nombre': nombre,
      'fecha_cierre': fechaCierre.toUtc().toIso8601String(),
    });
    return Jornada.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PremioJornada>> listarPremios(int jornadaId) async {
    final data = await client.get('/premios/jornada/$jornadaId');
    return (data as List<dynamic>).map((e) => PremioJornada.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PremioJornada> crearPremio({
    required int jornadaId,
    required CategoriaPremio categoria,
    double? valor,
  }) async {
    final data = await client.post('/premios', body: {
      'jornada_id': jornadaId,
      'categoria': categoria.valorApi,
      'valor': valor,
    });
    return PremioJornada.fromJson(data as Map<String, dynamic>);
  }

  Future<PremioJornada> actualizarPremio(int premioId, double? valor) async {
    final data = await client.patch('/premios/$premioId', body: {'valor': valor});
    return PremioJornada.fromJson(data as Map<String, dynamic>);
  }
}
