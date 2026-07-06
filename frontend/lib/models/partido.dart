class Equipo {
  final int id;
  final String nombre;
  final bool esClub;
  final String pais;

  Equipo({required this.id, required this.nombre, required this.esClub, required this.pais});

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      esClub: json['es_club'] as bool,
      pais: json['pais'] as String,
    );
  }
}

class Partido {
  final int id;
  final int jornadaId;
  final int orden;
  final DateTime? fechaHora;
  final String? canal;
  final int? equipoLocalId;
  final int? equipoVisitanteId;
  final int? golesLocal;
  final int? golesVisitante;

  Partido({
    required this.id,
    required this.jornadaId,
    required this.orden,
    this.fechaHora,
    this.canal,
    this.equipoLocalId,
    this.equipoVisitanteId,
    this.golesLocal,
    this.golesVisitante,
  });

  bool get esPlenoAl15 => orden == 15;

  bool get tieneResultado => golesLocal != null && golesVisitante != null;

  factory Partido.fromJson(Map<String, dynamic> json) {
    return Partido(
      id: json['id'] as int,
      jornadaId: json['jornada_id'] as int,
      orden: json['orden'] as int,
      fechaHora: json['fecha_hora'] != null ? DateTime.parse(json['fecha_hora'] as String).toLocal() : null,
      canal: json['canal'] as String?,
      equipoLocalId: json['equipo_local_id'] as int?,
      equipoVisitanteId: json['equipo_visitante_id'] as int?,
      golesLocal: json['goles_local'] as int?,
      golesVisitante: json['goles_visitante'] as int?,
    );
  }
}
