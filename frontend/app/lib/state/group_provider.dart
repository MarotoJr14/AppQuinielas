import 'package:flutter/material.dart';
import '../models/grupo.dart';
import 'auth_provider.dart';

/// Mantiene el contexto del grupo (peña) en el que el usuario está
/// trabajando actualmente. Todas las pantallas "dentro" de un grupo
/// (dashboard, quinielas, chat, etc.) consultan este provider para saber
/// en qué grupo están y si el usuario es líder del mismo.
class GroupProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  GroupProvider(this.authProvider);

  Grupo? grupoActual;
  bool esLider = false;
  List<UsuarioGrupo> miembros = [];
  bool cargando = false;

  Future<void> entrarEnGrupo(Grupo grupo) async {
    grupoActual = grupo;
    cargando = true;
    notifyListeners();
    try {
      miembros = await authProvider.grupoService.listarMiembros(grupo.id);
      final miRelacion = miembros.where((m) => m.usuarioId == authProvider.usuarioActual?.id);
      esLider = miRelacion.isNotEmpty && miRelacion.first.esLider;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> recargarMiembros() async {
    if (grupoActual == null) return;
    miembros = await authProvider.grupoService.listarMiembros(grupoActual!.id);
    final miRelacion = miembros.where((m) => m.usuarioId == authProvider.usuarioActual?.id);
    esLider = miRelacion.isNotEmpty && miRelacion.first.esLider;
    notifyListeners();
  }

  void actualizarGrupo(Grupo grupo) {
    grupoActual = grupo;
    notifyListeners();
  }

  String nombreDeUsuario(int usuarioId) {
    // Se completa de forma perezosa desde las pantallas que ya cargan la
    // lista de usuarios (ver UsuarioNombreCache). Aquí solo se expone el id
    // por si no hay caché disponible.
    return 'Usuario #$usuarioId';
  }

  void salir() {
    grupoActual = null;
    esLider = false;
    miembros = [];
    notifyListeners();
  }
}
