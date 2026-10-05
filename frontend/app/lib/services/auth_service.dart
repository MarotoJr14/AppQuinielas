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

  Future<Map<String, String>> login({required String nombreUsuario, required String password}) async {
    final data = await client.post('/auth/login', body: {
      'nombre_usuario': nombreUsuario,
      'password': password,
    });
    final json = data as Map<String, dynamic>;
    return {
      'access_token': json['access_token'] as String,
      'refresh_token': json['refresh_token'] as String,
    };
  }

  Future<void> logout({String? refreshToken}) async {
    final payload = refreshToken == null ? <String, dynamic>{} : {'refresh_token': refreshToken};
    await client.post('/auth/logout', body: payload);
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
