import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/grupo.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _porPagina = 10;

  List<Grupo> _grupos = [];
  bool _cargando = true;
  String? _error;
  int _pagina = 0;
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar({String? search}) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final grupos = await context.read<AuthProvider>().grupoService.listarMisGrupos(search: search);
      setState(() {
        _grupos = grupos;
        _pagina = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _entrarEnGrupo(Grupo grupo) async {
    final groupProvider = context.read<GroupProvider>();
    await groupProvider.entrarEnGrupo(grupo);
    if (mounted) Navigator.of(context).pushNamed('/dashboard');
  }

  List<Grupo> get _grupoPaginaActual {
    final inicio = _pagina * _porPagina;
    if (inicio >= _grupos.length) return [];
    final fin = (inicio + _porPagina).clamp(0, _grupos.length);
    return _grupos.sublist(inicio, fin);
  }

  int get _totalPaginas => (_grupos.length / _porPagina).ceil().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: () => _cargar(search: _busquedaCtrl.text),
        child: ListView(
          children: [
            Text('Tus peñas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Elige una peña para gestionar sus quinielas, o crea/únete a una nueva.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/grupos/crear').then((_) => _cargar()),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear un grupo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/grupos/unirse').then((_) => _cargar()),
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('Unirse a un grupo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _busquedaCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar peña...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) => _cargar(search: v),
            ),
            const SizedBox(height: 20),
            if (authProvider.esAdmin) ...[
              _TarjetaAdmin(onTap: () => Navigator.of(context).pushNamed('/admin')),
              const SizedBox(height: 20),
            ],
            if (_cargando)
              const CargandoWidget()
            else if (_error != null)
              ErrorBanner(mensaje: _error!, onReintentar: () => _cargar(search: _busquedaCtrl.text))
            else if (_grupos.isEmpty)
              const EstadoVacio(
                icono: Icons.groups_outlined,
                titulo: 'Todavía no perteneces a ninguna peña',
                subtitulo: 'Crea una nueva o únete a una existente para empezar.',
              )
            else ...[
              for (final grupo in _grupoPaginaActual)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaGrupo(grupo: grupo, onTap: () => _entrarEnGrupo(grupo)),
                ),
              if (_totalPaginas > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _pagina > 0 ? () => setState(() => _pagina--) : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Página ${_pagina + 1} de $_totalPaginas'),
                      IconButton(
                        onPressed: _pagina < _totalPaginas - 1 ? () => setState(() => _pagina++) : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaGrupo extends StatelessWidget {
  final Grupo grupo;
  final VoidCallback onTap;

  const _TarjetaGrupo({required this.grupo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.acento.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.acento),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(grupo.nombre, style: Theme.of(context).textTheme.titleSmall),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAdmin extends StatelessWidget {
  final VoidCallback onTap;
  const _TarjetaAdmin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.acento.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: AppColors.acento),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Administración del sistema',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
