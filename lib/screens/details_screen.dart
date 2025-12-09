// screens/details_screen.dart
// Supports multiple images, favorites, edit/delete, and now Message Seller.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/property_provider.dart';
import 'edit_property_screen.dart';
import 'chat_screen.dart';

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

    final rawImages = widget.property["images"];
    if (rawImages is List && rawImages.isNotEmpty) {
      images = rawImages.map((e) => e.toString()).toList();
    } else {
      images = [
        widget.property["image"] ??
            "https://via.placeholder.com/400x300.png?text=No+Image",
      ];
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
    if (currentUserId == null) return;

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
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Listing"),
        content: const Text("This action cannot be undone."),
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
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<PropertyProvider>(context, listen: false);
    await provider.deleteProperty(widget.property["id"]);

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ⭐ START CHAT FEATURE
  Future<void> _startChat() async {
    final sellerId = widget.property["ownerId"];
    final buyerId = FirebaseAuth.instance.currentUser?.uid;

    if (buyerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in to chat")));
      return;
    }

    if (buyerId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't message yourself")),
      );
      return;
    }

    // Generate chat ID that stays consistent
    final sorted = [buyerId, sellerId]..sort();
    final chatId = "${sorted[0]}_${sorted[1]}";

    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    if (!(await chatRef.get()).exists) {
      await chatRef.set({
        "participants": [buyerId, sellerId],
        "lastMessage": "",
        "lastTimestamp": FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: chatId, otherUserId: sellerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property["title"]),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
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
          children: [
            // Images
            SizedBox(
              height: 260,
              child: PageView.builder(
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

                  const SizedBox(height: 10),
                  Text(
                    widget.property["location"],
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      Text(
                        "\$${widget.property["value"]}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

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

                  const SizedBox(height: 25),

                  // ⭐ Message Seller Button
                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text("Message Seller"),
                        onPressed: _startChat,
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

  Widget _infoBox(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
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
