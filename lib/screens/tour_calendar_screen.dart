// screens/tour_calendar_screen.dart
// Shows seller calendar of tour requests with ability to confirm/decline.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class TourCalendarScreen extends StatefulWidget {
  const TourCalendarScreen({super.key});

  @override
  State<TourCalendarScreen> createState() => _TourCalendarScreenState();
}

class _TourCalendarScreenState extends State<TourCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Map<String, dynamic>>> events = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  /// Load all tour requests *where current user is the seller*
  Future<void> _loadTours() async {
    final sellerId = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("tours")
        .where("sellerId", isEqualTo: sellerId)
        .get();

    final Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    for (var doc in snap.docs) {
      final data = doc.data();

      final Timestamp ts = data["scheduledAt"];
      final date = DateTime(
        ts.toDate().year,
        ts.toDate().month,
        ts.toDate().day,
      );

      if (!tempEvents.containsKey(date)) {
        tempEvents[date] = [];
      }

      tempEvents[date]!.add({
        "id": doc.id,
        "propertyTitle": data["propertyTitle"] ?? "Listing",
        "buyerId": data["buyerId"],
        "tourType": data["tourType"],
        "scheduledAt": ts.toDate(),
        "note": data["note"],
        "status": data["status"], // pending, confirmed, declined
      });
    }

    setState(() {
      events = tempEvents;
      isLoading = false;
    });
  }

  /// Helper to get events for a given day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// Confirm or decline a tour request
  Future<void> _updateStatus(String tourId, String status) async {
    await FirebaseFirestore.instance.collection("tours").doc(tourId).update({
      "status": status,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Tour $status")));

    _loadTours();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, "0");
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text("Tour Calendar")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  selectedDayPredicate: (day) =>
                      day.year == _selectedDay.year &&
                      day.month == _selectedDay.month &&
                      day.day == _selectedDay.day,
                  eventLoader: (day) => _getEventsForDay(day),
                  calendarStyle: const CalendarStyle(
                    markerSize: 6,
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // LIST OF TOURS FOR SELECTED DAY
                Expanded(
                  child: dayEvents.isEmpty
                      ? const Center(
                          child: Text(
                            "No tours scheduled for this day",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: dayEvents.length,
                          itemBuilder: (context, index) {
                            final tour = dayEvents[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tour["propertyTitle"] ?? "Listing",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "${tour["tourType"] == "virtual" ? "Virtual Tour" : "In-Person Tour"} • ${_formatTime(tour["scheduledAt"])}",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 15,
                                      ),
                                    ),

                                    if ((tour["note"] ?? "")
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          "Note: ${tour["note"]}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Status: ${tour["status"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: tour["status"] == "pending"
                                                ? Colors.orange
                                                : tour["status"] == "confirmed"
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),

                                        if (tour["status"] == "pending")
                                          Row(
                                            children: [
                                              TextButton(
                                                onPressed: () => _updateStatus(
                                                  tour["id"],
                                                  "confirmed",
                                                ),
                                                child: const Text("Confirm"),
                                              ),
                                              TextButton(
                                                onPressed: () => _updateStatus(
                                                  tour["id"],
                                                  "declined",
                                                ),
                                                child: const Text(
                                                  "Decline",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
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
  }
}
