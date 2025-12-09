// screens/details_screen.dart
// Now supports MULTIPLE IMAGES from Firestore.

import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const DetailsScreen({super.key, required this.property});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late List<String> images;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Load images list from Firestore
    images = List<String>.from(widget.property["images"]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.property["title"])),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-image carousel
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) {
                      setState(() => currentIndex = i);
                    },
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox("Bedrooms", "${widget.property["bedrooms"]}"),
                      _infoBox("Bathrooms", "${widget.property["bathrooms"]}"),
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
      width: 150,
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
