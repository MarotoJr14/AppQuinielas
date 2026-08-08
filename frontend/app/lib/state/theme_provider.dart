import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// Gestiona el tema claro/oscuro de la app y persiste la elección del
/// usuario. Por defecto se carga con el tema claro, tal y como pide
/// frontend.md.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.light;

  ThemeMode get modo => _modo;
  bool get esOscuro => _modo == ThemeMode.dark;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(AppConstants.prefsThemeKey);
    _modo = guardado == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> alternar() async {
    _modo = _modo == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsThemeKey, _modo == ThemeMode.dark ? 'dark' : 'light');
  }
}
