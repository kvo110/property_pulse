// providers/auth_provider.dart
// This provider sits between the UI and the AuthService.
// The main goal is to let the UI easily react to login/logout events.
// Any screen can read the current user or call login/logout through this provider.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;

  // Listens to FirebaseAuth's stream so we always know if a user is logged in.
  // This is usually called as soon as the app starts (in main.dart or splash screen).
  void listenToAuthState() {
    _authService.authStateChanges.listen((user) {
      currentUser = user;
      notifyListeners(); // tells the UI something changed so it can rebuild
    });
  }

  // Calls AuthService's register function.
  // Returns an error message if something failed, otherwise null.
  Future<String?> register(String name, String email, String password) async {
    return await _authService.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }

  // Calls AuthService's login function.
  // If login fails, we return the Firebase error message.
  Future<String?> login(String email, String password) async {
    return await _authService.loginUser(email: email, password: password);
  }

  // Logs out the current user.
  Future<void> logout() async {
    await _authService.logoutUser();
  }
}
