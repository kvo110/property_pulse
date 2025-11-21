// theme/theme_provider.dart
// Provider that stores whether the app is in light or dark mode.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  // Flip the mode and notify app to rebuild with new theme
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // Return ThemeMode based on current state
  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
