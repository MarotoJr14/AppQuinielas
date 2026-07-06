import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/apuesta.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../utils/apuesta_utils.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';
import 'queue_detail_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  bool _cargando = true;
  String? _error;
  final List<Apuesta> _enCurso = [];
  final Map<int, Jornada> _jornadas = {};
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
      _enCurso.clear();
    });
    try {
      final auth = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();
      final historial = await auth.apuestaService.listarHistorial(groupProvider.grupoActual!.id);
      for (final apuesta in historial.where((a) => a.estado == EstadoApuesta.cerrada)) {
        final completada = await apuestaCompletada(auth, apuesta);
        if (!completada) {
          _enCurso.add(apuesta);
          _jornadas[apuesta.jornadaId] = await auth.jornadaService.obtener(apuesta.jornadaId);
        }
      }
      setState(() {});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          children: [
            Text('Quiniela en curso', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Seguimiento en directo de las quinielas que se están disputando.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const CargandoWidget()
            else if (_error != null)
              ErrorBanner(mensaje: _error!, onReintentar: _cargar)
            else if (_enCurso.isEmpty)
              const EstadoVacio(
                icono: Icons.live_tv_outlined,
                titulo: 'No hay ninguna quiniela en curso',
                subtitulo: 'Aparecerá aquí en cuanto una quiniela cerrada empiece a tener resultados.',
              )
            else
              for (final apuesta in _enCurso)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.live_tv_outlined),
                    title: Text(_jornadas[apuesta.jornadaId]?.nombre ?? 'Jornada #${apuesta.jornadaId}'),
                    subtitle: Text(
                      _jornadas[apuesta.jornadaId] != null
                          ? 'Cierre: ${_fmt.format(_jornadas[apuesta.jornadaId]!.fechaCierre)}'
                          : '',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => QueueDetailScreen(apuestaId: apuesta.id))),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
