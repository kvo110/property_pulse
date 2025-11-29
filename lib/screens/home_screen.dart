// screens/home_screen.dart
// Home page with featured properties, recent listings, and quick filter buttons
// Houses have price, bedroom, and bathroom details currently

import 'package:flutter/material.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Placeholder houses
  final List<Map<String, dynamic>> placeholderHouses = [
    {
      "title": "Modern Condo",
      "location": "Los Angeles, CA",
      "image":
          "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
      "value": 850000,
      "bedrooms": 4,
      "bathrooms": 2.5,
    },
    {
      "title": "Cozy Townhome",
      "location": "Dallas, TX",
      "image":
          "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
      "value": 420000,
      "bedrooms": 3,
      "bathrooms": 2,
    },
    {
      "title": "Suburban House",
      "location": "Phoenix, AZ",
      "image":
          "https://images.unsplash.com/photo-1507089947368-19c1da9775ae",
      "value": 610000,
      "bedrooms": 3,
      "bathrooms": 2.5,
    },
  ];

  // List for sorting
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

  // Sort logic (toggle on/off)
  void applyFilter(String filter) {
    setState(() {
      
      // Tap again to turn off
      if (activeFilter == filter) {
        activeFilter = null;
        filteredHouses = List.from(placeholderHouses);
        return;
      }

      // Turn on filter
      activeFilter = filter;
      filteredHouses = List.from(placeholderHouses);

      if (filter == "Price") {
        filteredHouses.sort((a, b) => a["value"].compareTo(b["value"]));
      } else if (filter == "Bedrooms") {
        filteredHouses
            .sort((a, b) => b["bedrooms"].compareTo(a["bedrooms"]));
      } else if (filter == "Bathrooms") {
        filteredHouses
            .sort((a, b) => b["bathrooms"].compareTo(a["bathrooms"]));
      }
    });
  }

  // Horizontal card
  Widget buildHorizontalCard(Map<String, dynamic> property) {
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
          color: Colors.grey.shade200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  Text(
                    property["location"],
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
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

  // Vertical card
  Widget buildVerticalCard(Map<String, dynamic> property) {
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
          color: Colors.grey.shade200,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                property["image"],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Text(property["title"]),
              subtitle: Text(property["location"]),
              trailing: Text(
                "\$${property["value"]}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick filters
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: quickAccessFilters.map((filter) {
                return ActionChip(
                  label: Text(filter),
                  backgroundColor: activeFilter == filter
                      ? Colors.green.shade300
                      : Colors.grey.shade200,
                  onPressed: () {
                    applyFilter(filter);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Featured Properties
            const Text(
              "Featured Properties",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: filteredHouses
                    .map((property) => buildHorizontalCard(property))
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Recent Listings
            const Text(
              "Recent Listings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Column(
              children: filteredHouses
                  .map((property) => buildVerticalCard(property))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}