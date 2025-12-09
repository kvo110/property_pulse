// main.dart
// PropertyPulse - Real Estate Market
// Kenny Vo & Edison Zheng – Mobile App Development

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart'; // <-- added
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before app loads
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PropertyPulse());
}

class PropertyPulse extends StatelessWidget {
  const PropertyPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(
          create: (_) => AuthProvider()..listenToAuthState(),
        ),

        ChangeNotifierProvider(
          create: (_) => PropertyProvider(), // <-- NEW PROVIDER
        ),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PropertyPulse',

            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.currentTheme,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
