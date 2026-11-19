import 'package:flutter/material.dart';

/// Colores y tipografía de PetCare, en claro y oscuro.
abstract final class TemaApp {
  static const _semilla = Color(0xFF2E7D6B);

  static final ThemeData claro = _crear(Brightness.light);
  static final ThemeData oscuro = _crear(Brightness.dark);

  static ThemeData _crear(Brightness brillo) {
    final colores = ColorScheme.fromSeed(
      seedColor: _semilla,
      brightness: brillo,
    );
    return ThemeData(
      colorScheme: colores,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colores.surface,
        foregroundColor: colores.onSurface,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
    );
  }
}
