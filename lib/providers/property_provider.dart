// providers/property_provider.dart
// Handles pulling property listings from Firestore and simple CRUD helpers.

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

        return {
          "id": doc.id,
          "title": data["title"] ?? "No Title",
          "location": data["location"] ?? "",
          "value": data["value"] ?? 0,
          "bedrooms": data["bedrooms"] ?? 0,
          "bathrooms": data["bathrooms"] ?? 0,
          "image":
              data["image"] ??
              "https://via.placeholder.com/400x300.png?text=No+Image",
          "ownerId": data["ownerId"] ?? "",
          "createdAt": data["createdAt"],
        };
      }).toList();
    });
  }

  Future<void> updateProperty(String id, Map<String, dynamic> updates) async {
    await propertiesRef.doc(id).update(updates);
  }

  Future<void> deleteProperty(String id) async {
    await propertiesRef.doc(id).delete();
  }
}
