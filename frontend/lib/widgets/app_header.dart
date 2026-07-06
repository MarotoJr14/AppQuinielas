import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../state/group_provider.dart';
import '../state/theme_provider.dart';
import 'inicial_avatar.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final usuario = authProvider.usuarioActual;
    final tituloCentral = groupProvider.grupoActual?.nombre ?? 'Inicio';

    return AppBar(
      centerTitle: true,
      title: Text(tituloCentral, style: Theme.of(context).textTheme.titleMedium),
      actions: [
        IconButton(
          tooltip: themeProvider.esOscuro ? 'Tema claro' : 'Tema oscuro',
          icon: Icon(themeProvider.esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: () => themeProvider.alternar(),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).pushNamed('/usuario/info'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                InicialAvatar(inicial: usuario?.inicial ?? '?', radio: 15),
                const SizedBox(width: 8),
                if (MediaQuery.of(context).size.width > 420)
                  Text(usuario?.nombreUsuario ?? '', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await authProvider.logout();
            groupProvider.salir();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
