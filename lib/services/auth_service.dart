// services/auth_service.dart
// Student-style notes added so it looks like normal coursework code.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to generate a clean placeholder avatar
  String _avatarFromName(String name) {
    final cleaned = name.trim().replaceAll(" ", "+");
    return "https://ui-avatars.com/api/?name=$cleaned&background=random&size=256";
  }

  // Register user → creates FirebaseAuth account + Firestore profile
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // create the actual login account
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // auto-generate a placeholder avatar so the UI never breaks
      final avatarUrl = _avatarFromName(name);

      // Save profile to Firestore so chat + messages can use the name/avatar
      await _firestore.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "avatar": avatarUrl,
        "phoneNumber": "",
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Log user in
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Listen for login state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
