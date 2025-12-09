// screens/edit_property_screen.dart
// Screen for editing an existing property listing.

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
  late TextEditingController imageController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields with existing property data
    titleController = TextEditingController(
      text: widget.property["title"]?.toString() ?? "",
    );
    locationController = TextEditingController(
      text: widget.property["location"]?.toString() ?? "",
    );
    valueController = TextEditingController(
      text: widget.property["value"]?.toString() ?? "",
    );
    bedsController = TextEditingController(
      text: widget.property["bedrooms"]?.toString() ?? "",
    );
    bathsController = TextEditingController(
      text: widget.property["bathrooms"]?.toString() ?? "",
    );
    imageController = TextEditingController(
      text: widget.property["image"]?.toString() ?? "",
    );
  }

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

    setState(() => isLoading = true);

    try {
      final propertyProvider = Provider.of<PropertyProvider>(
        context,
        listen: false,
      );

      final id = widget.property["id"] as String;

      await propertyProvider.updateProperty(id, {
        "title": titleController.text.trim(),
        "location": locationController.text.trim(),
        "value": int.tryParse(valueController.text.trim()) ?? 0,
        "bedrooms": int.tryParse(bedsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathsController.text.trim()) ?? 0,
        "image": imageController.text.trim().isEmpty
            ? "https://via.placeholder.com/400x300.png?text=No+Image"
            : imageController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing updated")));

      // Go back to details screen and tell it the update succeeded
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

  @override
  Widget build(BuildContext context) {
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

            const SizedBox(height: 12),

            _inputField("Image URL", imageController),
            const SizedBox(height: 20),

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
