// providers/property_provider.dart
// Handles pulling property listings from Firestore and simple CRUD + favorites.

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  final CollectionReference propertiesRef = FirebaseFirestore.instance
      .collection("properties");

  // Stream all properties from Firestore as a list of maps
  Stream<List<Map<String, dynamic>>> allPropertiesStream() {
    return propertiesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // make sure images is always a List<String>
        final rawImages = data["images"];
        List<String> images;
        if (rawImages is List) {
          images = rawImages.map((e) => e.toString()).toList();
        } else if (rawImages is String && rawImages.isNotEmpty) {
          images = [rawImages];
        } else {
          images = ["https://via.placeholder.com/400x300.png?text=No+Image"];
        }

        return {
          "id": doc.id,
          "title": data["title"] ?? "No Title",
          "location": data["location"] ?? "",
          "value": data["value"] ?? 0,
          "bedrooms": data["bedrooms"] ?? 0,
          "bathrooms": data["bathrooms"] ?? 0,
          "images": images,
          "ownerId": data["ownerId"] ?? "",
          "createdAt": data["createdAt"],
        };
      }).toList();
    });
  }

  // Update an existing property
  Future<void> updateProperty(String id, Map<String, dynamic> updates) async {
    await propertiesRef.doc(id).update(updates);
  }

  // Delete a property
  Future<void> deleteProperty(String id) async {
    await propertiesRef.doc(id).delete();
  }

  // Stream the current user's favorites from:
  // users/{uid}/favorites/{propertyId}
  Stream<List<Map<String, dynamic>>> userFavoritesStream(String uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            final rawImages = data["images"];
            List<String> images;
            if (rawImages is List) {
              images = rawImages.map((e) => e.toString()).toList();
            } else if (rawImages is String && rawImages.isNotEmpty) {
              images = [rawImages];
            } else {
              images = [
                "https://via.placeholder.com/400x300.png?text=No+Image",
              ];
            }

            return {
              "id": data["propertyId"] ?? doc.id,
              "title": data["title"] ?? "No Title",
              "location": data["location"] ?? "",
              "value": data["value"] ?? 0,
              "bedrooms": data["bedrooms"] ?? 0,
              "bathrooms": data["bathrooms"] ?? 0,
              "images": images,
              "ownerId": data["ownerId"] ?? "",
              "createdAt": data["createdAt"],
            };
          }).toList();
        });
  }

  // Check if a specific property is in the user's favorites
  Future<bool> isFavorite(String uid, String propertyId) async {
    final favRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(propertyId);

    final snap = await favRef.get();
    return snap.exists;
  }

  // Add or remove a favorite for the current user
  Future<void> setFavorite({
    required String uid,
    required Map<String, dynamic> property,
    required bool makeFavorite,
  }) async {
    final favRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(property["id"] as String);

    if (makeFavorite) {
      await favRef.set({
        "propertyId": property["id"],
        "title": property["title"],
        "location": property["location"],
        "value": property["value"],
        "bedrooms": property["bedrooms"],
        "bathrooms": property["bathrooms"],
        "images": property["images"],
        "ownerId": property["ownerId"],
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await favRef.delete();
    }
  }
}
