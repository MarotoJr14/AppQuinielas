import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../services/grupo_service.dart';
import '../services/jornada_service.dart';
import '../services/partido_service.dart';
import '../services/equipo_service.dart';
import '../services/apuesta_service.dart';
import '../services/columna_service.dart';
import '../services/mensaje_service.dart';
import '../services/usuarios_cache.dart';

enum EstadoSesion { cargando, autenticado, invitado }

/// Provider central de sesión: mantiene el token JWT, el usuario actual y
/// expone instancias ya configuradas de todos los servicios de la API
/// (comparten el mismo [ApiClient], por lo que el token se actualiza para
/// todos ellos automáticamente al iniciar/cerrar sesión).
class AuthProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  late final AuthService authService = AuthService(_client);
  late final UsuarioService usuarioService = UsuarioService(_client);
  late final GrupoService grupoService = GrupoService(_client);
  late final JornadaService jornadaService = JornadaService(_client);
  late final PartidoService partidoService = PartidoService(_client);
  late final EquipoService equipoService = EquipoService(_client);
  late final EquiposCache equiposCache = EquiposCache(equipoService);
  late final ApuestaService apuestaService = ApuestaService(_client);
  late final ColumnaService columnaService = ColumnaService(_client);
  late final MensajeService mensajeService = MensajeService(_client);
  late final UsuariosCache usuariosCache = UsuariosCache(usuarioService);

  EstadoSesion estado = EstadoSesion.cargando;
  Usuario? usuarioActual;

  Future<void> inicializar() async {
    final accessToken = await _client.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      estado = EstadoSesion.invitado;
      notifyListeners();
      return;
    }

    _client.token = accessToken;
    try {
      usuarioActual = await usuarioService.obtenerMiUsuario();
      estado = EstadoSesion.autenticado;
    } catch (_) {
      final refreshed = await _client.refreshSession();
      if (!refreshed) {
        await _borrarToken();
        estado = EstadoSesion.invitado;
      } else {
        try {
          usuarioActual = await usuarioService.obtenerMiUsuario();
          estado = EstadoSesion.autenticado;
        } catch (_) {
          await _borrarToken();
          estado = EstadoSesion.invitado;
        }
      }
    }
    notifyListeners();
  }

  Future<void> login(String nombreUsuario, String password) async {
    final tokens = await authService.login(nombreUsuario: nombreUsuario, password: password);
    await _client.saveSession(
      accessToken: tokens['access_token']!,
      refreshToken: tokens['refresh_token']!,
    );
    usuarioActual = await usuarioService.obtenerMiUsuario();
    estado = EstadoSesion.autenticado;
    notifyListeners();
  }

  Future<void> registro({
    required String nombreUsuario,
    required String email,
    required String password,
  }) async {
    await authService.registro(nombreUsuario: nombreUsuario, email: email, password: password);
    await login(nombreUsuario, password);
  }

  Future<void> logout() async {
    final refreshToken = await _client.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await authService.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // Se limpia la sesión local aunque el backend falle.
    }
    await _borrarToken();
    usuarioActual = null;
    estado = EstadoSesion.invitado;
    notifyListeners();
  }

  Future<void> _borrarToken() async {
    await _client.clearSession();
    _client.token = null;
  }

  Future<void> refrescarUsuario() async {
    usuarioActual = await usuarioService.obtenerMiUsuario();
    notifyListeners();
  }
}
