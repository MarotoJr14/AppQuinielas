import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../widgets/common.dart';

class CrearGrupoScreen extends StatefulWidget {
  const CrearGrupoScreen({super.key});

  @override
  State<CrearGrupoScreen> createState() => _CrearGrupoScreenState();
}

class _CrearGrupoScreenState extends State<CrearGrupoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthProvider>().grupoService.crear(
            nombre: _nombreCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (mounted) {
        mostrarExitoSnackbar(context, 'Peña creada correctamente.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear un grupo')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Nueva peña', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Serás el líder de esta peña y podrás gestionar sus quinielas.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la peña',
                        prefixIcon: Icon(Icons.shield_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'Mínimo 3 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña de la peña',
                        prefixIcon: Icon(Icons.lock_outline),
                        helperText: 'La usarán tus compañeros para unirse',
                      ),
                      validator: (v) => (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _cargando ? null : _crear,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Crear peña'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
