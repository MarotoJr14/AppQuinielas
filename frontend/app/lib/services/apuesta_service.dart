import 'api_client.dart';
import '../models/apuesta.dart';

class ApuestaService {
  final ApiClient client;
  ApuestaService(this.client);

  Future<Apuesta> crear({
    required int jornadaId,
    required int grupoId,
    required int usuarioElige8Id,
  }) async {
    final data = await client.post('/apuestas', body: {
      'jornada_id': jornadaId,
      'grupo_id': grupoId,
      'usuario_elige8_id': usuarioElige8Id,
    });
    return Apuesta.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Apuesta>> listarEnCola(int grupoId) async {
    final data = await client.get('/apuestas/grupo/$grupoId/en-cola');
    return (data as List<dynamic>).map((e) => Apuesta.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Apuesta>> listarHistorial(int grupoId) async {
    final data = await client.get('/apuestas/grupo/$grupoId/historial');
    return (data as List<dynamic>).map((e) => Apuesta.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Apuesta> obtener(int apuestaId) async {
    final data = await client.get('/apuestas/$apuestaId');
    return Apuesta.fromJson(data as Map<String, dynamic>);
  }

  Future<ApuestaDetalle> obtenerDetalle(int apuestaId) async {
    final data = await client.get('/apuestas/$apuestaId/detalle');
    return ApuestaDetalle.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RankingFila>> ranking(int apuestaId) async {
    final data = await client.get('/apuestas/$apuestaId/ranking');
    return (data as List<dynamic>).map((e) => RankingFila.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Apuesta> recalcular(int apuestaId) async {
    final data = await client.post('/apuestas/$apuestaId/recalcular');
    return Apuesta.fromJson(data as Map<String, dynamic>);
  }

  Future<Apuesta> cerrar(int apuestaId) async {
    final data = await client.post('/apuestas/$apuestaId/cerrar');
    return Apuesta.fromJson(data as Map<String, dynamic>);
  }
}
