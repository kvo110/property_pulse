// screens/home_screen.dart
// Home page displaying Firestore-powered listings with multi-image support
// and filter sorting that doesn't call setState during build.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import 'details_screen.dart';
import 'my_tours_screen.dart'; // <-- NEW: Buyer tour list screen

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

  // Helper to safely grab the first image from the list
  String _firstImage(Map<String, dynamic> property) {
    final rawImages = property["images"];

    if (rawImages is List && rawImages.isNotEmpty) {
      return rawImages.first.toString();
    }

    if (property["image"] != null) {
      return property["image"].toString();
    }

    return "https://via.placeholder.com/400x300.png?text=No+Image";
  }

  void applyFilter(String filter) {
    setState(() {
      if (activeFilter == filter) {
        activeFilter = null;
      } else {
        activeFilter = filter;
      }
    });
  }

  void _sortFilteredHouses() {
    if (activeFilter == null) return;

    if (activeFilter == "Price") {
      filteredHouses.sort((a, b) => a["value"].compareTo(b["value"]));
    } else if (activeFilter == "Bedrooms") {
      filteredHouses.sort((a, b) => b["bedrooms"].compareTo(a["bedrooms"]));
    } else if (activeFilter == "Bathrooms") {
      filteredHouses.sort((a, b) => b["bathrooms"].compareTo(a["bathrooms"]));
    }
  }

  // Horizontal card — FIXED OVERFLOW
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
          mainAxisSize: MainAxisSize.min, // <-- FIX
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                _firstImage(property),
                width: 260,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min, // <-- FIX
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

  // Vertical card (no overflow issue)
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
                _firstImage(property),
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

  // NEW — My Tours button
  Widget _myToursCard() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyToursScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "My Scheduled Tours",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
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

          // Apply sorting without setState
          _sortFilteredHouses();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NEW — Buyer Shortcut
                _myToursCard(),

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
                    return ActionChip(
                      label: Text(
                        filter,
                        style: TextStyle(color: theme.colorScheme.onSurface),
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
