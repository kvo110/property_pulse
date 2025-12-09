// screens/add_property_screen.dart
// Screen where a user can create a new property listing.
// This will be hooked into the bottom navigation bar as the "Create" tab.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // in case we expand later
import '../services/property_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBeds;
  String? _selectedBaths;
  String? _selectedType;

  bool _isSaving = false;

  final _bedOptions = ["1", "2", "3", "4", "5+"];
  final _bathOptions = ["1", "1.5", "2", "2.5", "3+"];
  final _propertyTypes = [
    "House",
    "Condo",
    "Townhome",
    "Multi-Family",
    "Apartment",
    "Manufactured Home",
    "Land",
    "Commercial",
  ];

  // Simple mock image URLs so we don't rely on Firebase Storage right now.
  final List<String> _mockImagePool = const [
    "https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg",
    "https://images.pexels.com/photos/259588/pexels-photo-259588.jpeg",
    "https://images.pexels.com/photos/186077/pexels-photo-186077.jpeg",
    "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg",
    "https://images.pexels.com/photos/439391/pexels-photo-439391.jpeg",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper to convert the bed string into an integer
  int _parseBedrooms(String? value) {
    if (value == null) return 0;
    if (value.contains("+")) {
      return int.tryParse(value.replaceAll("+", "")) ?? 0;
    }
    return int.tryParse(value) ?? 0;
  }

  // Helper to convert the bath string into a double
  double _parseBathrooms(String? value) {
    if (value == null) return 0;
    if (value.contains("+")) {
      return double.tryParse(value.replaceAll("+", "")) ?? 0;
    }
    return double.tryParse(value) ?? 0;
  }

  List<String> _pickMockImages() {
    // For now just take the first 3. Later we can randomize if we want.
    return _mockImagePool.take(3).toList();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBeds == null ||
        _selectedBaths == null ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select beds, baths, and type.")),
      );
      return;
    }

    final parsedPrice = int.tryParse(_priceController.text.trim());
    if (parsedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid numeric price.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final service = PropertyService();

    final error = await service.createProperty(
      title: _titleController.text.trim(),
      price: parsedPrice,
      bedrooms: _parseBedrooms(_selectedBeds),
      bathrooms: _parseBathrooms(_selectedBaths),
      type: _selectedType!,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      description: _descriptionController.text.trim(),
      images: _pickMockImages(),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Listing created successfully.")),
    );

    // Clear form after successful save
    _formKey.currentState!.reset();
    _titleController.clear();
    _priceController.clear();
    _cityController.clear();
    _stateController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedBeds = null;
      _selectedBaths = null;
      _selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Listing")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Property Details",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price (USD)"),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBeds,
                        decoration: const InputDecoration(
                          labelText: "Bedrooms",
                        ),
                        items: _bedOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBeds = val;
                          });
                        },
                        validator: (val) => val == null ? "Select beds" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBaths,
                        decoration: const InputDecoration(
                          labelText: "Bathrooms",
                        ),
                        items: _bathOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBaths = val;
                          });
                        },
                        validator: (val) => val == null ? "Select baths" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: "Property Type"),
                  items: _propertyTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? "Select a property type" : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: "City"),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: "State"),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveListing,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Create Listing"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
