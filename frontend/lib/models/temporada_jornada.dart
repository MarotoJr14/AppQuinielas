class Temporada {
  final int id;
  final String nombre;

  Temporada({required this.id, required this.nombre});

  factory Temporada.fromJson(Map<String, dynamic> json) {
    return Temporada(id: json['id'] as int, nombre: json['nombre'] as String);
  }
}

class Jornada {
  final int id;
  final int temporadaId;
  final String nombre;
  final DateTime fechaCierre;

  Jornada({
    required this.id,
    required this.temporadaId,
    required this.nombre,
    required this.fechaCierre,
  });

  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      id: json['id'] as int,
      temporadaId: json['temporada_id'] as int,
      nombre: json['nombre'] as String,
      fechaCierre: DateTime.parse(json['fecha_cierre'] as String).toLocal(),
    );
  }
}

/// Categorías de premio, tal y como se definen en el backend (database.md).
enum CategoriaPremio {
  aciertos15('15 aciertos', 'Pleno (15 aciertos)'),
  aciertos14('14 aciertos', '14 aciertos'),
  aciertos13('13 aciertos', '13 aciertos'),
  aciertos12('12 aciertos', '12 aciertos'),
  aciertos11('11 aciertos', '11 aciertos'),
  aciertos10('10 aciertos', '10 aciertos'),
  elige8('elige 8', 'Elige 8');

  final String valorApi;
  final String etiqueta;

  const CategoriaPremio(this.valorApi, this.etiqueta);

  static CategoriaPremio fromApi(String valor) {
    return CategoriaPremio.values.firstWhere(
      (c) => c.valorApi == valor,
      orElse: () => CategoriaPremio.elige8,
    );
  }
}

class PremioJornada {
  final int id;
  final int jornadaId;
  final CategoriaPremio categoria;
  final double? valor;

  PremioJornada({
    required this.id,
    required this.jornadaId,
    required this.categoria,
    required this.valor,
  });

  factory PremioJornada.fromJson(Map<String, dynamic> json) {
    return PremioJornada(
      id: json['id'] as int,
      jornadaId: json['jornada_id'] as int,
      categoria: CategoriaPremio.fromApi(json['categoria'] as String),
      valor: (json['valor'] as num?)?.toDouble(),
    );
  }
}
