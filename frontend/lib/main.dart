import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/auth_provider.dart';
import 'state/group_provider.dart';
import 'state/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/registro_screen.dart';
import 'screens/auth/recuperar_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/crear_grupo_screen.dart';
import 'screens/home/unirse_grupo_screen.dart';
import 'screens/home/usuario_info_screen.dart';
import 'screens/home/admin_screen.dart';
import 'screens/group/dashboard_screen.dart';
import 'screens/group/new_quiniela_screen.dart';
import 'screens/group/queue_screen.dart';
import 'screens/group/live_screen.dart';
import 'screens/group/results_screen.dart';
import 'screens/group/stats_screen.dart';
import 'screens/group/group_config_screen.dart';
import 'screens/group/chat_screen.dart';
import 'widgets/common.dart';

void main() {
  runApp(const QuinielasApp());
}

class QuinielasApp extends StatelessWidget {
  const QuinielasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..inicializar()),
        ChangeNotifierProxyProvider<AuthProvider, GroupProvider>(
          create: (context) => GroupProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? GroupProvider(auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Quinielas',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.modo,
            initialRoute: '/',
            routes: {
              '/': (context) => const _AuthGate(),
              '/login': (context) => const LoginScreen(),
              '/registro': (context) => const RegistroScreen(),
              '/recuperar-password': (context) => const RecuperarPasswordScreen(),
              '/home': (context) => const HomeScreen(),
              '/grupos/crear': (context) => const CrearGrupoScreen(),
              '/grupos/unirse': (context) => const UnirseGrupoScreen(),
              '/usuario/info': (context) => const UsuarioInfoScreen(),
              '/admin': (context) => const AdminScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/dashboard/nueva-quiniela': (context) => const NewQuinielaScreen(),
              '/dashboard/cola': (context) => const QueueScreen(),
              '/dashboard/en-curso': (context) => const LiveScreen(),
              '/dashboard/resultados': (context) => const ResultsScreen(),
              '/dashboard/estadisticas': (context) => const StatsScreen(),
              '/dashboard/configuracion': (context) => const GroupConfigScreen(),
              '/dashboard/chat': (context) => const ChatScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Punto de entrada de la app: espera a que [AuthProvider] determine si hay
/// una sesión válida y redirige a Login o a Home en consecuencia.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.estado) {
      case EstadoSesion.cargando:
        return const Scaffold(body: CargandoWidget());
      case EstadoSesion.invitado:
        return const LoginScreen();
      case EstadoSesion.autenticado:
        return const HomeScreen();
    }
  }
}
