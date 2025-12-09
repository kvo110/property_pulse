// screens/home_screen.dart
// Home page displaying Firestore-powered listings with multi-image support.

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
  List<Map<String, dynamic>> filteredHouses = [];
  String? activeFilter;

  final List<String> quickAccessFilters = const [
    "Price",
    "Bedrooms",
    "Bathrooms",
  ];

  void applyFilter(String filter) {
    setState(() {
      if (activeFilter == filter) {
        activeFilter = null;
        return;
      }

      activeFilter = filter;

      if (filter == "Price") {
        filteredHouses.sort((a, b) => a["value"].compareTo(b["value"]));
      } else if (filter == "Bedrooms") {
        filteredHouses.sort((a, b) => b["bedrooms"].compareTo(a["bedrooms"]));
      } else if (filter == "Bathrooms") {
        filteredHouses.sort((a, b) => b["bathrooms"].compareTo(a["bathrooms"]));
      }
    });
  }

  // Horizontal card, now uses images[0]
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                property["images"][0],
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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

  // Vertical card (same update)
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                property["images"][0],
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
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyProvider.allPropertiesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          filteredHouses = List.from(snapshot.data!);

          if (activeFilter != null) applyFilter(activeFilter!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    children: filteredHouses.map(buildHorizontalCard).toList(),
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
                  children: filteredHouses.map(buildVerticalCard).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
