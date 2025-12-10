// screens/compare_selector_screen.dart
// Lets user select 2–3 properties to compare before going to ComparisonScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import 'comparison_screen.dart';

class CompareSelectorScreen extends StatefulWidget {
  const CompareSelectorScreen({super.key});

  @override
  State<CompareSelectorScreen> createState() => _CompareSelectorScreenState();
}

class _CompareSelectorScreenState extends State<CompareSelectorScreen> {
  final List<String> _selectedIds = []; // <-- Track IDs
  final List<Map<String, dynamic>> _selectedProps = []; // <-- Track full maps

  void _toggleSelect(Map<String, dynamic> property) {
    final id = property["id"];

    setState(() {
      if (_selectedIds.contains(id)) {
        // remove
        final index = _selectedIds.indexOf(id);
        _selectedIds.removeAt(index);
        _selectedProps.removeAt(index);
      } else if (_selectedIds.length < 3) {
        // add
        _selectedIds.add(id);
        _selectedProps.add(property);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Properties (2–3)")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyProvider.allPropertiesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final properties = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: properties.length,
                  itemBuilder: (_, i) {
                    final p = properties[i];
                    final id = p["id"];
                    final selected = _selectedIds.contains(id);

                    return ListTile(
                      title: Text(p["title"]),
                      subtitle: Text(p["location"]),

                      // FIX: use real radio-style filled circle
                      trailing: Icon(
                        selected
                            ? Icons
                                  .radio_button_checked // filled
                            : Icons.radio_button_unchecked, // hollow
                        color: selected ? Colors.green : Colors.grey,
                        size: 28,
                      ),

                      // toggle
                      onTap: () => _toggleSelect(p),
                    );
                  },
                ),
              ),

              // Bottom button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _selectedIds.length < 2
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComparisonScreen(
                                properties: List.from(_selectedProps),
                              ),
                            ),
                          );
                        },
                  child: Text(
                    _selectedIds.length < 2
                        ? "Select at least 2"
                        : "Compare (${_selectedIds.length})",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
