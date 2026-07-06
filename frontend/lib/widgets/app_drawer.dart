import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../state/group_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final dentroDeGrupo = groupProvider.grupoActual != null;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.acento,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sports_soccer, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text('Quinielas', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            const Divider(height: 1),
            _ItemMenu(
              icono: Icons.home_outlined,
              texto: 'Inicio',
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
            ),
            if (dentroDeGrupo) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: _EtiquetaSeccion(texto: 'PEÑA ACTIVA'),
              ),
              _ItemMenu(
                icono: Icons.dashboard_outlined,
                texto: 'Dashboard',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false),
              ),
              _ItemMenu(
                icono: Icons.add_box_outlined,
                texto: 'Nueva quiniela',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/nueva-quiniela'),
              ),
              _ItemMenu(
                icono: Icons.pending_actions_outlined,
                texto: 'Quinielas en cola',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/cola'),
              ),
              _ItemMenu(
                icono: Icons.live_tv_outlined,
                texto: 'Ver quiniela en curso',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/en-curso'),
              ),
              _ItemMenu(
                icono: Icons.history_outlined,
                texto: 'Últimos resultados',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/resultados'),
              ),
              _ItemMenu(
                icono: Icons.bar_chart_outlined,
                texto: 'Estadísticas',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/estadisticas'),
              ),
              _ItemMenu(
                icono: Icons.chat_bubble_outline,
                texto: 'Chat del grupo',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/chat'),
              ),
              _ItemMenu(
                icono: Icons.settings_outlined,
                texto: 'Configuración del grupo',
                onTap: () => Navigator.of(context).pushNamed('/dashboard/configuracion'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;
  const _EtiquetaSeccion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _ItemMenu({required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () {
        Navigator.of(context).pop(); // cierra el drawer
        onTap();
      },
    );
  }
}
