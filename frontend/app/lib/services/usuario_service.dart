import 'api_client.dart';
import '../models/usuario.dart';

class UsuarioService {
  final ApiClient client;
  UsuarioService(this.client);

  Future<Usuario> obtenerMiUsuario() async {
    final data = await client.get('/usuarios/me');
    return Usuario.fromJson(data as Map<String, dynamic>);
  }

  Future<Usuario> obtenerUsuario(int id) async {
    final data = await client.get('/usuarios/$id');
    return Usuario.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Usuario>> listar({int skip = 0, int limit = 100}) async {
    final data = await client.get('/usuarios', query: {'skip': skip, 'limit': limit});
    return (data as List<dynamic>).map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Usuario> actualizarMiUsuario({String? nombreUsuario, String? password}) async {
    final body = <String, dynamic>{};
    if (nombreUsuario != null) body['nombre_usuario'] = nombreUsuario;
    if (password != null) body['password'] = password;
    final data = await client.patch('/usuarios/me', body: body);
    return Usuario.fromJson(data as Map<String, dynamic>);
  }
}
