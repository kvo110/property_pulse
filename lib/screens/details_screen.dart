// screens/details_screen.dart
// Supports multiple images, Firestore favorites, and owner edit/delete.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/property_provider.dart';
import 'edit_property_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const DetailsScreen({super.key, required this.property});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late List<String> images;
  int currentIndex = 0;

  bool isFavorite = false;
  String? currentUserId;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();

    // Always ensure images exists
    final rawImages = widget.property["images"];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages];
    } else {
      images = ["https://via.placeholder.com/400x300.png?text=No+Image"];
    }

    _initFavoriteState();
  }

  Future<void> _initFavoriteState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    currentUserId = user.uid;
    isOwner = widget.property["ownerId"] == currentUserId;

    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );

    final fav = await propertyProvider.isFavorite(
      currentUserId!,
      widget.property["id"],
    );

    if (!mounted) return;
    setState(() => isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to use favorites")),
      );
      return;
    }

    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );

    final newState = !isFavorite;
    setState(() => isFavorite = newState);

    await propertyProvider.setFavorite(
      uid: currentUserId!,
      property: widget.property,
      makeFavorite: newState,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newState ? "Added to favorites" : "Removed from favorites",
        ),
      ),
    );
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete Listing"),
          content: const Text("Are you sure? This cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );

    await propertyProvider.deleteProperty(widget.property["id"]);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property["title"]),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditPropertyScreen(property: widget.property),
                  ),
                );

                if (updated == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Listing updated")),
                  );
                }
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteListing,
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, i) {
                      return Image.network(
                        images[i],
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == i ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == i
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property["title"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.property["location"],
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      Text(
                        "\$${widget.property["value"]}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// *** FIXED OVERFLOW AREA ***
                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          "Bedrooms",
                          "${widget.property["bedrooms"]}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoBox(
                          "Bathrooms",
                          "${widget.property["bathrooms"]}",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
