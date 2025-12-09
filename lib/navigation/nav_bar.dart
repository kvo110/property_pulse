// navigation/nav_bar.dart
// Bottom navigation bar for the main sections of the app.
// Each index here maps directly to a screen widget in the list.

import 'package:flutter/material.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/add_property_screen.dart';
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

  // Order of screens matches the order of destinations below
  final List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    AddPropertyScreen(), // Create tab
    FavoritesScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show whichever screen matches selected index
      body: screens[pageIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) {
          setState(() => pageIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
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
