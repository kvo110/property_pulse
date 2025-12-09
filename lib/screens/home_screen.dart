// screens/home_screen.dart
// Home page with featured properties, recent listings, and quick filters.
// Now using PropertyProvider + Firestore instead of hard-coded demo data.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Just keeping track of which filter is active.
  // We will sort based on this inside the StreamBuilder.
  String? activeFilter;

  final List<String> quickAccessFilters = const [
    "Price",
    "Bedrooms",
    "Bathrooms",
  ];

  // When the user taps a chip, we only update activeFilter.
  // The actual list comes from Firestore, so we rebuild and sort in build().
  void applyFilter(String filter) {
    setState(() {
      if (activeFilter == filter) {
        // tap again to turn filter off
        activeFilter = null;
      } else {
        activeFilter = filter;
      }
    });
  }

  // Horizontal card for the "Featured" section
  Widget buildHorizontalCard(Map<String, dynamic> property) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(property: property)),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                property["image"],
                width: 260,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),

            // Basic info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    property["location"],
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Est. Value: \$${property['value']}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical card for the "Recent listings" section
  Widget buildVerticalCard(Map<String, dynamic> property) {
    final theme = Theme.of(context);

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
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                property["image"],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Text(
                property["title"],
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              subtitle: Text(
                property["location"],
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Text(
                "\$${property["value"]}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyProvider.allPropertiesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading properties"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProperties = snapshot.data!;

          // Start from the full Firestore list each time
          final List<Map<String, dynamic>> filteredHouses =
              List<Map<String, dynamic>>.from(allProperties);

          // Apply sorting based on activeFilter
          if (activeFilter != null) {
            if (activeFilter == "Price") {
              filteredHouses.sort((a, b) => a["value"].compareTo(b["value"]));
            } else if (activeFilter == "Bedrooms") {
              filteredHouses.sort(
                (a, b) => b["bedrooms"].compareTo(a["bedrooms"]),
              );
            } else if (activeFilter == "Bathrooms") {
              filteredHouses.sort(
                (a, b) => b["bathrooms"].compareTo(a["bathrooms"]),
              );
            }
          }

          // If there are no listings yet, show a simple helper message
          if (filteredHouses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No properties yet. Try adding a listing from the Create tab.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick filters line
                Text(
                  "Quick Access",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  children: quickAccessFilters.map((filter) {
                    final bool isActive = activeFilter == filter;
                    return ActionChip(
                      label: Text(
                        filter,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      backgroundColor: isActive
                          ? Colors.green.shade300
                          : theme.colorScheme.surfaceVariant,
                      onPressed: () => applyFilter(filter),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Featured section
                Text(
                  "Featured Properties",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 260,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: filteredHouses
                        .map((p) => buildHorizontalCard(p))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // Recent section
                Text(
                  "Recent Listings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                Column(
                  children: filteredHouses
                      .map((p) => buildVerticalCard(p))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
