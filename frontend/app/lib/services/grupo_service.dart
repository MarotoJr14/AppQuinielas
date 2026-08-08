import 'api_client.dart';
import '../models/grupo.dart';

class GrupoService {
  final ApiClient client;
  GrupoService(this.client);

  Future<Grupo> crear({required String nombre, required String password}) async {
    final data = await client.post('/grupos', body: {'nombre': nombre, 'password': password});
    return Grupo.fromJson(data as Map<String, dynamic>);
  }

  Future<UsuarioGrupo> unirse({required String nombre, required String password}) async {
    final data = await client.post('/grupos/unirse', body: {'nombre': nombre, 'password': password});
    return UsuarioGrupo.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Grupo>> listarMisGrupos({String? search}) async {
    final data = await client.get('/grupos', query: search != null && search.isNotEmpty ? {'search': search} : null);
    return (data as List<dynamic>).map((e) => Grupo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Grupo> obtener(int grupoId) async {
    final data = await client.get('/grupos/$grupoId');
    return Grupo.fromJson(data as Map<String, dynamic>);
  }

  Future<Grupo> actualizar(int grupoId, {String? nombre, String? password}) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (password != null) body['password'] = password;
    final data = await client.patch('/grupos/$grupoId', body: body);
    return Grupo.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UsuarioGrupo>> listarMiembros(int grupoId) async {
    final data = await client.get('/grupos/$grupoId/miembros');
    return (data as List<dynamic>).map((e) => UsuarioGrupo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cambiarLider(int grupoId, int nuevoLiderId) async {
    await client.post('/grupos/$grupoId/lider/$nuevoLiderId');
  }
}
