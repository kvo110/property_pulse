// screens/register_screen.dart
// Sign-up screen for new users.
// Keeping the look consistent with the Discord-style theme used on login_screen.
// Once we hook this up to FirebaseAuth + Firestore, the inputs here will create new user accounts.

import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Text controllers used for each field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false; // just like login, used for loading state

  @override
  void dispose() {
    // cleanup
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // TEMP register function – we’ll replace this with real Firebase register.
  void _handleRegister() async {
    // Simple check so user doesn't type mismatched passwords
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    print("Name: ${nameController.text}");
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Consistent color palette
    const cardColor = Color(0xFF23272A);
    const accent = Color(0xFF5865F2);

    return Scaffold(
      body: Container(
        // Purple gradient background (same as login)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5865F2), Color(0xFF4752C4), Color(0xFF2C2F33)],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Sign up to start using PropertyPulse",
                    style: TextStyle(color: Colors.grey[400]),
                  ),

                  const SizedBox(height: 25),

                  // Fields
                  _buildInput(nameController, "Full Name"),
                  const SizedBox(height: 15),

                  _buildInput(emailController, "Email"),
                  const SizedBox(height: 15),

                  _buildInput(passwordController, "Password", obscure: true),
                  const SizedBox(height: 15),

                  _buildInput(
                    confirmController,
                    "Confirm Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 25),

                  // Create account button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
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
                          : const Text("Create Account"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to avoid rewriting the same TextField code 4 times
  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black26,
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
