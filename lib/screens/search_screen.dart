// screens/search_screen.dart
// Search + filter screen placeholder (Week 2 feature).

import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  RangeValues priceRange = const RangeValues(0, 99999999);
  String? bedrooms;
  String? bathrooms;

  // Bedroom/Bathroom options
  final List<String> bedOptions = ["1", "2", "3", "4", "5+"];
  final List<String> bathOptions = ["1", "1.5", "2", "2.5", "3+"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Filters")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Price Range Slider
            const Text(
              "Price Range",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RangeSlider(
              values: priceRange,
              min: 50000,
              max: 2000000,
              divisions: 50,
              labels: RangeLabels(
                "\$${priceRange.start.toInt()}",
                "\$${priceRange.end.toInt()}",
              ),
              onChanged: (values) {
                setState(() => priceRange = values);
              },
            ),

            const SizedBox(height: 20),

            // Bedrooms filter
            const Text(
              "Bedrooms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text("Select Bedrooms"),
              value: bedrooms,
              isExpanded: true,
              items: bedOptions.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) => setState(() => bedrooms = val),
            ),

            const SizedBox(height: 20),

            // Bathrooms filter
            const Text(
              "Bathrooms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text("Select Bathrooms"),
              value: bathrooms,
              isExpanded: true,
              items: bathOptions.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) => setState(() => bathrooms = val),
            ),
          ],
        ),
      ),
    );
  }
}
