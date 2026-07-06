import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/apuesta.dart';
import '../../models/temporada_jornada.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';
import 'queue_detail_screen.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  bool _cargando = true;
  String? _error;
  List<Apuesta> _apuestas = [];
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
    });
    try {
      final auth = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();
      final apuestas = await auth.apuestaService.listarEnCola(groupProvider.grupoActual!.id);
      for (final a in apuestas) {
        if (!_jornadas.containsKey(a.jornadaId)) {
          _jornadas[a.jornadaId] = await auth.jornadaService.obtener(a.jornadaId);
        }
      }
      setState(() => _apuestas = apuestas);
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
            Text('Quinielas en cola', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Apuestas pendientes de pago, ordenadas por fecha límite.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const CargandoWidget()
            else if (_error != null)
              ErrorBanner(mensaje: _error!, onReintentar: _cargar)
            else if (_apuestas.isEmpty)
              const EstadoVacio(
                icono: Icons.inbox_outlined,
                titulo: 'No hay quinielas en cola',
                subtitulo: 'Crea una nueva quiniela desde el dashboard.',
              )
            else
              for (final apuesta in _apuestas)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.pending_actions_outlined),
                    title: Text(_jornadas[apuesta.jornadaId]?.nombre ?? 'Jornada #${apuesta.jornadaId}'),
                    subtitle: Text(
                      _jornadas[apuesta.jornadaId] != null
                          ? 'Cierra: ${_fmt.format(_jornadas[apuesta.jornadaId]!.fechaCierre)}'
                          : '',
                    ),
                    trailing: Text(
                      apuesta.precio != null ? '${apuesta.precio!.toStringAsFixed(2)} €' : '-',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => QueueDetailScreen(apuestaId: apuesta.id)))
                        .then((_) => _cargar()),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
