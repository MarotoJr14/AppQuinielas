import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';
import 'queue_detail_screen.dart';

class NewQuinielaScreen extends StatefulWidget {
  const NewQuinielaScreen({super.key});

  @override
  State<NewQuinielaScreen> createState() => _NewQuinielaScreenState();
}

class _NewQuinielaScreenState extends State<NewQuinielaScreen> {
  int _paso = 0;
  bool _cargando = true;
  List<Jornada> _jornadasDisponibles = [];
  Jornada? _jornadaSeleccionada;
  int? _usuarioElige8Id;
  final Map<int, String> _nombresUsuarios = {};

  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final groupProvider = context.read<GroupProvider>();
    final auth = context.read<AuthProvider>();
    try {
      final jornadas = await auth.jornadaService.listarDisponibles(groupProvider.grupoActual!.id);
      for (final m in groupProvider.miembros) {
        final nombre = await auth.usuariosCache.nombreDe(m.usuarioId);
        _nombresUsuarios[m.usuarioId] = nombre;
      }
      setState(() => _jornadasDisponibles = jornadas);
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _crearApuesta() async {
    if (_jornadaSeleccionada == null || _usuarioElige8Id == null) return;
    setState(() => _cargando = true);
    final groupProvider = context.read<GroupProvider>();
    try {
      final apuesta = await context.read<AuthProvider>().apuestaService.crear(
            jornadaId: _jornadaSeleccionada!.id,
            grupoId: groupProvider.grupoActual!.id,
            usuarioElige8Id: _usuarioElige8Id!,
          );
      if (mounted) {
        mostrarExitoSnackbar(context, 'Quiniela creada. ¡Ya podéis rellenar vuestras columnas!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QueueDetailScreen(apuestaId: apuesta.id)),
        );
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: _cargando && _jornadasDisponibles.isEmpty
          ? const CargandoWidget()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nueva quiniela', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  _paso == 0 ? 'Paso 1 de 2 — Elige la jornada' : 'Paso 2 de 2 — Asigna la columna Elige 8',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _paso == 0 ? _pasoJornada() : _pasoElige8(),
                ),
              ],
            ),
    );
  }

  Widget _pasoJornada() {
    if (_jornadasDisponibles.isEmpty) {
      return const EstadoVacio(
        icono: Icons.event_busy_outlined,
        titulo: 'No hay jornadas disponibles',
        subtitulo: 'O bien no hay jornadas abiertas, o vuestra peña ya ha apostado a todas.',
      );
    }
    return ListView(
      children: [
        for (final jornada in _jornadasDisponibles)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<Jornada>(
              value: jornada,
              groupValue: _jornadaSeleccionada,
              onChanged: (v) => setState(() => _jornadaSeleccionada = v),
              title: Text(jornada.nombre),
              subtitle: Text('Cierra: ${_fmt.format(jornada.fechaCierre)}'),
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _jornadaSeleccionada != null ? () => setState(() => _paso = 1) : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _pasoElige8() {
    final groupProvider = context.watch<GroupProvider>();
    return ListView(
      children: [
        Text(
          'Elige quién se encargará de la columna especial "Elige 8" para esta quiniela.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final m in groupProvider.miembros)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<int>(
              value: m.usuarioId,
              groupValue: _usuarioElige8Id,
              onChanged: (v) => setState(() => _usuarioElige8Id = v),
              title: Text(_nombresUsuarios[m.usuarioId] ?? 'Usuario #${m.usuarioId}'),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _paso = 0),
                child: const Text('Atrás'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_usuarioElige8Id != null && !_cargando) ? _crearApuesta : null,
                child: _cargando
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Crear quiniela'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
