// screens/chat_screen.dart
// 1-on-1 chat view with usernames + avatars loaded from Firestore.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  String otherName = "";
  String otherAvatar = "";

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.otherUserId)
        .get();

    setState(() {
      otherName = doc["name"] ?? "User";
      otherAvatar = doc["avatar"] ?? "";
    });
  }

  Future<void> _send() async {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    msgController.clear();

    final msgRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages");

    await msgRef.add({
      "text": text,
      "senderId": uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection("chats").doc(widget.chatId).update({
      "lastMessage": text,
      "lastTimestamp": FieldValue.serverTimestamp(),
    });

    _scrollToEnd();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: otherAvatar.isNotEmpty
                  ? NetworkImage(otherAvatar)
                  : null,
              child: otherAvatar.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Text(otherName),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(widget.chatId)
                  .collection("messages")
                  .orderBy("timestamp")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snap.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToEnd(),
                );

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  children: msgs.map((doc) {
                    final msg = doc.data() as Map<String, dynamic>;
                    final mine = msg["senderId"] == uid;

                    final ts = (msg["timestamp"] as Timestamp?)?.toDate();
                    final time = ts == null
                        ? ""
                        : "${ts.hour}:${ts.minute.toString().padLeft(2, "0")}";

                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: mine ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: mine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["text"],
                              style: TextStyle(
                                fontSize: 16,
                                color: mine ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: mine ? Colors.white70 : Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: const InputDecoration(
                        hintText: "Message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
