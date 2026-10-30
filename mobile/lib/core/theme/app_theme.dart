import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const marca = Color(0xFF1F4E79);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: marca,
        brightness: brightness,
      ),
    );
  }
}
