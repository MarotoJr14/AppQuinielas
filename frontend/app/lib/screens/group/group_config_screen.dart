import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';
import '../../widgets/inicial_avatar.dart';

class GroupConfigScreen extends StatefulWidget {
  const GroupConfigScreen({super.key});

  @override
  State<GroupConfigScreen> createState() => _GroupConfigScreenState();
}

class _GroupConfigScreenState extends State<GroupConfigScreen> {
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _editandoNombre = false;
  bool _editandoPassword = false;
  bool _cargando = false;
  final Map<int, String> _nombresUsuarios = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precargarNombres());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _precargarNombres() async {
    final groupProvider = context.read<GroupProvider>();
    final auth = context.read<AuthProvider>();
    for (final m in groupProvider.miembros) {
      final nombre = await auth.usuariosCache.nombreDe(m.usuarioId);
      if (mounted) setState(() => _nombresUsuarios[m.usuarioId] = nombre);
    }
  }

  Future<void> _guardarNombre() async {
    final groupProvider = context.read<GroupProvider>();
    if (_nombreCtrl.text.trim().length < 3) {
      mostrarErrorSnackbar(context, 'El nombre debe tener al menos 3 caracteres.');
      return;
    }
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().grupoService.actualizar(
            groupProvider.grupoActual!.id,
            nombre: _nombreCtrl.text.trim(),
          );
      final actualizado = await context.read<AuthProvider>().grupoService.obtener(groupProvider.grupoActual!.id);
      groupProvider.actualizarGrupo(actualizado);
      if (mounted) {
        mostrarExitoSnackbar(context, 'Nombre actualizado.');
        setState(() => _editandoNombre = false);
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarPassword() async {
    final groupProvider = context.read<GroupProvider>();
    if (_passwordCtrl.text.length < 4) {
      mostrarErrorSnackbar(context, 'La contraseña debe tener al menos 4 caracteres.');
      return;
    }
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().grupoService.actualizar(
            groupProvider.grupoActual!.id,
            password: _passwordCtrl.text,
          );
      if (mounted) {
        mostrarExitoSnackbar(context, 'Contraseña actualizada.');
        setState(() {
          _editandoPassword = false;
          _passwordCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarLider(int nuevoLiderId, String nombre) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar líder de la peña'),
        content: Text(
          '¿Seguro que quieres nombrar a "$nombre" nuevo líder? '
          'En cuanto confirmes, dejarás de tener acceso a esta configuración.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmado != true) return;

    final groupProvider = context.read<GroupProvider>();
    try {
      await context.read<AuthProvider>().grupoService.cambiarLider(groupProvider.grupoActual!.id, nuevoLiderId);
      await groupProvider.recargarMiembros();
      if (mounted) {
        mostrarExitoSnackbar(context, 'Líder actualizado.');
        if (!groupProvider.esLider) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final grupo = groupProvider.grupoActual;

    if (grupo == null) {
      return const AppScaffold(body: EstadoVacio(icono: Icons.groups_outlined, titulo: 'No hay ninguna peña activa'));
    }

    if (!groupProvider.esLider) {
      return const AppScaffold(
        body: EstadoVacio(
          icono: Icons.lock_outline,
          titulo: 'Solo el líder del grupo puede acceder a esta pantalla',
        ),
      );
    }

    _nombreCtrl.text = _editandoNombre ? _nombreCtrl.text : grupo.nombre;

    return AppScaffold(
      body: ListView(
        children: [
          Text('Configuración de la peña', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Nombre de la peña', style: Theme.of(context).textTheme.titleSmall)),
                      TextButton(
                        onPressed: () => setState(() {
                          _editandoNombre = !_editandoNombre;
                          _nombreCtrl.text = grupo.nombre;
                        }),
                        child: Text(_editandoNombre ? 'Cancelar' : 'Cambiar'),
                      ),
                    ],
                  ),
                  if (!_editandoNombre) Text(grupo.nombre, style: Theme.of(context).textTheme.bodyMedium),
                  if (_editandoNombre) ...[
                    const SizedBox(height: 8),
                    TextField(controller: _nombreCtrl),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _cargando ? null : _guardarNombre, child: const Text('Guardar')),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Contraseña de la peña', style: Theme.of(context).textTheme.titleSmall)),
                      TextButton(
                        onPressed: () => setState(() => _editandoPassword = !_editandoPassword),
                        child: Text(_editandoPassword ? 'Cancelar' : 'Cambiar'),
                      ),
                    ],
                  ),
                  if (_editandoPassword) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _cargando ? null : _guardarPassword, child: const Text('Guardar')),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Miembros (${groupProvider.miembros.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final miembro in groupProvider.miembros)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: InicialAvatar(
                  inicial: (_nombresUsuarios[miembro.usuarioId] ?? '?').isNotEmpty
                      ? (_nombresUsuarios[miembro.usuarioId] ?? '?')[0].toUpperCase()
                      : '?',
                ),
                title: Text(_nombresUsuarios[miembro.usuarioId] ?? 'Cargando...'),
                subtitle: miembro.esLider ? const Text('Líder de la peña') : null,
                trailing: miembro.esLider
                    ? const Icon(Icons.star, color: Colors.amber)
                    : TextButton(
                        onPressed: () => _cambiarLider(miembro.usuarioId, _nombresUsuarios[miembro.usuarioId] ?? ''),
                        child: const Text('Hacer líder'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
