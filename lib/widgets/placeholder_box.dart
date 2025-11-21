import 'package:flutter/material.dart';

class PlaceholderBox extends StatelessWidget {
  final String text;
  const PlaceholderBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
    );
  }
}
