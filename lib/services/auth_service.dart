// services/auth_service.dart
// Logic layer for authentication and user profile creation.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // FirebaseAuth account
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Firestore profile
      await _firestore.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phoneNumber": "",
        "avatar": "", // default empty avatar, can be updated from profile
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Log In User
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

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
