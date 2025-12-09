// navigation/nav_bar.dart
// Updated nav bar now includes a "Create" tab for adding property listings.
// Everything else stays the same so it doesn't conflict with collaborator code.

import 'package:flutter/material.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/add_property_screen.dart'; // <-- new import

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int pageIndex = 0;

  // Now includes AddPropertyScreen in the center
  final screens = const [
    HomeScreen(),
    SearchScreen(),
    AddPropertyScreen(), // <-- new "Create" tab
    FavoritesScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[pageIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) {
          setState(() => pageIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),

          // NEW “Create Listing” tab
          NavigationDestination(
            icon: Icon(Icons.add_home_outlined),
            label: "Create",
          ),

          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Messages"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
