import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/inicial_avatar.dart';

class UsuarioInfoScreen extends StatefulWidget {
  const UsuarioInfoScreen({super.key});

  @override
  State<UsuarioInfoScreen> createState() => _UsuarioInfoScreenState();
}

class _UsuarioInfoScreenState extends State<UsuarioInfoScreen> {
  bool _editandoNombre = false;
  bool _editandoPassword = false;

  final _nombreFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmarPasswordCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarPasswordCtrl.dispose();
    super.dispose();
  }

  String? _validarUsuario(String? v) {
    if (v == null || v.trim().isEmpty) return 'Introduce un nombre de usuario';
    final regex = RegExp(r'^[a-z0-9]+$');
    if (!regex.hasMatch(v)) return 'Solo se permiten letras minúsculas y números';
    if (v.length < 3) return 'Debe tener al menos 3 caracteres';
    return null;
  }

  String? _validarPassword(String? v) {
    if (v == null || v.isEmpty) return 'Introduce una contraseña';
    if (v.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe contener al menos 1 mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Debe contener al menos 1 minúscula';
    return null;
  }

  Future<void> _guardarNombre() async {
    if (!_nombreFormKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().usuarioService.actualizarMiUsuario(nombreUsuario: _nombreCtrl.text.trim());
      await context.read<AuthProvider>().refrescarUsuario();
      if (mounted) {
        mostrarExitoSnackbar(context, 'Nombre de usuario actualizado.');
        setState(() => _editandoNombre = false);
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().usuarioService.actualizarMiUsuario(password: _passwordCtrl.text);
      if (mounted) {
        mostrarExitoSnackbar(context, 'Contraseña actualizada.');
        setState(() {
          _editandoPassword = false;
          _passwordCtrl.clear();
          _confirmarPasswordCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuarioActual;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  InicialAvatar(inicial: usuario?.inicial ?? '?', radio: 40),
                  const SizedBox(height: 12),
                  Text(usuario?.nombreUsuario ?? '', style: Theme.of(context).textTheme.titleLarge),
                  Text(usuario?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Nombre de usuario', style: Theme.of(context).textTheme.titleSmall),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  _editandoNombre = !_editandoNombre;
                                  _nombreCtrl.text = usuario?.nombreUsuario ?? '';
                                }),
                                child: Text(_editandoNombre ? 'Cancelar' : 'Cambiar'),
                              ),
                            ],
                          ),
                          if (_editandoNombre) ...[
                            const SizedBox(height: 8),
                            Form(
                              key: _nombreFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _nombreCtrl,
                                    decoration: const InputDecoration(helperText: 'Solo minúsculas y números'),
                                    validator: _validarUsuario,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _cargando ? null : _guardarNombre,
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Contraseña', style: Theme.of(context).textTheme.titleSmall),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _editandoPassword = !_editandoPassword),
                                child: Text(_editandoPassword ? 'Cancelar' : 'Cambiar'),
                              ),
                            ],
                          ),
                          if (_editandoPassword) ...[
                            const SizedBox(height: 8),
                            Form(
                              key: _passwordFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Nueva contraseña',
                                      helperText: 'Mín. 8 caracteres, 1 mayúscula y 1 minúscula',
                                    ),
                                    validator: _validarPassword,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _confirmarPasswordCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña'),
                                    validator: (v) => v != _passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _cargando ? null : _guardarPassword,
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
