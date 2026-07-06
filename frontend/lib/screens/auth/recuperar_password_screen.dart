import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../widgets/common.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _formEmailKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nuevaPasswordCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _emailVerificado = false;
  bool _cargando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nuevaPasswordCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificarEmail() async {
    if (!_formEmailKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().authService.solicitarRecuperacion(_emailCtrl.text.trim());
      setState(() => _emailVerificado = true);
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _restablecer() async {
    if (!_formPasswordKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().authService.restablecerPassword(
            email: _emailCtrl.text.trim(),
            nuevaPassword: _nuevaPasswordCtrl.text,
          );
      if (mounted) {
        mostrarExitoSnackbar(context, 'Contraseña actualizada. Ya puedes iniciar sesión.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String? _validarPassword(String? v) {
    if (v == null || v.isEmpty) return 'Introduce una contraseña';
    if (v.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe contener al menos 1 mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Debe contener al menos 1 minúscula';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: !_emailVerificado ? _pasoEmail() : _pasoNuevaPassword(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pasoEmail() {
    return Form(
      key: _formEmailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('¿Olvidaste tu contraseña?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Introduce el correo electrónico vinculado a tu usuario.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce tu correo electrónico' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cargando ? null : _verificarEmail,
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _pasoNuevaPassword() {
    return Form(
      key: _formPasswordKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nueva contraseña', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Correo verificado: ${_emailCtrl.text.trim()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nuevaPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              helperText: 'Mín. 8 caracteres, 1 mayúscula y 1 minúscula',
            ),
            validator: _validarPassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmarCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar nueva contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) => v != _nuevaPasswordCtrl.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cargando ? null : _restablecer,
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Restablecer contraseña'),
          ),
        ],
      ),
    );
  }
}
