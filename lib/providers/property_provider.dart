// providers/property_provider.dart
// Provider that sits between the UI and PropertyService.
// Idea is to keep Firestore logic in one place and let widgets listen to this.

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/property_service.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyService _service = PropertyService();

  // If we ever want to cache properties in memory, we can use these.
  // For now they are optional and mainly here for future flexibility.
  bool _isLoading = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // Simple helper to clear any stored error text.
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // Stream of all properties in the app.
  // This is useful for the HomeScreen or SearchScreen
  // when we want a real-time list of all active listings.
  Stream<QuerySnapshot<Map<String, dynamic>>> allPropertiesStream() {
    return FirebaseFirestore.instance
        .collection("properties")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Stream of properties owned by the current user.
  // MyListingsScreen can either keep using PropertyService directly
  // or switch to this for consistency.
  Stream<QuerySnapshot<Map<String, dynamic>>> userPropertiesStream() {
    return _service.userPropertiesStream();
  }

  // Helper that calls the service to create a property.
  // Exposes loading + error so the UI can react nicely if needed.
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
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    final result = await _service.createProperty(
      title: title,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      type: type,
      city: city,
      state: state,
      description: description,
      images: images,
    );

    _isLoading = false;
    _lastError = result;
    notifyListeners();

    return result;
  }

  // Wraps the delete call as well so everything goes through the provider layer.
  Future<String?> deleteProperty(String docId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    final result = await _service.deleteProperty(docId);

    _isLoading = false;
    _lastError = result;
    notifyListeners();

    return result;
  }
}
