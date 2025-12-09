// screens/chat_screen.dart
// 1-on-1 real-time chat including:
// - text messages
// - image messages
// - unread counts
// - seen receipts
// - 12-hour AM/PM time formatting

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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String meName = "";
  String otherName = "";

  @override
  void initState() {
    super.initState();
    _loadNames();
    _markSeen();
  }

  @override
  void dispose() {
    msgController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  /// Convert to 12-hour AM/PM formatting
  String formatTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, "0");
    final suffix = hour >= 12 ? "PM" : "AM";

    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;

    return "$hour:$minute $suffix";
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

  Future<void> _markSeen() async {
    FirebaseFirestore.instance.collection("chats").doc(widget.chatId).update({
      "lastSeen.$uid": FieldValue.serverTimestamp(),
      "unreadCounts.$uid": 0,
    });
  }

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
      "imageUrl": "",
      "senderId": uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      "lastMessage": text,
      "lastTimestamp": FieldValue.serverTimestamp(),
      "unreadCounts.$uid": 0,
      "unreadCounts.${widget.otherUserId}": FieldValue.increment(1),
    });

    _scroll();
  }

  Future<void> _sendImageByUrl() async {
    final urlController = TextEditingController();

    final url = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              ctx,
              urlController.text.trim().isNotEmpty
                  ? urlController.text.trim()
                  : null,
            ),
            child: const Text("Send"),
          ),
        ],
      ),
    );

    if (url == null) return;

    final chatRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId);

    await chatRef.collection("messages").add({
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
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _messageBubble(
    Map<String, dynamic> msg, {
    required bool isLastFromMe,
    required DateTime? otherLastSeen,
  }) {
    final theme = Theme.of(context);
    final isMe = msg["senderId"] == uid;

    final timestamp = (msg["timestamp"] as Timestamp?)?.toDate();
    final timeText = timestamp == null ? "" : formatTime(timestamp);

    final seen =
        isMe &&
        isLastFromMe &&
        otherLastSeen != null &&
        timestamp != null &&
        !timestamp.isAfter(otherLastSeen);

    final hasImage = msg["imageUrl"] != null && msg["imageUrl"] != "";
    final text = msg["text"] ?? "";

    final bubbleColor = isMe
        ? (theme.brightness == Brightness.dark
              ? theme.colorScheme.primary
              : Colors.blue)
        : (theme.brightness == Brightness.dark
              ? theme.colorScheme.surfaceVariant
              : Colors.grey.shade300);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
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
            if (text.isNotEmpty) ...[
              if (hasImage) const SizedBox(height: 6),
              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
                if (isMe)
                  Icon(
                    seen ? Icons.done_all : Icons.check,
                    color: isMe ? Colors.white70 : Colors.black54,
                    size: 14,
                  ),
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
                final otherLastSeen =
                    (lastSeenMap[widget.otherUserId] as Timestamp?)?.toDate();

                return StreamBuilder<QuerySnapshot>(
                  stream: chatRef
                      .collection("messages")
                      .orderBy("timestamp")
                      .snapshots(),
                  builder: (context, msgSnap) {
                    if (!msgSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final msgs = msgSnap.data!.docs;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _markSeen();
                      _scroll();
                    });

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
                          otherLastSeen: otherLastSeen,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: _sendImageByUrl,
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
