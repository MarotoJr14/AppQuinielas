import '../models/usuario.dart';
import 'usuario_service.dart';

/// Caché en memoria de usuarios por id, para poder mostrar nombres de
/// usuario (por ejemplo, en la lista de miembros de un grupo o en las
/// columnas de una quiniela) sin repetir peticiones a la API.
class UsuariosCache {
  UsuariosCache(this._service);
  final UsuarioService _service;
  final Map<int, Usuario> _porId = {};

  Future<String> nombreDe(int usuarioId) async {
    if (_porId.containsKey(usuarioId)) {
      return _porId[usuarioId]!.nombreUsuario;
    }
    try {
      final usuario = await _service.obtenerUsuario(usuarioId);
      _porId[usuarioId] = usuario;
      return usuario.nombreUsuario;
    } catch (_) {
      return 'Usuario #$usuarioId';
    }
  }

  String nombreCacheado(int usuarioId) {
    return _porId[usuarioId]?.nombreUsuario ?? 'Usuario #$usuarioId';
  }

  Future<void> precargar(Iterable<int> ids) async {
    for (final id in ids.toSet()) {
      if (!_porId.containsKey(id)) {
        await nombreDe(id);
      }
    }
  }
}
