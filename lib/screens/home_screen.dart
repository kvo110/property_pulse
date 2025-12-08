// screens/home_screen.dart
// Home page with featured properties, recent listings, and quick filters.
// Updated so cards and text respond correctly to light/dark theme switching.

import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../providers/demo_houses.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // demo property data
  final List<Map<String, dynamic>> placeholderHouses = demoHouses;

  late List<Map<String, dynamic>> filteredHouses;
  String? activeFilter;

  final List<String> quickAccessFilters = const [
    "Price",
    "Bedrooms",
    "Bathrooms",
  ];

  @override
  void initState() {
    super.initState();
    filteredHouses = List.from(placeholderHouses);
  }

  // simple sorting logic for the filter chips
  void applyFilter(String filter) {
    setState(() {
      if (activeFilter == filter) {
        activeFilter = null;
        filteredHouses = List.from(placeholderHouses);
        return;
      }

      activeFilter = filter;
      filteredHouses = List.from(placeholderHouses);

      if (filter == "Price") {
        filteredHouses.sort((a, b) => a["value"].compareTo(b["value"]));
      } else if (filter == "Bedrooms") {
        filteredHouses.sort((a, b) => b["bedrooms"].compareTo(a["bedrooms"]));
      } else if (filter == "Bathrooms") {
        filteredHouses.sort((a, b) => b["bathrooms"].compareTo(a["bathrooms"]));
      }
    });
  }

  // horizontal property card
  Widget buildHorizontalCard(Map<String, dynamic> property) {
    final theme = Theme.of(context);

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
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface, // dynamic theme surface
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                property["image"],
                width: 260,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),

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
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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

  // vertical property card
  Widget buildVerticalCard(Map<String, dynamic> property) {
    final theme = Theme.of(context);

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
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface, // dynamic surface color
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
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

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            // filter chips update theme background dynamically
            Wrap(
              spacing: 10,
              children: quickAccessFilters.map((filter) {
                return ActionChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: activeFilter == filter
                      ? Colors.green.shade300
                      : theme.colorScheme.surfaceVariant,
                  onPressed: () => applyFilter(filter),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

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
      ),
    );
  }
}
