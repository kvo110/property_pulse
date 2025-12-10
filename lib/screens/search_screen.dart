// screens/search_screen.dart
// Search + filter screen using live Firestore listings via PropertyProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import 'details_screen.dart';

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
  final List<String> propertyTypes = const [
    "House",
    "Condo",
    "Townhome",
    "Multi-Family",
  ];

  // Theme-aware card builder for search results
  Widget buildPropertyCard(Map<String, dynamic> property) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;

    final images = property["images"] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty
        ? images.first.toString()
        : "https://via.placeholder.com/400x300.png?text=No+Image";

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
          mainAxisSize: MainAxisSize.min, // let the content shrink if needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 120, // slightly shorter to avoid overflow in grid
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Wrap ListTile in Flexible so it does not force extra height
            Flexible(
              child: ListTile(
                dense: true,
                // dense list tile keeps vertical height smaller
                minVerticalPadding: 4,
                title: Text(
                  property["title"] ?? "Listing",
                  style: TextStyle(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  property["location"] ?? "",
                  style: TextStyle(color: textColor?.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  "\$${property["value"]}",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilters(Map<String, dynamic> p) {
    final int price = p["value"] is int
        ? p["value"] as int
        : int.tryParse("${p["value"]}") ?? 0;
    final int beds = p["bedrooms"] is int
        ? p["bedrooms"] as int
        : int.tryParse("${p["bedrooms"]}") ?? 0;
    final int bathsInt = p["bathrooms"] is int
        ? p["bathrooms"] as int
        : int.tryParse("${p["bathrooms"]}") ?? 0;
    final String propType = p["propertyType"]?.toString() ?? "";
    final String location = p["location"]?.toString().toLowerCase() ?? "";

    if (price < priceRange.start || price > priceRange.end) {
      return false;
    }

    if (bedrooms != null) {
      final int minBeds = bedrooms == "5+" ? 5 : int.tryParse(bedrooms!) ?? 0;
      if (beds < minBeds) return false;
    }

    if (bathrooms != null) {
      if (bathrooms == "3+") {
        if (bathsInt < 3) return false;
      } else {
        final double target = double.tryParse(bathrooms!) ?? 0;
        if (bathsInt.toDouble() < target) return false;
      }
    }

    if (propertyType != null && propertyType!.isNotEmpty) {
      if (!propType.toLowerCase().contains(propertyType!.toLowerCase())) {
        return false;
      }
    }

    if (city.isNotEmpty && !location.contains(city.trim().toLowerCase())) {
      return false;
    }

    if (stateText.isNotEmpty &&
        !location.contains(stateText.trim().toLowerCase())) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Filters")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyProvider.allPropertiesStream(),
        builder: (context, snapshot) {
          final allProps = snapshot.data ?? [];
          final filteredProps = allProps.where(_matchesFilters).toList();

          return SingleChildScrollView(
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
                  hint: Text(
                    "Select Bedrooms",
                    style: TextStyle(color: textColor),
                  ),
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
                  onChanged: (val) => setState(() => city = val),
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
                  onChanged: (val) => setState(() => stateText = val),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Filters are applied live via _matchesFilters
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Results (${filteredProps.length})",
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

                if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (filteredProps.isEmpty)
                  const Text("No results match these filters.")
                else if (isGridView)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // make grid tiles taller so the column has enough vertical room
                    childAspectRatio: 0.6,
                    children: filteredProps.map(buildPropertyCard).toList(),
                  )
                else
                  Column(
                    children: filteredProps.map(buildPropertyCard).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
