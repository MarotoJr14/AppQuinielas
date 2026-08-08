class Grupo {
  final int id;
  final String nombre;

  Grupo({required this.id, required this.nombre});

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(id: json['id'] as int, nombre: json['nombre'] as String);
  }
}

class UsuarioGrupo {
  final int id;
  final int grupoId;
  final int usuarioId;
  final bool esLider;

  UsuarioGrupo({
    required this.id,
    required this.grupoId,
    required this.usuarioId,
    required this.esLider,
  });

  factory UsuarioGrupo.fromJson(Map<String, dynamic> json) {
    return UsuarioGrupo(
      id: json['id'] as int,
      grupoId: json['grupo_id'] as int,
      usuarioId: json['usuario_id'] as int,
      esLider: json['es_lider'] as bool,
    );
  }
}
