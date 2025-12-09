// screens/messages_screen.dart
// Shows all chat rooms the current user is part of.
// Supports: avatars, unread counts, last message preview, per-listing title.
// Updated: Timestamps now display in 12-hour AM/PM format.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  /// Returns the other participant in a 1-on-1 chat
  String _otherUser(List users, String current) {
    return users.firstWhere((uid) => uid != current);
  }

  /// Converts timestamps to 12-hour AM/PM format
  String formatTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, "0");
    final suffix = hour >= 12 ? "PM" : "AM";

    if (hour == 0) hour = 12; // Midnight → 12 AM
    if (hour > 12) hour -= 12;

    return "$hour:$minute $suffix";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final chatsRef = FirebaseFirestore.instance.collection("chats");
    final usersRef = FirebaseFirestore.instance.collection("users");

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsRef
            .where("participants", arrayContains: uid)
            .orderBy("lastTimestamp", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No conversations yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final chats = snap.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, idx) {
              final chat = chats[idx];
              final chatId = chat.id;

              final participants = List<String>.from(
                chat["participants"] ?? [],
              );
              final otherId = _otherUser(participants, uid);

              final lastMsg = chat["lastMessage"] ?? "";
              final ts = (chat["lastTimestamp"] as Timestamp?)?.toDate();

              final data = chat.data() as Map<String, dynamic>;
              final unreadCounts = (data["unreadCounts"] is Map)
                  ? Map<String, dynamic>.from(data["unreadCounts"])
                  : {};

              final unread = unreadCounts[uid] is int ? unreadCounts[uid] : 0;

              final propertyTitle = data.containsKey("propertyTitle")
                  ? data["propertyTitle"]
                  : "Listing";

              return FutureBuilder<DocumentSnapshot>(
                future: usersRef.doc(otherId).get(),
                builder: (context, userSnap) {
                  String displayName = otherId;
                  String? avatarUrl;

                  if (userSnap.hasData && userSnap.data!.exists) {
                    final u = userSnap.data!.data() as Map<String, dynamic>?;

                    if (u != null) {
                      final name = u["name"] ?? "";
                      final email = u["email"] ?? "";
                      avatarUrl = u["avatar"] ?? "";

                      displayName = name.isNotEmpty
                          ? name
                          : (email.isNotEmpty ? email : otherId);
                    }
                  }

                  return ListTile(
                    leading: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                        : const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(
                      propertyTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: Text(
                      "$displayName • $lastMsg",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (ts != null)
                          Text(
                            formatTime(ts),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        if (unread > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unread.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(chatId: chatId, otherUserId: otherId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
