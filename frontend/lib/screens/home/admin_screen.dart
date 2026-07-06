import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../widgets/common.dart';
import 'jornada_admin_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Temporada> _temporadas = [];
  List<Jornada> _jornadas = [];
  bool _cargando = true;
  String? _error;

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
      final temporadas = await auth.jornadaService.listarTemporadas();
      final jornadas = await auth.jornadaService.listarTodas();
      jornadas.sort((a, b) => b.fechaCierre.compareTo(a.fechaCierre));
      setState(() {
        _temporadas = temporadas;
        _jornadas = jornadas;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _crearTemporada() async {
    final ctrl = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva temporada'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nombre (ej. 2025-2026)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (nombre == null || nombre.isEmpty) return;
    try {
      await context.read<AuthProvider>().jornadaService.crearTemporada(nombre);
      _cargar();
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  Future<void> _crearJornada() async {
    if (_temporadas.isEmpty) {
      mostrarErrorSnackbar(context, 'Crea antes una temporada.');
      return;
    }
    Temporada temporadaSeleccionada = _temporadas.first;
    final nombreCtrl = TextEditingController();
    DateTime fechaCierre = DateTime.now().add(const Duration(days: 3));

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nueva jornada'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Temporada>(
                      initialValue: temporadaSeleccionada,
                      decoration: const InputDecoration(labelText: 'Temporada'),
                      items: _temporadas
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.nombre)))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => temporadaSeleccionada = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre de la jornada (ej. J1)'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha y hora de cierre'),
                      subtitle: Text(_fmt.format(fechaCierre)),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: fechaCierre,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (fecha == null) return;
                        if (!context.mounted) return;
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(fechaCierre),
                        );
                        if (hora == null) return;
                        setStateDialog(() {
                          fechaCierre = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear')),
              ],
            );
          },
        );
      },
    );

    if (resultado != true || nombreCtrl.text.trim().isEmpty) return;
    try {
      final jornada = await context.read<AuthProvider>().jornadaService.crear(
            temporadaId: temporadaSeleccionada.id,
            nombre: nombreCtrl.text.trim(),
            fechaCierre: fechaCierre,
          );
      await _cargar();
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => JornadaAdminScreen(jornada: jornada)));
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración del sistema')),
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _crearTemporada,
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: const Text('Nueva temporada'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _crearJornada,
                                icon: const Icon(Icons.add),
                                label: const Text('Nueva jornada'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Temporadas', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _temporadas
                              .map((t) => Chip(label: Text(t.nombre)))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Text('Jornadas', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (_jornadas.isEmpty)
                          const EstadoVacio(icono: Icons.event_note_outlined, titulo: 'Todavía no hay jornadas creadas')
                        else
                          for (final jornada in _jornadas)
                            Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(jornada.nombre),
                                subtitle: Text('Cierre: ${_fmt.format(jornada.fechaCierre)}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => JornadaAdminScreen(jornada: jornada))),
                              ),
                            ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
