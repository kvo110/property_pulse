// services/property_service.dart
// Handles Firestore reads/writes for property listings.
// Keeping this separate from the UI so our screens stay cleaner.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Creates a new property listing in the "properties" collection.
  // Returns null if everything worked, otherwise returns an error message.
  Future<String?> createProperty({
    required String title,
    required int price,
    required int bedrooms,
    required double bathrooms,
    required String type,
    required String city,
    required String state,
    required String description,
    required List<String> images,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return "You must be logged in to create a listing.";
      }

      await _firestore.collection("properties").add({
        "ownerId": user.uid,
        "title": title,
        "price": price,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "type": type,
        "city": city,
        "state": state,
        "description": description,
        "images": images,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to create listing. Please try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Stream of all properties created by the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> userPropertiesStream() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection("properties")
        .where("ownerId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Deletes a property by document id.
  Future<String?> deleteProperty(String docId) async {
    try {
      await _firestore.collection("properties").doc(docId).delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to delete listing.";
    } catch (e) {
      return "Something went wrong while deleting listing.";
    }
  }
}
