// providers/property_provider.dart
// Handles pulling property listings from Firestore, CRUD, favorites,
// AND NOW: comparison list support.

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  final CollectionReference propertiesRef = FirebaseFirestore.instance
      .collection("properties");

  // NEW: Comparison List (max 3 properties)
  final List<Map<String, dynamic>> _comparisonList = [];

  List<Map<String, dynamic>> get comparisonList =>
      List.unmodifiable(_comparisonList);

  bool isInComparison(String propertyId) {
    return _comparisonList.any((p) => p["id"] == propertyId);
  }

  bool addToComparison(Map<String, dynamic> property) {
    if (_comparisonList.length >= 3) return false;

    if (!isInComparison(property["id"])) {
      _comparisonList.add(property);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeFromComparison(String propertyId) {
    _comparisonList.removeWhere((p) => p["id"] == propertyId);
    notifyListeners();
  }

  void clearComparison() {
    _comparisonList.clear();
    notifyListeners();
  }

  // Existing Firestore property stream
  Stream<List<Map<String, dynamic>>> allPropertiesStream() {
    return propertiesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

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
          "sqft": data["sqft"] ?? 0,
          "yearBuilt": data["yearBuilt"],
          "description": data["description"] ?? "",
          "images": images,
          "ownerId": data["ownerId"] ?? "",
          "createdAt": data["createdAt"],
        };
      }).toList();
    });
  }

  // Update & Delete property
  Future<void> updateProperty(String id, Map<String, dynamic> updates) async {
    await propertiesRef.doc(id).update(updates);
  }

  Future<void> deleteProperty(String id) async {
    await propertiesRef.doc(id).delete();
  }

  // Favorites
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
              "sqft": data["sqft"] ?? 0,
              "description": data["description"] ?? "",
              "images": images,
              "ownerId": data["ownerId"] ?? "",
              "createdAt": data["createdAt"],
            };
          }).toList();
        });
  }

  Future<bool> isFavorite(String uid, String propertyId) async {
    final favRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(propertyId);

    final snap = await favRef.get();
    return snap.exists;
  }

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
        "sqft": property["sqft"] ?? 0,
        "description": property["description"] ?? "",
        "images": property["images"],
        "ownerId": property["ownerId"],
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await favRef.delete();
    }
  }
}
