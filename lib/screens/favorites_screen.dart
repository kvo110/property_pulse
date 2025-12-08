// screens/favorites_screen.dart
// Displays all favorited properties
// Updated to support dark/light theme colors so UI stays consistent

import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../providers/favorites.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // helper so cards match current theme mode automatically
  Color _cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2D32)
        : Colors.grey.shade200;
  }

  // helper for subtitles in dark mode
  Color _subtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade700;
  }

  // Vertical favorite card
  Widget buildFavoriteCard(Map<String, dynamic> property, int index) {
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
          color: _cardColor(context), // theme-aware background
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
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              subtitle: Text(
                property["location"],
                style: TextStyle(color: _subtitleColor(context)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  setState(() {
                    favoriteHouses.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Removed from favorites")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favoriteHouses.isEmpty
            ? Center(
                child: Text(
                  "No favorited properties yet",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Favorites",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView.builder(
                      itemCount: favoriteHouses.length,
                      itemBuilder: (context, index) {
                        return buildFavoriteCard(favoriteHouses[index], index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
