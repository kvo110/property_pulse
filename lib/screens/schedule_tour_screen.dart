// screens/schedule_tour_screen.dart
// Lets a buyer request a virtual or in-person tour for a specific property,
// while preventing double-booking by checking for overlapping times.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleTourScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  // Duration of each tour (in minutes) — used for conflict detection
  static const int tourDurationMinutes = 60;

  const ScheduleTourScreen({super.key, required this.property});

  @override
  State<ScheduleTourScreen> createState() => _ScheduleTourScreenState();
}

class _ScheduleTourScreenState extends State<ScheduleTourScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _tourType = "virtual";
  final TextEditingController _noteController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // User picks a calendar date
  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // User picks a time on that date
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // This handles submitting a tour request + checking for scheduling conflicts
  Future<void> _submitRequest() async {
    // Make sure user picked something
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick a date and time")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to schedule a tour")),
      );
      return;
    }

    final buyerId = user.uid;
    final sellerId = widget.property["ownerId"];
    final propertyId = widget.property["id"] ?? "";

    // Combine date + time → full DateTime
    final scheduledStart = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // End time — 60 mins later
    final scheduledEnd = scheduledStart.add(
      Duration(minutes: ScheduleTourScreen.tourDurationMinutes),
    );

    setState(() => _isSubmitting = true);

    try {
      // 🔍 Conflict check —
      // Look for any existing tours that overlap the requested time
      final query = await FirebaseFirestore.instance
          .collection("tours")
          .where("sellerId", isEqualTo: sellerId)
          .where(
            "scheduledAt",
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              scheduledStart.subtract(const Duration(hours: 1)),
            ),
          )
          .where(
            "scheduledAt",
            isLessThanOrEqualTo: Timestamp.fromDate(
              scheduledEnd.add(const Duration(hours: 1)),
            ),
          )
          .get();

      bool hasConflict = false;

      for (var doc in query.docs) {
        final existingStart = (doc["scheduledAt"] as Timestamp).toDate();
        final existingEnd = existingStart.add(
          const Duration(minutes: ScheduleTourScreen.tourDurationMinutes),
        );

        // Overlap formula: startA < endB && startB < endA
        if (scheduledStart.isBefore(existingEnd) &&
            existingStart.isBefore(scheduledEnd)) {
          hasConflict = true;
          break;
        }
      }

      // Let user know if time is taken already
      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The seller already has a tour around this time."),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Otherwise: create the tour request
      await FirebaseFirestore.instance.collection("tours").add({
        "propertyId": propertyId,
        "propertyTitle": widget.property["title"],
        "sellerId": sellerId,
        "buyerId": buyerId,
        "scheduledAt": Timestamp.fromDate(scheduledStart),
        "tourType": _tourType,
        "note": _noteController.text.trim(),
        "status": "pending", // seller must accept/decline
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tour request sent to the seller")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  // Helpers for display
  String _formattedDate() {
    if (_selectedDate == null) return "Pick a date";
    return "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}";
  }

  String _formattedTime() {
    if (_selectedTime == null) return "Pick a time";

    final hour = _selectedTime!.hourOfPeriod == 0
        ? 12
        : _selectedTime!.hourOfPeriod;

    final minute = _selectedTime!.minute.toString().padLeft(2, "0");
    final period = _selectedTime!.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.property["title"] ?? "Listing";

    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Tour")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property title + location
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            Text(
              widget.property["location"] ?? "",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 20),

            // Tour type picker
            Text(
              "Tour Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: const Text("Virtual"),
                  selected: _tourType == "virtual",
                  onSelected: (val) {
                    if (val) setState(() => _tourType = "virtual");
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("In-Person"),
                  selected: _tourType == "in_person",
                  onSelected: (val) {
                    if (val) setState(() => _tourType = "in_person");
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Date + time picker
            Text(
              "Date & Time",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(_formattedDate()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(_formattedTime()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Optional note field
            Text(
              "Note to Seller (optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Add any preferences (virtual link, parking, etc.)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text(_isSubmitting ? "Sending..." : "Send Request"),
                onPressed: _isSubmitting ? null : _submitRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
