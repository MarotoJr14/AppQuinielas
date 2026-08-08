class Usuario {
  final int id;
  final String nombreUsuario;
  final String email;

  Usuario({required this.id, required this.nombreUsuario, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      email: json['email'] as String,
    );
  }

  String get inicial => nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : '?';
}
