import 'api_client.dart';
import '../models/mensaje.dart';

class MensajeService {
  final ApiClient client;
  MensajeService(this.client);

  Future<Mensaje> enviar({required int grupoId, required String contenido}) async {
    final data = await client.post('/mensajes', body: {'grupo_id': grupoId, 'contenido': contenido});
    return Mensaje.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Mensaje>> listar(int grupoId, {int skip = 0, int limit = 50}) async {
    final data = await client.get('/mensajes/grupo/$grupoId', query: {'skip': skip, 'limit': limit});
    return (data as List<dynamic>).map((e) => Mensaje.fromJson(e as Map<String, dynamic>)).toList();
  }
}
