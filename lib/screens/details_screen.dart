// screens/details_screen.dart
// Screen to display all house details

import 'package:flutter/material.dart';
import '../providers/favorites.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const DetailsScreen({super.key, required this.property});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int currentIndex = 0;
  bool isFavorited = false;

  late final List<String> images;

  @override
  void initState() {
    super.initState();

    // placeholder repeated images for now
    images = [
      widget.property["image"],
      widget.property["image"],
      widget.property["image"],
      widget.property["image"],
      widget.property["image"],
    ];

    // check if it's already favorited
    isFavorited = favoriteHouses.any(
      (house) => house["title"] == widget.property["title"],
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
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited
                  ? Colors.red
                  : theme.colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                if (isFavorited) {
                  favoriteHouses.removeWhere(
                    (house) =>
                        house["title"] == widget.property["title"],
                  );
                } else {
                  favoriteHouses.add(widget.property);
                }
                isFavorited = !isFavorited;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorited
                        ? "Added to favorites"
                        : "Removed from favorites",
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      );
                    },
                  ),

                  // little dots for carousel indicator
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == index
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    widget.property["location"],
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      Text(
                        "\$${widget.property["value"]}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox(context, "Bedrooms",
                          widget.property["bedrooms"].toString()),
                      _infoBox(context, "Bathrooms",
                          widget.property["bathrooms"].toString()),
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

  // simple box for bedrooms/bathrooms count
  Widget _infoBox(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface, // dynamic surface color
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
