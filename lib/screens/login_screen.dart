// screens/login_screen.dart
// Login UI for PropertyPulse.
// I added extra comments so it's easier for both of us to understand.
// This screen is ONLY handling UI for now – the actual Firebase login will be connected later
// once we finish AuthService + AuthProvider.

import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextField controllers – these capture whatever the user types in.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false; // used to show the loading spinner during login

  @override
  void dispose() {
    // Clean up the controllers when leaving the screen.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // TEMP login function – we’re just printing values for now.
  // Once AuthService is added, this will be replaced with real Firebase login.
  void _handleLogin() async {
    setState(() => isLoading = true);

    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");

    // Fake loading delay just to make UI feel more real
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Colors used throughout the screen (Discord-style)
    const cardColor = Color(0xFF23272A);
    const accent = Color(0xFF5865F2);

    return Scaffold(
      // Instead of a solid background, this is the purple gradient layer
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // starts bright on top → dark on bottom
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5865F2), Color(0xFF4752C4), Color(0xFF2C2F33)],
          ),
        ),

        // Centering the login card container
        child: Center(
          child: Container(
            // This is the actual card that holds the fields/buttons
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),

            // The column holds: title → subtitle → fields → button → nav link
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  "Log in to your PropertyPulse account",
                  style: TextStyle(color: Colors.grey[400]),
                ),

                const SizedBox(height: 25),

                // Email Input
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email"),
                ),

                const SizedBox(height: 15),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password"),
                ),

                const SizedBox(height: 25),

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

                const SizedBox(height: 14),

                // Navigation to the Register page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
        ),
      ),
    );
  }

  // Helper function so input fields look consistent and clean
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black26,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
