import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/apuesta.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';

class _StatUsuario {
  final int usuarioId;
  final String nombre;
  int aciertos = 0;
  int fallos = 0;
  int columnas = 0;

  _StatUsuario({required this.usuarioId, required this.nombre});
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _cargando = true;
  String? _error;
  List<_StatUsuario> _ranking = [];

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
      final historial = await auth.apuestaService.listarHistorial(groupProvider.grupoActual!.id);
      final cerradas = historial.where((a) => a.estado == EstadoApuesta.cerrada || a.estado == EstadoApuesta.finalizada);

      final Map<int, _StatUsuario> agregados = {};
      for (final apuesta in cerradas) {
        List<RankingFila> ranking;
        try {
          ranking = await auth.apuestaService.ranking(apuesta.id);
        } catch (_) {
          continue;
        }
        for (final fila in ranking.where((f) => !f.esElige8)) {
          final stat = agregados.putIfAbsent(
            fila.usuarioId,
            () => _StatUsuario(usuarioId: fila.usuarioId, nombre: fila.nombreUsuario),
          );
          stat.aciertos += fila.aciertos;
          stat.fallos += fila.fallos;
          stat.columnas += 1;
        }
      }

      final lista = agregados.values.toList()..sort((a, b) => b.aciertos.compareTo(a.aciertos));
      setState(() => _ranking = lista);
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
            Text('Estadísticas de la peña', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Ranking histórico de aciertos (columnas normales, sin Elige 8).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const CargandoWidget()
            else if (_error != null)
              ErrorBanner(mensaje: _error!, onReintentar: _cargar)
            else if (_ranking.isEmpty)
              const EstadoVacio(
                icono: Icons.bar_chart_outlined,
                titulo: 'Todavía no hay datos suficientes',
                subtitulo: 'Aparecerán estadísticas cuando haya quinielas finalizadas.',
              )
            else
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < _ranking.length; i++)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: i == 0 ? AppColors.acento : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text('${i + 1}', style: TextStyle(color: i == 0 ? Colors.white : null)),
                        ),
                        title: Text(_ranking[i].nombre),
                        subtitle: Text(
                          '${_ranking[i].columnas} quinielas jugadas · ${_ranking[i].fallos} fallos totales',
                        ),
                        trailing: Text(
                          '${_ranking[i].aciertos} aciertos',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
