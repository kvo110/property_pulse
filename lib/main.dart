// main.dart
// PropertyPulse - Real Estate Market
// Kenny Vo & Edison Zheng – Mobile App Development

// This file sets up the app theme (light/dark), NavBar, and Provider setup.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Theme imports
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

// Nav bar (main navigation shell for the whole app)
import 'navigation/nav_bar.dart';

void main() {
  // Run the app with theme provider for dark/light mode
  runApp(const PropertyPulse());
}

class PropertyPulse extends StatelessWidget {
  const PropertyPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ThemeProvider manages whether the app is in light or dark mode
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PropertyPulse',

            // Light and dark themes stored in app_theme.dart
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.currentTheme,

            // Bottom navigation bar is our home shell for now
            home: const NavBar(),
          );
        },
      ),
    );
  }
}
