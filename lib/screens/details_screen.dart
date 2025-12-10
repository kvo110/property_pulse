// screens/details_screen.dart
// Supports multiple images, favorites, edit/delete, Message Seller,
// sqft, description, Schedule Tour, AND Property Comparison,
// now with YEAR BUILT included.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/property_provider.dart';
import '../providers/comparison_manager.dart';
import 'comparison_screen.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
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

    if (mounted) Navigator.pop(context);
  }

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: chatId, otherUserId: sellerId),
      ),
    );
  }

  void _openScheduleTour() {
    final buyerId = FirebaseAuth.instance.currentUser?.uid;
    final sellerId = widget.property["ownerId"];

    if (buyerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    if (buyerId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot schedule your own listing")),
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
        ? widget.property["sqft"]
        : int.tryParse(widget.property["sqft"]?.toString() ?? "0") ?? 0;

    final int yearBuilt = (widget.property["yearBuilt"] is int)
        ? widget.property["yearBuilt"]
        : int.tryParse(widget.property["yearBuilt"]?.toString() ?? "0") ?? 0;

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditPropertyScreen(property: widget.property),
                  ),
                );
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

                  const SizedBox(height: 8),
                  Text(
                    widget.property["location"],
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "\$${widget.property["value"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (sqft > 0 || yearBuilt > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sqft > 0)
                          Row(
                            children: [
                              const Icon(Icons.square_foot, size: 20),
                              const SizedBox(width: 6),
                              Text("$sqft sqft"),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (yearBuilt > 0)
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 20),
                              const SizedBox(width: 6),
                              Text("Year Built: $yearBuilt"),
                            ],
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
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                    const SizedBox(height: 25),
                  ],

                  if (!isOwner)
                    Consumer<ComparisonManager>(
                      builder: (context, compare, _) {
                        final selected = compare.isSelected(
                          widget.property["id"],
                        );
                        final canCompare = compare.selected.length >= 2;

                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                ),
                                label: Text(
                                  selected
                                      ? "Added to Compare"
                                      : "Add to Compare",
                                ),
                                onPressed: () {
                                  compare.toggleProperty(widget.property);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        selected
                                            ? "Removed from comparison"
                                            : "Added to comparison list",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            if (canCompare) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.compare_arrows),
                                  label: const Text("Compare Now"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ComparisonScreen(
                                          properties: compare.selected,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                  if (!isOwner) const SizedBox(height: 12),

                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text("Message Seller"),
                        onPressed: _startChat,
                      ),
                    ),

                  if (!isOwner) const SizedBox(height: 10),

                  if (!isOwner)
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
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
