import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CargandoWidget extends StatelessWidget {
  const CargandoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
  }
}

class ErrorBanner extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const ErrorBanner({super.key, required this.mensaje, this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errores.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errores.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errores),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: AppColors.errores)),
          ),
          if (onReintentar != null)
            TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text(titulo, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(subtitulo!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (accion != null) ...[const SizedBox(height: 20), accion!],
          ],
        ),
      ),
    );
  }
}

/// Muestra un [SnackBar] de error a partir de cualquier excepción capturada.
void mostrarErrorSnackbar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString().replaceFirst('ApiException: ', '')),
      backgroundColor: AppColors.errores,
    ),
  );
}

void mostrarExitoSnackbar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje), backgroundColor: AppColors.aciertos),
  );
}
