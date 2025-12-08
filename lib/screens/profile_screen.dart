// screens/profile_screen.dart
// User profile/settings screen with theme-aware UI adjustments.
// This version fixes card + text colors so they adapt to light/dark mode correctly.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme_provider.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Pulls user Firestore document in real time
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserData() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  // Edit dialog for profile fields
  Future<void> _editDialog(
    BuildContext context,
    String fieldName,
    String title,
    String currentValue,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newValue = controller.text.trim();
                if (newValue.isNotEmpty || fieldName == "phoneNumber") {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .update({fieldName: newValue});
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: ListView(
        children: [
          // Theme mode toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),

          const SizedBox(height: 20),

          // User profile viewer
          StreamBuilder(
            stream: _getUserData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Unable to load profile data."),
                  ),
                );
              }

              final data = snapshot.data!.data()!;
              final name = data["name"] ?? "Unknown User";
              final email = data["email"] ?? "No Email";
              final phone = data["phoneNumber"] ?? "";

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Information",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      // Name Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name:",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editDialog(context, "name", "Name", name);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Email (non-editable)
                      Text(
                        "Email:",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 16),

                      // Phone Number Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Phone Number:",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              Text(
                                phone.isEmpty ? "Not Provided" : phone,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editDialog(
                                context,
                                "phoneNumber",
                                "Phone Number",
                                phone,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }
}
