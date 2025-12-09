// screens/add_property_screen.dart
// Allows users to create new property listings and save them to Firestore.
// Note: this screen sits inside the bottom nav as a tab, so we do not pop the route.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final valueController = TextEditingController();
  final bedsController = TextEditingController();
  final bathsController = TextEditingController();
  final imageController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    valueController.dispose();
    bedsController.dispose();
    bathsController.dispose();
    imageController.dispose();
    super.dispose();
  }

  // Saves the new listing to Firestore
  Future<void> saveProperty() async {
    // Simple validation for required fields
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        valueController.text.isEmpty ||
        bedsController.text.isEmpty ||
        bathsController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill out all required fields")),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("properties").add({
        "title": titleController.text.trim(),
        "location": locationController.text.trim(),
        "value": int.tryParse(valueController.text.trim()) ?? 0,
        "bedrooms": int.tryParse(bedsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathsController.text.trim()) ?? 0,
        "image": imageController.text.trim().isEmpty
            ? "https://via.placeholder.com/400x300.png?text=No+Image"
            : imageController.text.trim(),
        "ownerId": uid,
        "createdAt": DateTime.now(),
      });

      if (!mounted) return;

      // Clear the form so it feels like a fresh state
      titleController.clear();
      locationController.clear();
      valueController.clear();
      bedsController.clear();
      bathsController.clear();
      imageController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing Created")));

      // Important: we do NOT Navigator.pop here because this screen is part
      // of the bottom nav tab system, not a pushed route.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Listing")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField("Title", titleController),
            const SizedBox(height: 12),

            inputField("Location", locationController),
            const SizedBox(height: 12),

            inputField("Price", valueController, type: TextInputType.number),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: inputField(
                    "Bedrooms",
                    bedsController,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: inputField(
                    "Bathrooms",
                    bathsController,
                    type: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            inputField("Image URL (optional)", imageController),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProperty,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save Listing"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
