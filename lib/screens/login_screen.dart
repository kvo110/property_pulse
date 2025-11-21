// screens/login_screen.dart
// Temporary login screen so routing works
// App will hook this into FirebaseAuth once the AuthService is created

import 'package:flutter/material.dart';
import 'register_screen.dart'; // to navigate to sign-up page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controllers hold whatever the user types in
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false; // used to disable the button during login

  @override
  void dispose() {
    // cleaning up controllers
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // This will run when the user press 'Log In'
  void _handleLogin() async {
    setState(() => isLoading = true);

    // ATTENTION: implement Firebase log in (Only a placeholder currently)
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");

    await Future.delayed(const Duration(seconds: 1)); // fake delay

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar purely for navigation at this stage
      appBar: AppBar(title: const Text("Property Pulse Login")),

      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Text(
              "Log In to Access Property Pulse",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            // Email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 22),

            // Log In button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Log In"),
              ),
            ),

            const SizedBox(height: 20),

            // Register navigation
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Create one"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
