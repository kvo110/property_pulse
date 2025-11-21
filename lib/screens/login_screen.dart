// screens/login_screen.dart
// Temporary login screen so routing works
// Will be replaced with real log UI during development

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Login Screen (Place Holder)",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
