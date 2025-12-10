// screens/add_property_screen.dart
// Allows users to create listings with multiple images, sqft, description, year built, and property type.

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
  final sqftController = TextEditingController();
  final yearController = TextEditingController();
  final descriptionController = TextEditingController();

  // Simple dropdown list for property types
  final List<String> propertyTypes = const [
    "House",
    "Condo",
    "Townhome",
    "Multi-Family",
  ];

  String? selectedPropertyType;

  // Multiple image URLs
  final List<TextEditingController> imageControllers = [
    TextEditingController(),
  ];

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    valueController.dispose();
    bedsController.dispose();
    bathsController.dispose();
    sqftController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    for (var c in imageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> saveProperty() async {
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        valueController.text.isEmpty ||
        bedsController.text.isEmpty ||
        bathsController.text.isEmpty ||
        sqftController.text.isEmpty ||
        yearController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedPropertyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill out all required fields, including property type",
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Collect any non-empty image URLs
      List<String> images = imageControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (images.isEmpty) {
        images = ["https://via.placeholder.com/400x300.png?text=No+Image"];
      }

      await FirebaseFirestore.instance.collection("properties").add({
        "title": titleController.text.trim(),
        "location": locationController.text.trim(),
        "value": int.tryParse(valueController.text.trim()) ?? 0,
        "bedrooms": int.tryParse(bedsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathsController.text.trim()) ?? 0,
        "sqft": int.tryParse(sqftController.text.trim()) ?? 0,
        "yearBuilt": int.tryParse(yearController.text.trim()) ?? 0,
        "propertyType": selectedPropertyType ?? "",
        "description": descriptionController.text.trim(),
        "images": images,
        "ownerId": uid,
        "createdAt": DateTime.now(),
      });

      if (!mounted) return;

      // Clear fields so the user can submit another listing if they want
      titleController.clear();
      locationController.clear();
      valueController.clear();
      bedsController.clear();
      bathsController.clear();
      sqftController.clear();
      yearController.clear();
      descriptionController.clear();
      selectedPropertyType = null;
      for (var c in imageControllers) {
        c.clear();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing Created")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) setState(() => isLoading = false);
  }

  Widget imageField(int index) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: imageControllers[index],
            decoration: InputDecoration(
              labelText: "Image URL ${index + 1}",
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (imageControllers.length > 1) {
              setState(() => imageControllers.removeAt(index));
            }
          },
        ),
      ],
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
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bedsController,
                    decoration: const InputDecoration(labelText: "Bedrooms"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: bathsController,
                    decoration: const InputDecoration(labelText: "Bathrooms"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: sqftController,
              decoration: const InputDecoration(labelText: "Square Feet"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: "Year Built"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // Property type dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Property Type",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedPropertyType,
              items: propertyTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select property type",
              ),
              onChanged: (val) {
                setState(() {
                  selectedPropertyType = val;
                });
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Property Images",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: List.generate(
                imageControllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: imageField(index),
                ),
              ),
            ),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  imageControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Another Image"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProperty,
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
