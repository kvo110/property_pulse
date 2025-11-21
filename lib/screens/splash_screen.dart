// screens/splash_screen.dart
// This screen quickly checks if a user is already signed in.
// If they are -> send them straight to the NavBar.
// If not -> send them to LoginScreen.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/nav_bar.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState(); // check login state as soon as splash loads
  }

  // Simple auth check using FirebaseAuth
  void _checkAuthState() async {
    // small delay to make the splash screen visible for a moment
    await Future.delayed(const Duration(seconds: 1));

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // Already signed in -> go straight to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavBar()),
      );
    } else {
      // Not signed in yet -> go to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple loading indicator while the check runs
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
