// services/auth_service.dart
// This is the "logic layer" for authentication.
// Keeps FirebaseAuth code separate from UI so everything stays organized.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  // This creates the FirebaseAuth account and saves user details into Firestore.
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // create auth account
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // store profile in Firestore
      await _firestore.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "createdAt": DateTime.now(),
      });

      return null; // means registration was successful
    } on FirebaseAuthException catch (e) {
      return e.message; // return Firebase error message
    }
  }

  // Log In User
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // login successful
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logs the user out
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // This stream notifies us whenever the login state changes.
  // The provider will listen to this so the app automatically reacts to login/logout.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
