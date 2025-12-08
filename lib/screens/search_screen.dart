// screens/search_screen.dart
// Search + filter screen (Week 2 feature)
// Updated so all cards + text respond correctly to theme mode

import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../providers/demo_houses.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Filter values
  RangeValues priceRange = const RangeValues(50000, 2000000);
  String? bedrooms;
  String? bathrooms;
  String? propertyType;
  String city = "";
  String stateText = "";
  bool isGridView = true;

  // Options for dropdowns
  final List<String> bedOptions = ["1", "2", "3", "4", "5+"];
  final List<String> bathOptions = ["1", "1.5", "2", "2.5", "3+"];
  final List<String> propertyTypes = [
    "House",
    "Condo",
    "Townhome",
    "Multi-Family",
  ];

  // Demo placeholder
  final List<Map<String, dynamic>> placeholderHouses = demoHouses;

  // Theme-aware card builder
  Widget buildPropertyCard(Map<String, dynamic> property) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(property: property)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                property["image"],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Text(
                property["title"],
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                property["location"],
                style: TextStyle(color: textColor?.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Scaffold(
      appBar: AppBar(title: const Text("Search Filters")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Price Range",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
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

            Text(
              "Bedrooms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            DropdownButton<String>(
              hint: Text("Select Bedrooms", style: TextStyle(color: textColor)),
              value: bedrooms,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              items: bedOptions.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: textColor)),
                );
              }).toList(),
              onChanged: (val) => setState(() => bedrooms = val),
            ),

            const SizedBox(height: 20),

            Text(
              "Bathrooms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            DropdownButton<String>(
              hint: Text(
                "Select Bathrooms",
                style: TextStyle(color: textColor),
              ),
              value: bathrooms,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              items: bathOptions.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: textColor)),
                );
              }).toList(),
              onChanged: (val) => setState(() => bathrooms = val),
            ),

            const SizedBox(height: 20),

            Text(
              "Property Type",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            DropdownButton<String>(
              hint: Text(
                "Select Property Type",
                style: TextStyle(color: textColor),
              ),
              value: propertyType,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              items: propertyTypes.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: textColor)),
                );
              }).toList(),
              onChanged: (val) => setState(() => propertyType = val),
            ),

            const SizedBox(height: 20),

            Text(
              "City",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter city",
                hintStyle: TextStyle(color: textColor?.withOpacity(0.6)),
              ),
              onChanged: (val) => city = val,
            ),

            const SizedBox(height: 20),

            Text(
              "State",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter state",
                hintStyle: TextStyle(color: textColor?.withOpacity(0.6)),
              ),
              onChanged: (val) => stateText = val,
            ),

            const SizedBox(height: 20),

            // Buttons
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

            // Results title + switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Results",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => isGridView = !isGridView),
                  icon: Icon(
                    isGridView ? Icons.grid_view : Icons.view_list,
                    color: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Grid or List view
            if (isGridView)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: placeholderHouses.map(buildPropertyCard).toList(),
              )
            else
              Column(
                children: placeholderHouses.map(buildPropertyCard).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
