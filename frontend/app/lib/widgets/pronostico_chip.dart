import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/pronostico.dart';

/// Chip pequeño y cuadrado usado para representar una opción de pronóstico
/// (1, X, 2, o un valor de goles). `acertado` colorea el chip en verde/rojo
/// cuando el partido ya tiene resultado (vista "en curso" / "resultados").
class ChipPronostico extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final bool? acertado;
  final VoidCallback? onTap;

  const ChipPronostico({
    super.key,
    required this.texto,
    required this.seleccionado,
    this.acertado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color fondo;
    Color borde;
    Color colorTexto;

    if (seleccionado && acertado == true) {
      fondo = AppColors.aciertos;
      borde = AppColors.aciertos;
      colorTexto = Colors.white;
    } else if (seleccionado && acertado == false) {
      fondo = AppColors.errores;
      borde = AppColors.errores;
      colorTexto = Colors.white;
    } else if (seleccionado) {
      fondo = AppColors.acento;
      borde = AppColors.acento;
      colorTexto = Colors.white;
    } else {
      fondo = Colors.transparent;
      borde = Theme.of(context).dividerColor;
      colorTexto = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borde),
        ),
        child: Text(
          texto,
          style: TextStyle(color: colorTexto, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}

/// Fila de 3 chips (1, X, 2) para el pronóstico de un partido normal.
class SelectorSigno extends StatelessWidget {
  final Signo? valor;
  final bool? acertado;
  final ValueChanged<Signo>? onChanged;

  const SelectorSigno({super.key, required this.valor, this.acertado, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in Signo.values) ...[
          ChipPronostico(
            texto: s.valorApi,
            seleccionado: valor == s,
            acertado: valor == s ? acertado : null,
            onTap: onChanged != null ? () => onChanged!(s) : null,
          ),
          if (s != Signo.values.last) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

/// Fila de 4 chips (0, 1, 2, M) para el pronóstico de goles del Pleno al 15.
class SelectorGoles extends StatelessWidget {
  final Goles? valor;
  final bool? acertado;
  final ValueChanged<Goles>? onChanged;

  const SelectorGoles({super.key, required this.valor, this.acertado, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final g in Goles.values) ...[
          ChipPronostico(
            texto: g.valorApi,
            seleccionado: valor == g,
            acertado: valor == g ? acertado : null,
            onTap: onChanged != null ? () => onChanged!(g) : null,
          ),
          if (g != Goles.values.last) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
