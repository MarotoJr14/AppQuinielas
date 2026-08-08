class Mensaje {
  final int id;
  final int grupoId;
  final int usuarioId;
  final DateTime enviadoEn;
  final String contenido;
  final String? nombreUsuario;

  Mensaje({
    required this.id,
    required this.grupoId,
    required this.usuarioId,
    required this.enviadoEn,
    required this.contenido,
    this.nombreUsuario,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as int,
      grupoId: json['grupo_id'] as int,
      usuarioId: json['usuario_id'] as int,
      enviadoEn: DateTime.parse(json['enviado_en'] as String).toLocal(),
      contenido: json['contenido'] as String,
    );
  }
}
