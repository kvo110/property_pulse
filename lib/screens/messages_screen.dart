// screens/messages_screen.dart
// Displays user's conversations with avatars + names.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("participants", arrayContains: uid)
            .orderBy("lastTimestamp", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snap.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;

              final participants = List<String>.from(chat['participants']);
              final otherId = participants.firstWhere((p) => p != uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(otherId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const ListTile();

                  final user = userSnap.data!;
                  final name = user["name"] ?? "Unknown";
                  final avatar = user["avatar"];

                  final lastMsg = chat["lastMessage"] ?? "";
                  final ts = (chat["lastTimestamp"] as Timestamp?)?.toDate();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: avatar != null
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(name),
                    subtitle: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ts == null
                        ? null
                        : Text(
                            "${ts.hour}:${ts.minute.toString().padLeft(2, "0")}",
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
