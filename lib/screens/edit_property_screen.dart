// screens/edit_property_screen.dart
// Lets owners edit an existing listing, including images, sqft, year built, and description.

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
  late TextEditingController sqftController;
  late TextEditingController yearController;
  late TextEditingController descriptionController;

  List<TextEditingController> imageControllers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.property["title"]);
    locationController = TextEditingController(
      text: widget.property["location"],
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
    sqftController = TextEditingController(
      text: widget.property["sqft"]?.toString() ?? "",
    );
    yearController = TextEditingController(
      text: widget.property["yearBuilt"]?.toString() ?? "",
    );
    descriptionController = TextEditingController(
      text: widget.property["description"] ?? "",
    );

    List<String> images = [];
    if (widget.property["images"] is List) {
      images = List<String>.from(widget.property["images"]);
    } else if (widget.property["image"] is String) {
      images = [widget.property["image"]];
    }

    if (images.isEmpty) {
      images = ["https://via.placeholder.com/400x300.png?text=No+Image"];
    }

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
    sqftController.dispose();
    yearController.dispose();
    descriptionController.dispose();
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
        bathsController.text.trim().isEmpty ||
        sqftController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

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
        "sqft": int.tryParse(sqftController.text.trim()) ?? 0,
        "yearBuilt": int.tryParse(yearController.text.trim()) ?? 0,
        "description": descriptionController.text.trim(),
        "images": images,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing updated")));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
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

            const SizedBox(height: 12),

            _inputField(
              "Square Feet",
              sqftController,
              type: TextInputType.number,
            ),

            const SizedBox(height: 12),

            _inputField(
              "Year Built",
              yearController,
              type: TextInputType.number,
            ),

            const SizedBox(height: 12),

            _inputField("Description", descriptionController, maxLines: 4),

            const SizedBox(height: 20),

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
