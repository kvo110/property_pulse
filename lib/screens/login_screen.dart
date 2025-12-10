// screens/login_screen.dart
// Login UI for PropertyPulse with enlarged logo + enlarged login card.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final errorMsg = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (errorMsg != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF23272A);
    const accent = Color(0xFF5865F2);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5865F2), Color(0xFF4752C4), Color(0xFF2C2F33)],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------- ENLARGED LOGO ----------
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: 360, // 🔥 increased from 320
                    height: 150, // 🔥 proportional increase
                    child: Image.asset(
                      "assets/images/property_pulse_logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                // ---------- ENLARGED LOGIN CARD ----------
                Container(
                  width: 360, // 🔥 increased from 320
                  padding: const EdgeInsets.all(28), // slightly more padding
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        "Welcome to Property Pulse",
                        style: TextStyle(
                          fontSize: 22, // 🔥 slightly increased
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Log in to your Property Pulse account",
                        style: TextStyle(color: Colors.grey[400]),
                      ),

                      const SizedBox(height: 28),

                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Email"),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Password"),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Log In"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black26,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
