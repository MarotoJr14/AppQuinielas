/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  /// URL base de la API backend. Ajustar según el entorno de despliegue.
  /// - Emulador Android: usar 10.0.2.2 en lugar de localhost.
  /// - Dispositivo físico / web: usar la IP o dominio real del backend.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// El usuario con id=1 es el administrador del sistema (ver backend).
  static const int adminUsuarioId = 1;

  static const String prefsTokenKey = 'auth_token';
  static const String prefsThemeKey = 'theme_mode';
}
