import 'api_client.dart';
import '../models/usuario.dart';

class AuthService {
  final ApiClient client;
  AuthService(this.client);

  Future<Usuario> registro({
    required String nombreUsuario,
    required String email,
    required String password,
  }) async {
    final data = await client.post('/auth/registro', body: {
      'nombre_usuario': nombreUsuario,
      'email': email,
      'password': password,
    });
    return Usuario.fromJson(data as Map<String, dynamic>);
  }

  /// Devuelve el token de acceso JWT.
  Future<String> login({required String nombreUsuario, required String password}) async {
    final data = await client.post('/auth/login', body: {
      'nombre_usuario': nombreUsuario,
      'password': password,
    });
    return (data as Map<String, dynamic>)['access_token'] as String;
  }

  Future<void> solicitarRecuperacion(String email) async {
    await client.post('/auth/recuperar-password', query: {'email': email});
  }

  Future<void> restablecerPassword({required String email, required String nuevaPassword}) async {
    await client.post('/auth/restablecer-password', body: {
      'email': email,
      'nueva_password': nuevaPassword,
    });
  }
}
