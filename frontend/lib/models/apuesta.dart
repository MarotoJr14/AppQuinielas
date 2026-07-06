import 'pronostico.dart';
import 'partido.dart';
import 'temporada_jornada.dart';

class Columna {
  final int id;
  final int apuestaId;
  final int usuarioId;
  final bool esElige8;
  final List<Pronostico> pronosticos;
  final int? aciertos;
  final int? fallos;
  final String? nombreUsuario;

  Columna({
    required this.id,
    required this.apuestaId,
    required this.usuarioId,
    required this.esElige8,
    this.pronosticos = const [],
    this.aciertos,
    this.fallos,
    this.nombreUsuario,
  });

  factory Columna.fromJson(Map<String, dynamic> json) {
    return Columna(
      id: json['id'] as int,
      apuestaId: json['apuesta_id'] as int,
      usuarioId: json['usuario_id'] as int,
      esElige8: json['es_elige8'] as bool,
      pronosticos: (json['pronosticos'] as List<dynamic>? ?? [])
          .map((p) => Pronostico.fromJson(p as Map<String, dynamic>))
          .toList(),
      aciertos: json['aciertos'] as int?,
      fallos: json['fallos'] as int?,
    );
  }

  Pronostico? pronosticoDe(int partidoId) {
    for (final p in pronosticos) {
      if (p.partidoId == partidoId) return p;
    }
    return null;
  }
}

enum EstadoApuesta {
  pendiente,
  cerrada,
  enCurso,
  finalizada;

  String get valorApi {
    switch (this) {
      case EstadoApuesta.pendiente:
        return 'pendiente';
      case EstadoApuesta.cerrada:
        return 'cerrada';
      case EstadoApuesta.enCurso:
        return 'en_curso';
      case EstadoApuesta.finalizada:
        return 'finalizada';
    }
  }

  String get etiqueta {
    switch (this) {
      case EstadoApuesta.pendiente:
        return 'Pendiente';
      case EstadoApuesta.cerrada:
        return 'Cerrada';
      case EstadoApuesta.enCurso:
        return 'En curso';
      case EstadoApuesta.finalizada:
        return 'Finalizada';
    }
  }

  static EstadoApuesta fromApi(String valor) {
    return EstadoApuesta.values.firstWhere(
      (e) => e.valorApi == valor,
      orElse: () => EstadoApuesta.pendiente,
    );
  }
}

class Apuesta {
  final int id;
  final int jornadaId;
  final int grupoId;
  final int usuarioElige8Id;
  final EstadoApuesta estado;
  final double? precio;
  final double? beneficio;

  // Campos opcionales enriquecidos localmente (no siempre presentes).
  final Jornada? jornada;

  Apuesta({
    required this.id,
    required this.jornadaId,
    required this.grupoId,
    required this.usuarioElige8Id,
    required this.estado,
    this.precio,
    this.beneficio,
    this.jornada,
  });

  factory Apuesta.fromJson(Map<String, dynamic> json) {
    return Apuesta(
      id: json['id'] as int,
      jornadaId: json['jornada_id'] as int,
      grupoId: json['grupo_id'] as int,
      usuarioElige8Id: json['usuario_elige8_id'] as int,
      estado: EstadoApuesta.fromApi(json['estado'] as String),
      precio: (json['precio'] as num?)?.toDouble(),
      beneficio: (json['beneficio'] as num?)?.toDouble(),
    );
  }
}

class ApuestaDetalle {
  final Apuesta apuesta;
  final List<Partido> partidos;
  final List<Columna> columnas;
  final List<PremioJornada> premios;

  ApuestaDetalle({
    required this.apuesta,
    required this.partidos,
    required this.columnas,
    required this.premios,
  });

  factory ApuestaDetalle.fromJson(Map<String, dynamic> json) {
    return ApuestaDetalle(
      apuesta: Apuesta.fromJson(json),
      partidos: (json['partidos'] as List<dynamic>? ?? [])
          .map((p) => Partido.fromJson(p as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orden.compareTo(b.orden)),
      columnas: (json['columnas'] as List<dynamic>? ?? [])
          .map((c) => Columna.fromJson(c as Map<String, dynamic>))
          .toList(),
      premios: (json['premios'] as List<dynamic>? ?? [])
          .map((p) => PremioJornada.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RankingFila {
  final int columnaId;
  final int usuarioId;
  final String nombreUsuario;
  final bool esElige8;
  final int aciertos;
  final int fallos;
  final int pendientes;
  final bool enRacha;

  RankingFila({
    required this.columnaId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.esElige8,
    required this.aciertos,
    required this.fallos,
    required this.pendientes,
    required this.enRacha,
  });

  factory RankingFila.fromJson(Map<String, dynamic> json) {
    return RankingFila(
      columnaId: json['columna_id'] as int,
      usuarioId: json['usuario_id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      esElige8: json['es_elige8'] as bool,
      aciertos: json['aciertos'] as int,
      fallos: json['fallos'] as int,
      pendientes: json['pendientes'] as int,
      enRacha: json['en_racha'] as bool,
    );
  }
}
