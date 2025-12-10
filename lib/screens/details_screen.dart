// screens/details_screen.dart
// Supports multiple images, favorites, edit/delete, Message Seller,
// sqft, description, and Schedule Tour.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/property_provider.dart';
import 'edit_property_screen.dart';
import 'chat_screen.dart';
import 'schedule_tour_screen.dart';

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

    // make sure we always have at least one image
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

  // Starts or opens chat between buyer and seller for THIS listing.
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

    final propertyId = widget.property["id"] ?? "";
    final propertyTitle = widget.property["title"] ?? "Listing";

    // Per-property thread: include property id so each listing has its own chat
    final sorted = [buyerId, sellerId]..sort();
    final chatId = "${sorted[0]}_${sorted[1]}_$propertyId";

    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    final existing = await chatRef.get();
    if (!existing.exists) {
      await chatRef.set({
        "participants": [buyerId, sellerId],
        "propertyId": propertyId,
        "propertyTitle": propertyTitle,
        "lastMessage": "",
        "lastTimestamp": FieldValue.serverTimestamp(),
        "unreadCounts": {buyerId: 0, sellerId: 0},
        "lastSeen": {buyerId: FieldValue.serverTimestamp(), sellerId: null},
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

  // Opens the schedule tour screen so the buyer can request a time.
  void _openScheduleTour() {
    final buyerId = FirebaseAuth.instance.currentUser?.uid;
    final sellerId = widget.property["ownerId"];

    if (buyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to schedule a tour")),
      );
      return;
    }

    if (buyerId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't schedule a tour with yourself"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleTourScreen(property: widget.property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int sqft = (widget.property["sqft"] is int)
        ? widget.property["sqft"] as int
        : int.tryParse(widget.property["sqft"]?.toString() ?? "0") ?? 0;

    final String description =
        (widget.property["description"]?.toString() ?? "").trim();

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
            // image carousel
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

                  const SizedBox(height: 16),

                  if (sqft > 0)
                    Row(
                      children: [
                        const Icon(Icons.square_foot, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "$sqft sqft",
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

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

                  if (description.isNotEmpty) ...[
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  if (!isOwner)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text("Message Seller"),
                            onPressed: _startChat,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event_available_outlined),
                            label: const Text("Schedule Tour"),
                            onPressed: _openScheduleTour,
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
