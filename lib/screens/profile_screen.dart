// screens/profile_screen.dart
// User profile/settings screen. Dark/light mode toggle included.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme_provider.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Get user details from database
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserData() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  // Dialog to update user name
  Future<void> _editNameDialog(BuildContext context, String currentName) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    TextEditingController nameController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Enter new name",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();

                if (newName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .update({"name": newName});
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
          // Dark mode switch
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),

          const SizedBox(height: 20),

          // User profile displayer
          StreamBuilder(
            stream: _getUserData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Unable to load profile data.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              final data = snapshot.data!.data()!;
              final name = data["name"] ?? "Unknown User";
              final email = data["email"] ?? "No Email";

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  // Profile details
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profile Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              _editNameDialog(context, name);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Email
                      Text(
                        "Email:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Logout button
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
