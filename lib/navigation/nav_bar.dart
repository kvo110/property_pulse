// navigation/nav_bar.dart
// Simple bottom nav bar that switches between the 5 main screens.
//
// Screens are just placeholders for now. We'll fill out actual features in Week 1–3.

import 'package:flutter/material.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int pageIndex = 0;

  // Order of screens matches nav bar icons
  final screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[pageIndex], // Display selected screen

      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) {
          setState(() => pageIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Messages"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
