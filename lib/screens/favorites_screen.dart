// screens/favorites_screen.dart
// Shows the current user's favorited listings from Firestore.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/property_provider.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Color _cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2D32)
        : Colors.grey.shade200;
  }

  Color _subtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favorites")),
        body: Center(
          child: Text(
            "Please log in to view favorites",
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      );
    }

    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: propertyProvider.userFavoritesStream(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data!;

          if (favorites.isEmpty) {
            return Center(
              child: Text(
                "No favorited properties yet",
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final property = favorites[index];
                      final images = property["images"] as List<String>;
                      final imageUrl = images.isNotEmpty
                          ? images[0]
                          : "https://via.placeholder.com/400x300.png?text=No+Image";

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
                            color: _cardColor(context),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 160,
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
                                  style: TextStyle(
                                    color: _subtitleColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
