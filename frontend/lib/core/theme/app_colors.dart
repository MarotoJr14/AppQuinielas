import 'package:flutter/material.dart';

/// Paleta de colores de la app, tal y como se especifica en frontend.md.
class AppColors {
  AppColors._();

  static const Color fondoClaro = Color(0xFFF8F7F4);
  static const Color fondoOscuro = Color(0xFF121212);
  static const Color acento = Color(0xFFC9A227);
  static const Color aciertos = Color(0xFF2E8B57);
  static const Color errores = Color(0xFFC94A4A);

  // Superficies derivadas para tarjetas, inputs, etc. (no vienen especificadas
  // explícitamente en frontend.md, pero se derivan de los fondos base para
  // mantener coherencia visual entre ambos temas).
  static const Color superficieClara = Color(0xFFFFFFFF);
  static const Color superficieOscura = Color(0xFF1E1E1E);

  static const Color bordeClaro = Color(0xFFE3E1D9);
  static const Color bordeOscuro = Color(0xFF2C2C2C);

  static const Color textoClaro = Color(0xFF1B1B18);
  static const Color textoOscuro = Color(0xFFF2F1EC);

  static const Color textoSecundarioClaro = Color(0xFF6B685F);
  static const Color textoSecundarioOscuro = Color(0xFFA8A59C);
}
