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

class Competicion {
  final int id;
  final String nombre;
  final String ambito;
  final bool esClubs;

  Competicion({required this.id, required this.nombre, required this.ambito, required this.esClubs});

  factory Competicion.fromJson(Map<String, dynamic> json) {
    return Competicion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      ambito: json['ambito'] as String,
      esClubs: json['es_clubes'] as bool,
    );
  }
}

class TemporadaCompeticion {
  final int id;
  final int temporadaId;
  final int competicionId;
  final Competicion? competicion;

  TemporadaCompeticion({
    required this.id,
    required this.temporadaId,
    required this.competicionId,
    this.competicion,
  });

  factory TemporadaCompeticion.fromJson(Map<String, dynamic> json) {
    return TemporadaCompeticion(
      id: json['id'] as int,
      temporadaId: json['temporada_id'] as int,
      competicionId: json['competicion_id'] as int,
      competicion: json['competicion'] != null ? Competicion.fromJson(json['competicion'] as Map<String, dynamic>) : null,
    );
  }
}

class Partido {
  final int id;
  final int jornadaId;
  final int orden;
  final String estado;
  final int? competicionTemporadaId;
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
    this.estado = 'pendiente',
    this.competicionTemporadaId,
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
      estado: json['estado'] as String? ?? 'pendiente',
      competicionTemporadaId: json['competicion_temporada_id'] as int?,
      fechaHora: json['fecha_hora'] != null ? DateTime.parse(json['fecha_hora'] as String).toLocal() : null,
      canal: json['canal'] as String?,
      equipoLocalId: json['equipo_local_id'] as int?,
      equipoVisitanteId: json['equipo_visitante_id'] as int?,
      golesLocal: json['goles_local'] as int?,
      golesVisitante: json['goles_visitante'] as int?,
    );
  }
}
