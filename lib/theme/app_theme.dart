// theme/app_theme.dart
// Central light + dark themes using Material 3 styling.

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
