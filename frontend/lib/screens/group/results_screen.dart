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

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _cargando = true;
  String? _error;
  final List<Apuesta> _finalizadas = [];
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
      _finalizadas.clear();
    });
    try {
      final auth = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();
      final historial = await auth.apuestaService.listarHistorial(groupProvider.grupoActual!.id);
      for (final apuesta in historial.where((a) => a.estado == EstadoApuesta.cerrada)) {
        final completada = await apuestaCompletada(auth, apuesta);
        if (completada) {
          _finalizadas.add(apuesta);
          _jornadas[apuesta.jornadaId] = await auth.jornadaService.obtener(apuesta.jornadaId);
        }
      }
      _finalizadas.sort((a, b) {
        final ja = _jornadas[a.jornadaId]?.fechaCierre ?? DateTime(2000);
        final jb = _jornadas[b.jornadaId]?.fechaCierre ?? DateTime(2000);
        return jb.compareTo(ja);
      });
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
            Text('Últimos resultados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Historial de quinielas finalizadas.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            if (_cargando)
              const CargandoWidget()
            else if (_error != null)
              ErrorBanner(mensaje: _error!, onReintentar: _cargar)
            else if (_finalizadas.isEmpty)
              const EstadoVacio(
                icono: Icons.history_outlined,
                titulo: 'Todavía no hay quinielas finalizadas',
              )
            else
              for (final apuesta in _finalizadas)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events_outlined),
                    title: Text(_jornadas[apuesta.jornadaId]?.nombre ?? 'Jornada #${apuesta.jornadaId}'),
                    subtitle: Text(
                      _jornadas[apuesta.jornadaId] != null
                          ? _fmt.format(_jornadas[apuesta.jornadaId]!.fechaCierre)
                          : '',
                    ),
                    trailing: Text(
                      apuesta.beneficio != null ? '${apuesta.beneficio!.toStringAsFixed(2)} €' : '-',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
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
