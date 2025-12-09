// screens/edit_property_screen.dart
// Updated to support MULTIPLE IMAGES instead of a single URL.
// Users can add/remove/update image URLs dynamically.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';

class EditPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController valueController;
  late TextEditingController bedsController;
  late TextEditingController bathsController;

  // Now a LIST of image controllers
  List<TextEditingController> imageControllers = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.property["title"] ?? "",
    );
    locationController = TextEditingController(
      text: widget.property["location"] ?? "",
    );
    valueController = TextEditingController(
      text: widget.property["value"].toString(),
    );
    bedsController = TextEditingController(
      text: widget.property["bedrooms"].toString(),
    );
    bathsController = TextEditingController(
      text: widget.property["bathrooms"].toString(),
    );

    // Convert Firestore list → text controllers
    List<String> images = List<String>.from(widget.property["images"]);
    for (var url in images) {
      imageControllers.add(TextEditingController(text: url));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    valueController.dispose();
    bedsController.dispose();
    bathsController.dispose();

    for (var c in imageControllers) {
      c.dispose();
    }

    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (titleController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        valueController.text.trim().isEmpty ||
        bedsController.text.trim().isEmpty ||
        bathsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all required fields")),
      );
      return;
    }

    // Turn controller list → pure strings
    final images = imageControllers
        .map(
          (c) => c.text.trim().isEmpty
              ? "https://via.placeholder.com/400x300.png?text=No+Image"
              : c.text.trim(),
        )
        .toList();

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<PropertyProvider>(context, listen: false);

      final id = widget.property["id"];

      await provider.updateProperty(id, {
        "title": titleController.text.trim(),
        "location": locationController.text.trim(),
        "value": int.tryParse(valueController.text.trim()) ?? 0,
        "bedrooms": int.tryParse(bedsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathsController.text.trim()) ?? 0,
        "images": images, // <-- MULTIPLE IMAGES SAVED HERE
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing updated")));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating listing: $e")));
    }

    setState(() => isLoading = false);
  }

  Widget _inputField(
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

  Widget _imageField(int index) {
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
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              imageControllers.removeAt(index);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Listing")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField("Title", titleController),
            const SizedBox(height: 12),

            _inputField("Location", locationController),
            const SizedBox(height: 12),

            _inputField("Price", valueController, type: TextInputType.number),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _inputField(
                    "Bedrooms",
                    bedsController,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputField(
                    "Bathrooms",
                    bathsController,
                    type: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -----------------------------
            // MULTIPLE IMAGE INPUTS SECTION
            // -----------------------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Images",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: [
                for (int i = 0; i < imageControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _imageField(i),
                  ),
              ],
            ),

            // Add new image URL
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    imageControllers.add(TextEditingController(text: ""));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Image"),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
