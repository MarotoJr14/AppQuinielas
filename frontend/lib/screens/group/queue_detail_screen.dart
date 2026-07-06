import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/apuesta.dart';
import '../../models/partido.dart';
import '../../models/pronostico.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../utils/apuesta_utils.dart';
import '../../widgets/common.dart';
import '../../widgets/pronostico_chip.dart';

class _EdicionColumna {
  final int? columnaIdExistente;
  final int usuarioId;
  final bool esElige8;
  final Map<int, Pronostico> pronosticos;

  _EdicionColumna({
    required this.columnaIdExistente,
    required this.usuarioId,
    required this.esElige8,
    required this.pronosticos,
  });
}

class _ColumnaPantalla {
  final int? id;
  final int usuarioId;
  final bool esElige8;
  final bool enEdicion;
  final Map<int, Pronostico> persistidos;
  final Map<int, Pronostico>? enEdicionMapa;

  _ColumnaPantalla({
    required this.id,
    required this.usuarioId,
    required this.esElige8,
    required this.enEdicion,
    required this.persistidos,
    this.enEdicionMapa,
  });

  Pronostico? pronosticoDe(int partidoId) {
    if (enEdicion) return enEdicionMapa?[partidoId];
    return persistidos[partidoId];
  }
}

class QueueDetailScreen extends StatefulWidget {
  final int apuestaId;
  const QueueDetailScreen({super.key, required this.apuestaId});

  @override
  State<QueueDetailScreen> createState() => _QueueDetailScreenState();
}

class _QueueDetailScreenState extends State<QueueDetailScreen> {
  ApuestaDetalle? _detalle;
  Jornada? _jornada;
  List<RankingFila> _ranking = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  final Map<int, String> _nombres = {};
  _EdicionColumna? _edicion;

  static const double _anchoColIzq = 220;
  static const double _anchoCol = 132;
  static const double _altoFila = 44;
  static const double _altoFilaP15 = 88;
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final detalle = await auth.apuestaService.obtenerDetalle(widget.apuestaId);
      final jornada = await auth.jornadaService.obtener(detalle.apuesta.jornadaId);
      await auth.equiposCache.asegurarCargado();

      final idsUsuarios = <int>{detalle.apuesta.usuarioElige8Id, ...detalle.columnas.map((c) => c.usuarioId)};
      await auth.usuariosCache.precargar(idsUsuarios);
      for (final id in idsUsuarios) {
        _nombres[id] = auth.usuariosCache.nombreCacheado(id);
      }

      List<RankingFila> ranking = [];
      if (detalle.apuesta.estado != EstadoApuesta.pendiente) {
        ranking = await auth.apuestaService.ranking(widget.apuestaId);
      }

      setState(() {
        _detalle = detalle;
        _jornada = jornada;
        _ranking = ranking;
        _edicion = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  bool get _editable => _detalle?.apuesta.estado == EstadoApuesta.pendiente;

  int? get _miId => context.read<AuthProvider>().usuarioActual?.id;

  bool get _soyAdmin => context.read<AuthProvider>().esAdmin;

  Columna? get _columnaNormalLider {
    if (_detalle == null) return null;
    final coincidencias = _detalle!.columnas.where(
      (c) => !c.esElige8 && c.usuarioId == _detalle!.apuesta.usuarioElige8Id,
    );
    return coincidencias.isNotEmpty ? coincidencias.first : null;
  }

  Columna? get _miColumnaNormal {
    if (_detalle == null || _miId == null) return null;
    final coincidencias = _detalle!.columnas.where((c) => !c.esElige8 && c.usuarioId == _miId);
    return coincidencias.isNotEmpty ? coincidencias.first : null;
  }

  bool get _existeColumnaElige8 {
    if (_detalle == null) return false;
    return _detalle!.columnas.any((c) => c.esElige8);
  }

  List<_ColumnaPantalla> _construirColumnas() {
    if (_detalle == null) return [];
    final apuesta = _detalle!.apuesta;
    Columna? elige8Real;
    Columna? normalLiderReal;
    final resto = <Columna>[];
    for (final c in _detalle!.columnas) {
      if (c.esElige8) {
        elige8Real = c;
      } else if (c.usuarioId == apuesta.usuarioElige8Id) {
        normalLiderReal = c;
      } else {
        resto.add(c);
      }
    }
    final ordenReal = <Columna>[
      if (elige8Real != null) elige8Real,
      if (normalLiderReal != null) normalLiderReal,
      ...resto,
    ];

    final resultado = <_ColumnaPantalla>[];
    for (final c in ordenReal) {
      final enEdicionEsta = _edicion != null && _edicion!.columnaIdExistente == c.id;
      resultado.add(_ColumnaPantalla(
        id: c.id,
        usuarioId: c.usuarioId,
        esElige8: c.esElige8,
        enEdicion: enEdicionEsta,
        persistidos: {for (final p in c.pronosticos) p.partidoId: p},
        enEdicionMapa: enEdicionEsta ? _edicion!.pronosticos : null,
      ));
    }

    if (_edicion != null && _edicion!.columnaIdExistente == null) {
      final virtual = _ColumnaPantalla(
        id: null,
        usuarioId: _edicion!.usuarioId,
        esElige8: _edicion!.esElige8,
        enEdicion: true,
        persistidos: const {},
        enEdicionMapa: _edicion!.pronosticos,
      );
      if (_edicion!.esElige8) {
        resultado.insert(0, virtual);
      } else if (_edicion!.usuarioId == apuesta.usuarioElige8Id) {
        final idx = resultado.indexWhere((c) => c.esElige8) + 1;
        resultado.insert(idx.clamp(0, resultado.length), virtual);
      } else {
        resultado.add(virtual);
      }
    }
    return resultado;
  }

  String _nombreColumna(_ColumnaPantalla c) {
    if (c.esElige8) return 'Elige 8';
    return _nombres[c.usuarioId] ?? 'Usuario #${c.usuarioId}';
  }

  void _iniciarRellenarMiColumna() {
    setState(() {
      _edicion = _EdicionColumna(columnaIdExistente: null, usuarioId: _miId!, esElige8: false, pronosticos: {});
    });
  }

  void _iniciarRellenarElige8() {
    setState(() {
      _edicion = _EdicionColumna(columnaIdExistente: null, usuarioId: _miId!, esElige8: true, pronosticos: {});
    });
  }

  void _iniciarEditar(_ColumnaPantalla c) {
    setState(() {
      _edicion = _EdicionColumna(
        columnaIdExistente: c.id,
        usuarioId: c.usuarioId,
        esElige8: c.esElige8,
        pronosticos: Map.of(c.persistidos),
      );
    });
  }

  Future<void> _nuevaColumnaAdmin() async {
    final auth = context.read<AuthProvider>();
    // Miembros sin columna normal todavía.
    final idsConColumna = _detalle!.columnas.where((c) => !c.esElige8).map((c) => c.usuarioId).toSet();
    // Reutilizamos la caché de nombres ya cargada; para elegir necesitamos ids de miembros:
    // se obtienen desde el listado de columnas existentes + el propio grupo no está aquí,
    // así que ofrecemos introducir directamente el id de usuario si no está en caché.
    final disponibles = _nombres.entries.where((e) => !idsConColumna.contains(e.key)).toList();

    final usuarioId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Rellenar columna de otro usuario'),
        children: [
          for (final e in disponibles)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, e.key),
              child: Text(e.value),
            ),
          if (disponibles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('Todos los miembros conocidos ya tienen columna.'),
            ),
        ],
      ),
    );
    if (usuarioId == null) return;
    unawaited(auth.usuariosCache.nombreDe(usuarioId));
    setState(() {
      _edicion = _EdicionColumna(columnaIdExistente: null, usuarioId: usuarioId, esElige8: false, pronosticos: {});
    });
  }

  void _cancelarEdicion() => setState(() => _edicion = null);

  Future<void> _guardarEdicion() async {
    if (_edicion == null) return;
    setState(() => _guardando = true);
    try {
      final auth = context.read<AuthProvider>();
      final pronosticos = _edicion!.pronosticos.values.toList();
      if (_edicion!.columnaIdExistente == null) {
        await auth.columnaService.rellenar(
          apuestaId: widget.apuestaId,
          usuarioId: _edicion!.usuarioId,
          esElige8: _edicion!.esElige8,
          pronosticos: pronosticos,
        );
      } else {
        await auth.columnaService.editar(columnaId: _edicion!.columnaIdExistente!, pronosticos: pronosticos);
      }
      await auth.apuestaService.recalcular(widget.apuestaId);
      if (mounted) mostrarExitoSnackbar(context, 'Columna guardada correctamente.');
      await _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _cerrarQuiniela() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar quiniela'),
        content: const Text(
          'Esta acción es irreversible: a partir de ahora no se podrán añadir ni editar columnas. ¿Continuar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar quiniela')),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await context.read<AuthProvider>().apuestaService.cerrar(widget.apuestaId);
      if (mounted) mostrarExitoSnackbar(context, 'Quiniela cerrada.');
      await _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  void _cambiarSigno(_ColumnaPantalla col, Partido partido, Signo signo) {
    if (_edicion == null) return;
    setState(() {
      _edicion!.pronosticos[partido.id] = Pronostico(partidoId: partido.id, signo: signo);
    });
  }

  void _toggleElige8(_ColumnaPantalla col, Partido partido) {
    if (_edicion == null) return;
    final miColumnaNormal = _detalle!.columnas.where((c) => !c.esElige8 && c.usuarioId == _edicion!.usuarioId);
    if (miColumnaNormal.isEmpty) return;
    final pronosticoNormal = miColumnaNormal.first.pronosticoDe(partido.id);
    if (pronosticoNormal?.signo == null) return;

    setState(() {
      if (_edicion!.pronosticos.containsKey(partido.id)) {
        _edicion!.pronosticos.remove(partido.id);
      } else {
        final incluidos = _edicion!.pronosticos.values.where((p) => p.signo != null).length;
        if (incluidos >= 8) {
          mostrarErrorSnackbar(context, 'La columna Elige 8 admite como máximo 8 pronósticos 1X2.');
          return;
        }
        _edicion!.pronosticos[partido.id] = Pronostico(partidoId: partido.id, signo: pronosticoNormal!.signo);
      }
    });
  }

  void _cambiarGolesElige8(Partido partido, {required bool esLocal, required Goles valor}) {
    if (_edicion == null) return;
    setState(() {
      final actual = _edicion!.pronosticos[partido.id];
      _edicion!.pronosticos[partido.id] = Pronostico(
        partidoId: partido.id,
        pleno15Local: esLocal ? valor : actual?.pleno15Local,
        pleno15Visitante: !esLocal ? valor : actual?.pleno15Visitante,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_jornada?.nombre ?? 'Quiniela')),
      body: SafeArea(
        child: _cargando
            ? const CargandoWidget()
            : _error != null
                ? Padding(padding: const EdgeInsets.all(16), child: ErrorBanner(mensaje: _error!, onReintentar: _cargar))
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _cabecera(),
                        const SizedBox(height: 16),
                        _barraAcciones(),
                        const SizedBox(height: 12),
                        _tablaPartidos(),
                        if (_ranking.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _seccionRanking(),
                        ],
                        if (partidosCompletados(_detalle!.partidos)) ...[
                          const SizedBox(height: 28),
                          _seccionPremios(),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _cabecera() {
    final apuesta = _detalle!.apuesta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_jornada?.nombre ?? '', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            if (_jornada != null)
              Text('Cierre: ${_fmt.format(_jornada!.fechaCierre)}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _dato('Estado', apuesta.estado == EstadoApuesta.pendiente ? 'Pendiente' : (partidosCompletados(_detalle!.partidos) ? 'Finalizada' : 'En curso')),
                _dato('Precio', apuesta.precio != null ? '${apuesta.precio!.toStringAsFixed(2)} €' : '-'),
                _dato('Beneficio', apuesta.beneficio != null ? '${apuesta.beneficio!.toStringAsFixed(2)} €' : '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
        Text(valor, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _barraAcciones() {
    if (_edicion != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _guardando ? null : _cancelarEdicion,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardarEdicion,
              child: _guardando
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar columna'),
            ),
          ),
        ],
      );
    }

    if (!_editable) return const SizedBox.shrink();

    final botones = <Widget>[];
    if (_miColumnaNormal == null && _miId != null) {
      botones.add(OutlinedButton.icon(
        onPressed: _iniciarRellenarMiColumna,
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text('Rellenar mi columna'),
      ));
    }
    if (_miId == _detalle!.apuesta.usuarioElige8Id && !_existeColumnaElige8) {
      botones.add(OutlinedButton.icon(
        onPressed: _miColumnaNormal != null ? _iniciarRellenarElige8 : null,
        icon: const Icon(Icons.star_border),
        label: const Text('Rellenar Elige 8'),
      ));
    }
    if (_soyAdmin) {
      botones.add(OutlinedButton.icon(
        onPressed: _nuevaColumnaAdmin,
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Nueva columna'),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 12, runSpacing: 8, children: botones),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _cerrarQuiniela,
            icon: const Icon(Icons.lock_outline, color: AppColors.errores),
            label: const Text('Cerrar quiniela', style: TextStyle(color: AppColors.errores)),
          ),
        ),
      ],
    );
  }

  Widget _tablaPartidos() {
    final columnas = _construirColumnas();
    final auth = context.read<AuthProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: _anchoColIzq, child: Padding(padding: EdgeInsets.all(6), child: Text('Partido'))),
              for (final col in columnas)
                SizedBox(
                  width: _anchoCol,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _nombreColumna(col),
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_editable && _edicion == null && col.id != null && (col.usuarioId == _miId || _soyAdmin))
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              final real = _detalle!.columnas.firstWhere((c) => c.id == col.id);
                              _iniciarEditar(_ColumnaPantalla(
                                id: real.id,
                                usuarioId: real.usuarioId,
                                esElige8: real.esElige8,
                                enEdicion: false,
                                persistidos: {for (final p in real.pronosticos) p.partidoId: p},
                              ));
                            },
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          for (final partido in _detalle!.partidos) _filaPartido(partido, columnas, auth),
        ],
      ),
    );
  }

  Widget _filaPartido(Partido partido, List<_ColumnaPantalla> columnas, AuthProvider auth) {
    final altura = partido.esPlenoAl15 ? _altoFilaP15 : _altoFila;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _anchoColIzq,
            height: altura,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Text('${partido.orden}', style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(
                    child: Text(
                      '${auth.equiposCache.nombreDe(partido.equipoLocalId)} - ${auth.equiposCache.nombreDe(partido.equipoVisitanteId)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (partido.tieneResultado)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${partido.golesLocal}-${partido.golesVisitante}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final col in columnas)
            SizedBox(
              width: _anchoCol,
              height: altura,
              child: Center(child: _celda(col, partido)),
            ),
        ],
      ),
    );
  }

  Widget _celda(_ColumnaPantalla col, Partido partido) {
    final pronostico = col.pronosticoDe(partido.id);

    if (col.esElige8) {
      if (partido.esPlenoAl15) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectorGoles(
              valor: pronostico?.pleno15Local,
              acertado: pronostico?.acertado,
              onChanged: col.enEdicion ? (g) => _cambiarGolesElige8(partido, esLocal: true, valor: g) : null,
            ),
            const SizedBox(height: 4),
            SelectorGoles(
              valor: pronostico?.pleno15Visitante,
              acertado: pronostico?.acertado,
              onChanged: col.enEdicion ? (g) => _cambiarGolesElige8(partido, esLocal: false, valor: g) : null,
            ),
          ],
        );
      }
      // Fila normal (1-14) de la columna Elige 8: chip único, copiado de la columna normal.
      if (pronostico?.signo == null) {
        return col.enEdicion
            ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(40, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                onPressed: () => _toggleElige8(col, partido),
                child: const Text('+', style: TextStyle(fontSize: 12)),
              )
            : Text('—', style: Theme.of(context).textTheme.bodySmall);
      }
      return ChipPronostico(
        texto: pronostico!.signo!.valorApi,
        seleccionado: true,
        acertado: pronostico.acertado,
        onTap: col.enEdicion ? () => _toggleElige8(col, partido) : null,
      );
    }

    // Columna normal (incluye fila 15 con 1X2 normal).
    return SelectorSigno(
      valor: pronostico?.signo,
      acertado: pronostico?.acertado,
      onChanged: col.enEdicion ? (s) => _cambiarSigno(col, partido, s) : null,
    );
  }

  Widget _seccionRanking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Clasificación de aciertos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final fila in _ranking)
                Container(
                  decoration: BoxDecoration(
                    color: fila.enRacha ? AppColors.aciertos.withValues(alpha: 0.12) : null,
                    border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: ListTile(
                    leading: fila.esElige8 ? const Icon(Icons.star, color: AppColors.acento) : null,
                    title: Text(fila.esElige8 ? 'Elige 8 (${fila.nombreUsuario})' : fila.nombreUsuario),
                    subtitle: Text('${fila.aciertos} aciertos · ${fila.fallos} fallos · ${fila.pendientes} pendientes'),
                    trailing: Text('${fila.aciertos}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seccionPremios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Premios de la jornada', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final premio in _detalle!.premios)
                ListTile(
                  title: Text(premio.categoria.etiqueta),
                  trailing: Text(
                    premio.valor != null ? '${premio.valor!.toStringAsFixed(2)} €' : '-',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              if (_detalle!.premios.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay premios registrados para esta jornada.'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

void unawaited(Future<void> future) {}
