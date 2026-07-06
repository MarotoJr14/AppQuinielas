import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final grupo = groupProvider.grupoActual;

    if (grupo == null) {
      return AppScaffold(
        body: EstadoVacio(
          icono: Icons.groups_outlined,
          titulo: 'No hay ninguna peña activa',
          subtitulo: 'Vuelve a Inicio y selecciona una peña.',
          accion: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false),
            child: const Text('Ir a Inicio'),
          ),
        ),
      );
    }

    final esLider = groupProvider.esLider;

    return AppScaffold(
      body: ListView(
        children: [
          Text(grupo.nombre, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            esLider ? 'Eres el líder de esta peña' : 'Miembro de la peña',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _TarjetaDashboard(
                icono: Icons.add_box_outlined,
                titulo: 'Nueva quiniela',
                habilitada: esLider,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/nueva-quiniela'),
                onTapDeshabilitada: () => mostrarErrorSnackbar(context, 'Solo el líder del grupo puede crear una nueva quiniela.'),
              ),
              _TarjetaDashboard(
                icono: Icons.pending_actions_outlined,
                titulo: 'Quinielas en cola',
                habilitada: true,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/cola'),
              ),
              _TarjetaDashboard(
                icono: Icons.live_tv_outlined,
                titulo: 'Ver quiniela en curso',
                habilitada: true,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/en-curso'),
              ),
              _TarjetaDashboard(
                icono: Icons.history_outlined,
                titulo: 'Últimos resultados',
                habilitada: true,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/resultados'),
              ),
              _TarjetaDashboard(
                icono: Icons.bar_chart_outlined,
                titulo: 'Estadísticas',
                habilitada: true,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/estadisticas'),
              ),
              _TarjetaDashboard(
                icono: Icons.settings_outlined,
                titulo: 'Configuración del grupo',
                habilitada: esLider,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/configuracion'),
                onTapDeshabilitada: () => mostrarErrorSnackbar(context, 'Solo el líder del grupo puede acceder a la configuración.'),
              ),
              _TarjetaDashboard(
                icono: Icons.chat_bubble_outline,
                titulo: 'Chat del grupo',
                habilitada: true,
                onTap: () => Navigator.of(context).pushNamed('/dashboard/chat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaDashboard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final bool habilitada;
  final VoidCallback onTap;
  final VoidCallback? onTapDeshabilitada;

  const _TarjetaDashboard({
    required this.icono,
    required this.titulo,
    required this.habilitada,
    required this.onTap,
    this.onTapDeshabilitada,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: habilitada ? onTap : onTapDeshabilitada,
        child: Opacity(
          opacity: habilitada ? 1 : 0.45,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: 32, color: AppColors.acento),
                const SizedBox(height: 10),
                Text(titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
