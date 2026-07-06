import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
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

  bool get esAdmin => usuarioActual?.id == AppConstants.adminUsuarioId;

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.prefsTokenKey);
    if (token == null) {
      estado = EstadoSesion.invitado;
      notifyListeners();
      return;
    }
    _client.token = token;
    try {
      usuarioActual = await usuarioService.obtenerMiUsuario();
      estado = EstadoSesion.autenticado;
    } catch (_) {
      await _borrarToken();
      estado = EstadoSesion.invitado;
    }
    notifyListeners();
  }

  Future<void> login(String nombreUsuario, String password) async {
    final token = await authService.login(nombreUsuario: nombreUsuario, password: password);
    _client.token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsTokenKey, token);
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
    await _borrarToken();
    usuarioActual = null;
    estado = EstadoSesion.invitado;
    notifyListeners();
  }

  Future<void> _borrarToken() async {
    _client.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefsTokenKey);
  }

  Future<void> refrescarUsuario() async {
    usuarioActual = await usuarioService.obtenerMiUsuario();
    notifyListeners();
  }
}
