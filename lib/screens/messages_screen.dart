// screens/messages_screen.dart
// Shows all chat rooms the current user is part of.
// Now supports: per-listing threads, avatars, unread badges, and last message preview.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  String _otherUser(List participants, String current) {
    return participants.firstWhere((uid) => uid != current);
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
                chat["participants"] ?? const [],
              );
              final otherId = _otherUser(participants, uid);

              final lastMsg = chat["lastMessage"] ?? "";
              final ts = (chat["lastTimestamp"] as Timestamp?)?.toDate();
              final data = chat.data() as Map<String, dynamic>;

              final unreadMap = (data["unreadCounts"] is Map)
                  ? Map<String, dynamic>.from(data["unreadCounts"])
                  : {};

              final unread = unreadMap[uid] is int ? unreadMap[uid] : 0;

              final propertyTitle =
                  chat.data().toString().contains("propertyTitle")
                  ? (chat["propertyTitle"] ?? "Listing")
                  : "Listing";

              // We fetch the other user's profile so we can show their name + avatar
              return FutureBuilder<DocumentSnapshot>(
                future: usersRef.doc(otherId).get(),
                builder: (context, userSnap) {
                  String displayName = otherId;
                  String? avatarUrl;

                  if (userSnap.hasData && userSnap.data!.exists) {
                    final data = userSnap.data!.data() as Map<String, dynamic>?;

                    if (data != null) {
                      final name = (data["name"] as String?) ?? "";
                      final email = (data["email"] as String?) ?? "";
                      avatarUrl = (data["avatar"] as String?) ?? "";

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
                            "${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        if (unread > 0) ...[
                          const SizedBox(height: 4),
                          Container(
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
