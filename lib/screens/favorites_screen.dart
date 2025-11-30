// screens/favorites_screen.dart
// Displays all favorited properties
// Users can remove properties from favorites

import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../providers/favorites.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  // Vertical image list
  Widget buildFavoriteCard(Map<String, dynamic> property, int index) {
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
              title: Text(property["title"]),
              subtitle: Text(property["location"]),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  setState(() {
                    favoriteHouses.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Removed from favorites"),
                    ),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favoriteHouses.isEmpty
            ? const Center(
                child: Text(
                  "No favorited properties yet",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Favorites",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView.builder(
                      itemCount: favoriteHouses.length,
                      itemBuilder: (context, index) {
                        return buildFavoriteCard(
                          favoriteHouses[index],
                          index,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
