import 'api_client.dart';
import '../models/partido.dart';

class EquipoService {
  final ApiClient client;
  EquipoService(this.client);

  Future<List<Equipo>> listar({int skip = 0, int limit = 500}) async {
    final data = await client.get('/equipos', query: {'skip': skip, 'limit': limit});
    return (data as List<dynamic>).map((e) => Equipo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Equipo> crear({required String nombre, required bool esClub, required String pais}) async {
    final data = await client.post('/equipos', body: {'nombre': nombre, 'es_club': esClub, 'pais': pais});
    return Equipo.fromJson(data as Map<String, dynamic>);
  }
}

/// Caché simple en memoria de equipos (id -> nombre), para no repetir
/// llamadas a la API al pintar cada fila de partido en las tablas de quiniela.
class EquiposCache {
  EquiposCache(this._service);
  final EquipoService _service;
  final Map<int, Equipo> _porId = {};
  bool _cargado = false;

  Future<void> asegurarCargado() async {
    if (_cargado) return;
    final equipos = await _service.listar();
    for (final e in equipos) {
      _porId[e.id] = e;
    }
    _cargado = true;
  }

  String nombreDe(int? id) {
    if (id == null) return 'Por confirmar';
    return _porId[id]?.nombre ?? 'Equipo #$id';
  }
}
