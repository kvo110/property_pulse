// screens/chat_screen.dart
// Full 1-on-1 chat screen with:
// - text messages
// - optional image messages via URL
// - delivered/seen indicator for your last message
// - unread counts handled in the parent chat doc.

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
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  String meName = "";
  String otherName = "";
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadNames();
    _markSeen(); // when we open, mark messages as seen for this user
  }

  @override
  void dispose() {
    msgController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    final users = FirebaseFirestore.instance.collection("users");

    final me = await users.doc(uid).get();
    final other = await users.doc(widget.otherUserId).get();

    setState(() {
      meName = me.data()?["name"] ?? me.data()?["email"] ?? "Me";
      otherName = other.data()?["name"] ?? other.data()?["email"] ?? "User";
    });
  }

  // Mark this chat as "seen" for the current user and reset their unread count.
  Future<void> _markSeen() async {
    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId);

    await chatRef.update({
      "lastSeen.$uid": FieldValue.serverTimestamp(),
      "unreadCounts.$uid": 0,
    });
  }

  // Basic text message send
  Future<void> _send() async {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    msgController.clear();

    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId);
    final msgRef = chatRef.collection("messages");

    await msgRef.add({
      "text": text,
      "imageUrl": "", // no image for normal text message
      "senderId": uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Update chat preview + unread counts
    await chatRef.update({
      "lastMessage": text,
      "lastTimestamp": FieldValue.serverTimestamp(),
      // current user has just sent the message, so no unread for them
      "unreadCounts.$uid": 0,
      // bump unread for the other user
      "unreadCounts.${widget.otherUserId}": FieldValue.increment(1),
    });

    _scroll();
  }

  // Sends an image message by asking user for a URL.
  Future<void> _sendImageByUrl() async {
    final urlController = TextEditingController();

    final url = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Send Image"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: "Image URL",
              hintText: "https://example.com/photo.jpg",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                ctx,
                urlController.text.trim().isEmpty
                    ? null
                    : urlController.text.trim(),
              ),
              child: const Text("Send"),
            ),
          ],
        );
      },
    );

    if (url == null || url.isEmpty) return;

    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId);
    final msgRef = chatRef.collection("messages");

    await msgRef.add({
      "text": "",
      "imageUrl": url,
      "senderId": uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      "lastMessage": "[Image]",
      "lastTimestamp": FieldValue.serverTimestamp(),
      "unreadCounts.$uid": 0,
      "unreadCounts.${widget.otherUserId}": FieldValue.increment(1),
    });

    _scroll();
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Bubble for each message with optional "seen" status on the last message from me
  Widget _messageBubble(
    Map<String, dynamic> msg, {
    required bool isLastFromMe,
    required DateTime? otherLastSeen,
  }) {
    final theme = Theme.of(context);
    final isMe = msg["senderId"] == uid;
    final timestamp = (msg["timestamp"] as Timestamp?)?.toDate();

    final timeText = timestamp == null
        ? ""
        : "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

    final bool seen =
        isMe &&
        isLastFromMe &&
        otherLastSeen != null &&
        timestamp != null &&
        !timestamp.isAfter(otherLastSeen);

    final bool hasImage =
        msg["imageUrl"] != null && msg["imageUrl"].toString().isNotEmpty;
    final String text = (msg["text"] ?? "").toString();

    final isDark = theme.brightness == Brightness.dark;

    final Color bubbleColor = isMe
        ? (isDark ? theme.colorScheme.primary : Colors.blue)
        : (isDark ? theme.colorScheme.surfaceVariant : Colors.grey.shade300);

    final Color textColor = isMe ? Colors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(msg["imageUrl"], fit: BoxFit.cover),
              ),
            if (hasImage && text.isNotEmpty) const SizedBox(height: 6),
            if (text.isNotEmpty)
              Text(text, style: TextStyle(color: textColor, fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    seen ? Icons.done_all : Icons.check,
                    size: 14,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId);

    return Scaffold(
      appBar: AppBar(title: Text(otherName)),

      body: Column(
        children: [
          // Chat + seen state come from here
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: chatRef.snapshots(),
              builder: (context, chatSnap) {
                if (!chatSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chatData =
                    chatSnap.data!.data() as Map<String, dynamic>? ?? {};
                final lastSeenMap =
                    (chatData["lastSeen"] as Map<String, dynamic>?) ?? {};
                final otherLastSeenTs =
                    (lastSeenMap[widget.otherUserId] as Timestamp?)?.toDate();

                return StreamBuilder<QuerySnapshot>(
                  stream: chatRef
                      .collection("messages")
                      .orderBy("timestamp")
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final msgs = snap.data!.docs;

                    // every time messages update, mark this chat as seen + scroll down
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _markSeen();
                      _scroll();
                    });

                    // find index of the last message sent by current user
                    int lastFromMeIndex = -1;
                    for (int i = msgs.length - 1; i >= 0; i--) {
                      final data = msgs[i].data() as Map<String, dynamic>;
                      if (data["senderId"] == uid) {
                        lastFromMeIndex = i;
                        break;
                      }
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      itemCount: msgs.length,
                      itemBuilder: (context, index) {
                        final msg = msgs[index].data() as Map<String, dynamic>;
                        final isLastFromMe = index == lastFromMeIndex;

                        return _messageBubble(
                          msg,
                          isLastFromMe: isLastFromMe,
                          otherLastSeen: otherLastSeenTs,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sendImageByUrl,
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: const InputDecoration(
                        hintText: "Message...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
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
