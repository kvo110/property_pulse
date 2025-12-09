// providers/property_provider.dart
// Handles pulling property listings from Firestore and formatting them for the UI.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  final CollectionReference propertiesRef = FirebaseFirestore.instance
      .collection("properties");

  // Converts Firestore snapshots → List<Map<String, dynamic>>
  Stream<List<Map<String, dynamic>>> allPropertiesStream() {
    return propertiesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          "id": doc.id, // keep ID for editing/deleting later
          "title": data["title"] ?? "No Title",
          "location": data["location"] ?? "",
          "value": data["value"] ?? 0,
          "bedrooms": data["bedrooms"] ?? 0,
          "bathrooms": data["bathrooms"] ?? 0,
          "image":
              data["image"] ??
              "https://via.placeholder.com/400x300.png?text=No+Image",
        };
      }).toList();
    });
  }
}
