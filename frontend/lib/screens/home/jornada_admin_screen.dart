import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/partido.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../widgets/common.dart';

class JornadaAdminScreen extends StatefulWidget {
  final Jornada jornada;
  const JornadaAdminScreen({super.key, required this.jornada});

  @override
  State<JornadaAdminScreen> createState() => _JornadaAdminScreenState();
}

class _JornadaAdminScreenState extends State<JornadaAdminScreen> {
  List<Partido> _partidos = [];
  List<PremioJornada> _premios = [];
  List<Equipo> _equipos = [];
  bool _cargando = true;
  final _fmtHora = DateFormat('dd/MM HH:mm');

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final auth = context.read<AuthProvider>();
      final partidos = await auth.partidoService.listarPorJornada(widget.jornada.id);
      final premios = await auth.jornadaService.listarPremios(widget.jornada.id);
      final equipos = await auth.equipoService.listar();
      setState(() {
        _partidos = partidos;
        _premios = premios;
        _equipos = equipos;
      });
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _nombreEquipo(int? id) {
    if (id == null) return 'Por confirmar';
    final coincidencias = _equipos.where((e) => e.id == id);
    return coincidencias.isNotEmpty ? coincidencias.first.nombre : 'Equipo #$id';
  }

  Future<void> _generar15Partidos() async {
    setState(() => _cargando = true);
    try {
      final auth = context.read<AuthProvider>();
      for (int orden = 1; orden <= 15; orden++) {
        await auth.partidoService.crear(jornadaId: widget.jornada.id, orden: orden);
      }
      await _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
      setState(() => _cargando = false);
    }
  }

  Future<int?> _seleccionarOcrearEquipo() async {
    final buscarCtrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final filtrados = _equipos
              .where((e) => e.nombre.toLowerCase().contains(buscarCtrl.text.toLowerCase()))
              .toList();
          return AlertDialog(
            title: const Text('Seleccionar equipo'),
            content: SizedBox(
              width: 360,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    controller: buscarCtrl,
                    decoration: const InputDecoration(labelText: 'Buscar o crear equipo', prefixIcon: Icon(Icons.search)),
                    onChanged: (_) => setStateDialog(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final e in filtrados)
                          ListTile(
                            title: Text(e.nombre),
                            subtitle: Text(e.pais),
                            onTap: () => Navigator.pop(context, e.id),
                          ),
                        if (buscarCtrl.text.trim().length > 1)
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: Text('Crear "${buscarCtrl.text.trim()}"'),
                            onTap: () async {
                              try {
                                final nuevo = await context.read<AuthProvider>().equipoService.crear(
                                      nombre: buscarCtrl.text.trim(),
                                      esClub: true,
                                      pais: 'España',
                                    );
                                _equipos.add(nuevo);
                                if (context.mounted) Navigator.pop(context, nuevo.id);
                              } catch (e) {
                                if (context.mounted) mostrarErrorSnackbar(context, e);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ],
          );
        });
      },
    );
  }

  Future<void> _editarPartido(Partido partido) async {
    int? localId = partido.equipoLocalId;
    int? visitanteId = partido.equipoVisitanteId;
    DateTime? fechaHora = partido.fechaHora;
    final canalCtrl = TextEditingController(text: partido.canal ?? '');

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Partido ${partido.orden}${partido.esPlenoAl15 ? ' (Pleno al 15)' : ''}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_nombreEquipo(localId)),
                    subtitle: const Text('Equipo local'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () async {
                      final id = await _seleccionarOcrearEquipo();
                      if (id != null) setStateDialog(() => localId = id);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_nombreEquipo(visitanteId)),
                    subtitle: const Text('Equipo visitante'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () async {
                      final id = await _seleccionarOcrearEquipo();
                      if (id != null) setStateDialog(() => visitanteId = id);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(fechaHora != null ? _fmtHora.format(fechaHora!) : 'Sin fecha'),
                    subtitle: const Text('Fecha y hora'),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaHora ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (fecha == null) return;
                      if (!context.mounted) return;
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(fechaHora ?? DateTime.now()),
                      );
                      if (hora == null) return;
                      setStateDialog(() {
                        fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: canalCtrl,
                    decoration: const InputDecoration(labelText: 'Canal (opcional)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
            ],
          );
        });
      },
    );

    if (guardar != true) return;
    try {
      await context.read<AuthProvider>().partidoService.actualizar(
            partido.id,
            equipoLocalId: localId,
            equipoVisitanteId: visitanteId,
            fechaHora: fechaHora,
            canal: canalCtrl.text.trim().isEmpty ? null : canalCtrl.text.trim(),
          );
      await _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  Future<void> _registrarResultado(Partido partido) async {
    final localCtrl = TextEditingController(text: partido.golesLocal?.toString() ?? '');
    final visitanteCtrl = TextEditingController(text: partido.golesVisitante?.toString() ?? '');

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado — Partido ${partido.orden}'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                controller: localCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Goles local'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: visitanteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Goles visitante'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (guardar != true) return;
    final gl = int.tryParse(localCtrl.text);
    final gv = int.tryParse(visitanteCtrl.text);
    if (gl == null || gv == null) {
      if (mounted) mostrarErrorSnackbar(context, 'Introduce resultados numéricos válidos.');
      return;
    }
    try {
      await context.read<AuthProvider>().partidoService.registrarResultado(partido.id, golesLocal: gl, golesVisitante: gv);
      await _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  Future<void> _gestionarPremios() async {
    final valores = {for (final p in _premios) p.categoria: p.valor};

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Premios de la jornada'),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final categoria in CategoriaPremio.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                          initialValue: valores[categoria]?.toString() ?? '',
                          decoration: InputDecoration(labelText: categoria.etiqueta, suffixText: '€'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) => valores[categoria] = double.tryParse(v.replaceAll(',', '.')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final auth = context.read<AuthProvider>();
                    for (final categoria in CategoriaPremio.values) {
                      final valor = valores[categoria];
                      final existente = _premios.where((p) => p.categoria == categoria);
                      if (existente.isNotEmpty) {
                        await auth.jornadaService.actualizarPremio(existente.first.id, valor);
                      } else if (valor != null) {
                        await auth.jornadaService.crearPremio(jornadaId: widget.jornada.id, categoria: categoria, valor: valor);
                      }
                    }
                    await _cargar();
                  } catch (e) {
                    if (mounted) mostrarErrorSnackbar(context, e);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.jornada.nombre)),
      body: SafeArea(
        child: _cargando
            ? const CargandoWidget()
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _gestionarPremios,
                            icon: const Icon(Icons.emoji_events_outlined),
                            label: const Text('Premios'),
                          ),
                        ),
                        if (_partidos.isEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generar15Partidos,
                              icon: const Icon(Icons.add),
                              label: const Text('Crear 15 partidos'),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_partidos.isEmpty)
                      const EstadoVacio(
                        icono: Icons.sports_soccer_outlined,
                        titulo: 'Esta jornada todavía no tiene partidos',
                      )
                    else
                      for (final partido in _partidos)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: partido.esPlenoAl15 ? Colors.amber.shade100 : null,
                              child: Text('${partido.orden}'),
                            ),
                            title: Text('${_nombreEquipo(partido.equipoLocalId)} — ${_nombreEquipo(partido.equipoVisitanteId)}'),
                            subtitle: Text(
                              partido.tieneResultado
                                  ? 'Resultado: ${partido.golesLocal} - ${partido.golesVisitante}'
                                  : (partido.fechaHora != null ? _fmtHora.format(partido.fechaHora!) : 'Sin fecha'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar partido',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editarPartido(partido),
                                ),
                                IconButton(
                                  tooltip: 'Registrar resultado',
                                  icon: const Icon(Icons.scoreboard_outlined),
                                  onPressed: () => _registrarResultado(partido),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
      ),
    );
  }
}
