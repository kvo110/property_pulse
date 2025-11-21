// theme/app_theme.dart
// Central light + dark themes using Material 3 styling.

import 'package:flutter/material.dart';

class AppTheme {
  // Light mode colors
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    useMaterial3: true,
  );

  // Dark mode colors
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    useMaterial3: true,
  );
}
