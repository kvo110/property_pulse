// screens/my_tours_screen.dart
// Shows ALL tour requests for the logged-in BUYER:
// - Upcoming (first)
// - Past tours (separate section)
// - Tapping a tour opens chat with the seller.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class MyToursScreen extends StatefulWidget {
  const MyToursScreen({super.key});

  @override
  State<MyToursScreen> createState() => _MyToursScreenState();
}

class _MyToursScreenState extends State<MyToursScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> upcomingTours = [];
  List<Map<String, dynamic>> pastTours = [];

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("tours")
        .where("buyerId", isEqualTo: uid)
        .orderBy("scheduledAt", descending: false)
        .get();

    final now = DateTime.now();

    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> past = [];

    for (var doc in snap.docs) {
      final data = doc.data();

      final dt = (data["scheduledAt"] as Timestamp).toDate();
      final tour = {
        "id": doc.id,
        "propertyId": data["propertyId"],
        "propertyTitle": data["propertyTitle"] ?? "Listing",
        "sellerId": data["sellerId"],
        "tourType": data["tourType"],
        "scheduledAt": dt,
        "note": data["note"],
        "status": data["status"],
      };

      if (dt.isAfter(now)) {
        upcoming.add(tour);
      } else {
        past.add(tour);
      }
    }

    // Sort upcoming ascending (soonest first)
    upcoming.sort((a, b) => a["scheduledAt"].compareTo(b["scheduledAt"]));

    // Sort past descending (most recent first)
    past.sort((a, b) => b["scheduledAt"].compareTo(a["scheduledAt"]));

    setState(() {
      upcomingTours = upcoming;
      pastTours = past;
      isLoading = false;
    });
  }

  String _formatDateTime(DateTime dt) {
    final month = dt.month.toString().padLeft(2, "0");
    final day = dt.day.toString().padLeft(2, "0");
    final year = dt.year.toString();

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";

    return "$month/$day/$year • $hour:$minute $period";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "confirmed":
        return Colors.green;
      case "declined":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _openChat(String sellerId, String propertyId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final sorted = [uid, sellerId]..sort();
    final chatId = "${sorted[0]}_${sorted[1]}_$propertyId";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: chatId, otherUserId: sellerId),
      ),
    );
  }

  Widget _tourCard(Map<String, dynamic> tour) {
    final dt = tour["scheduledAt"] as DateTime;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: () => _openChat(tour["sellerId"], tour["propertyId"]),
        title: Text(
          tour["propertyTitle"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDateTime(dt),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              tour["tourType"] == "virtual" ? "Virtual Tour" : "In-Person Tour",
            ),
            if (tour["note"] != null && tour["note"].trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Note: ${tour["note"]}",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(tour["status"]).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tour["status"].toUpperCase(),
            style: TextStyle(
              color: _statusColor(tour["status"]),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("None"),
          ),
        ...items.map(_tourCard).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tours")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _section("Upcoming Tours", upcomingTours),
                  _section("Past Tours", pastTours),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
