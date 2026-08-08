import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Construye los ThemeData claro y oscuro de la app, ambos derivados de la
/// paleta de colores definida en frontend.md.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.acento,
      brightness: Brightness.light,
      primary: AppColors.acento,
      error: AppColors.errores,
      surface: AppColors.superficieClara,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.fondoClaro,
      canvasColor: AppColors.fondoClaro,
      dividerColor: AppColors.bordeClaro,
      fontFamily: 'Roboto',
      textTheme: _textTheme(AppColors.textoClaro, AppColors.textoSecundarioClaro),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.superficieClara,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficieClara,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.bordeClaro),
        ),
      ),
      inputDecorationTheme: _inputTheme(AppColors.superficieClara, AppColors.bordeClaro),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(AppColors.acento),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.acento),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.superficieClara),
      chipTheme: _chipTheme(AppColors.fondoClaro, AppColors.bordeClaro, AppColors.textoClaro),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.acento,
      brightness: Brightness.dark,
      primary: AppColors.acento,
      error: AppColors.errores,
      surface: AppColors.superficieOscura,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.fondoOscuro,
      canvasColor: AppColors.fondoOscuro,
      dividerColor: AppColors.bordeOscuro,
      fontFamily: 'Roboto',
      textTheme: _textTheme(AppColors.textoOscuro, AppColors.textoSecundarioOscuro),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.superficieOscura,
        foregroundColor: AppColors.textoOscuro,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficieOscura,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.bordeOscuro),
        ),
      ),
      inputDecorationTheme: _inputTheme(AppColors.superficieOscura, AppColors.bordeOscuro),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(AppColors.acento),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.acento),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.superficieOscura),
      chipTheme: _chipTheme(AppColors.fondoOscuro, AppColors.bordeOscuro, AppColors.textoOscuro),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static TextTheme _textTheme(Color principal, Color secundario) {
    return TextTheme(
      titleLarge: TextStyle(color: principal, fontWeight: FontWeight.w700, fontSize: 22),
      titleMedium: TextStyle(color: principal, fontWeight: FontWeight.w600, fontSize: 17),
      titleSmall: TextStyle(color: principal, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: TextStyle(color: principal, fontSize: 16),
      bodyMedium: TextStyle(color: principal, fontSize: 14),
      bodySmall: TextStyle(color: secundario, fontSize: 12),
      labelLarge: TextStyle(color: principal, fontWeight: FontWeight.w600),
    );
  }

  static InputDecorationTheme _inputTheme(Color relleno, Color borde) {
    return InputDecorationTheme(
      filled: true,
      fillColor: relleno,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.acento, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errores),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.acento,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color color) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: color),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Color color) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ChipThemeData _chipTheme(Color fondo, Color borde, Color texto) {
    return ChipThemeData(
      backgroundColor: fondo,
      selectedColor: AppColors.acento,
      side: BorderSide(color: borde),
      labelStyle: TextStyle(color: texto, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
