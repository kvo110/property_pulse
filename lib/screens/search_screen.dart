// screens/search_screen.dart
// Search + filter screen placeholder (Week 2 feature).
// Apply filter has no functionality currently

import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../providers/demo_houses.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
 
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  RangeValues priceRange = const RangeValues(50000, 2000000);
  String? bedrooms;
  String? bathrooms;
  String? propertyType;
  String city = "";
  String stateText = "";
  bool isGridView = true;

  // Bedroom/Bathroom options
  final List<String> bedOptions = ["1", "2", "3", "4", "5+"];
  final List<String> bathOptions = ["1", "1.5", "2", "2.5", "3+"];

  // Property type options
  final List<String> propertyTypes = [
    "House",
    "Condo",
    "Townhome",
    "Multi-Family"
  ];

  // Placeholder houses
  final List<Map<String, dynamic>> placeholderHouses = demoHouses;

  // Cards to display houses
  Widget buildPropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade200,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                property["image"],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Text(property["title"]),
              subtitle: Text(property["location"]),
            ),
          ],
        ),
      ),
    );
  }

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

            const SizedBox(height: 20),

            // Property type filter
            const Text(
              "Property Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text("Select Property Type"),
              value: propertyType,
              isExpanded: true,
              items: propertyTypes.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) => setState(() => propertyType = val),
            ),

            const SizedBox(height: 20),

            // City filter
            const Text(
              "City",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter city",
              ),
              onChanged: (val) => city = val,
            ),

            const SizedBox(height: 20),

            // State filter
            const Text(
              "State",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter state",
              ),
              onChanged: (val) => stateText = val,
            ),

            const SizedBox(height: 20),

            // Apply/Clear filters
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Filters Applied")),
                      );
                    },
                    child: const Text("Apply Filters"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        priceRange = const RangeValues(50000, 2000000);
                        bedrooms = null;
                        bathrooms = null;
                        propertyType = null;
                        city = "";
                        stateText = "";
                      });
                    },
                    child: const Text("Clear"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Property results with grid/list view
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Results",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => isGridView = !isGridView);
                  },
                  icon: Icon(
                    isGridView ? Icons.grid_view : Icons.view_list,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (isGridView)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: placeholderHouses.map((property) {
                  return buildPropertyCard(property);
                }).toList(),
              )
            else
              Column(
                children: placeholderHouses.map((property) {
                  return buildPropertyCard(property);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
