import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'app_header.dart';

/// Estructura común (Header + Drawer) a todas las pantallas de la app,
/// salvo las de la sección de login, tal y como especifica frontend.md.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  const AppScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(padding: padding, child: body),
      ),
    );
  }
}
