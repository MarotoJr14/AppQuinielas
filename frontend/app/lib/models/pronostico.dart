/// Pronóstico 1X2 para un partido normal.
enum Signo {
  uno('1'),
  x('X'),
  dos('2');

  final String valorApi;
  const Signo(this.valorApi);

  static Signo? fromApi(String? valor) {
    if (valor == null) return null;
    return Signo.values.firstWhere((s) => s.valorApi == valor);
  }
}

/// Pronóstico de goles del Pleno al 15 (0, 1, 2 o M = 3 o más).
enum Goles {
  cero('0'),
  uno('1'),
  dos('2'),
  m('M');

  final String valorApi;
  const Goles(this.valorApi);

  static Goles? fromApi(String? valor) {
    if (valor == null) return null;
    return Goles.values.firstWhere((g) => g.valorApi == valor);
  }
}

class Pronostico {
  final int? id;
  final int partidoId;
  final Signo? signo;
  final Goles? pleno15Local;
  final Goles? pleno15Visitante;
  final bool? acertado;

  Pronostico({
    this.id,
    required this.partidoId,
    this.signo,
    this.pleno15Local,
    this.pleno15Visitante,
    this.acertado,
  });

  Pronostico copyWith({Signo? signo, Goles? pleno15Local, Goles? pleno15Visitante}) {
    return Pronostico(
      id: id,
      partidoId: partidoId,
      signo: signo ?? this.signo,
      pleno15Local: pleno15Local ?? this.pleno15Local,
      pleno15Visitante: pleno15Visitante ?? this.pleno15Visitante,
      acertado: acertado,
    );
  }

  factory Pronostico.fromJson(Map<String, dynamic> json) {
    return Pronostico(
      id: json['id'] as int?,
      partidoId: json['partido_id'] as int,
      signo: Signo.fromApi(json['signo'] as String?),
      pleno15Local: Goles.fromApi(json['pleno15_local'] as String?),
      pleno15Visitante: Goles.fromApi(json['pleno15_visitante'] as String?),
      acertado: json['acertado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partido_id': partidoId,
      'signo': signo?.valorApi,
      'pleno15_local': pleno15Local?.valorApi,
      'pleno15_visitante': pleno15Visitante?.valorApi,
    };
  }
}
