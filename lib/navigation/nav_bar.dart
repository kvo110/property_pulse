// navigation/nav_bar.dart
// Adds a smooth animated glow underline under the selected tab.
// Light mode: grey glow
// Dark mode: purple glow
// No floating icons. Icons & layout unchanged.

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

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  int pageIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> screens = const [
    HomeScreen(),
    SearchScreen(),
    AddPropertyScreen(),
    FavoritesScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _tabWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / 6;
  }

  @override
  Widget build(BuildContext context) {
    final tabWidth = _tabWidth(context);

    // Pick glow color based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowColor = isDark
        ? const Color.fromARGB(255, 158, 3, 186)
        : const Color.fromARGB(255, 2, 115, 207);

    return Scaffold(
      body: screens[pageIndex],

      bottomNavigationBar: Stack(
        children: [
          NavigationBar(
            height: 65,
            selectedIndex: pageIndex,
            onDestinationSelected: (index) {
              setState(() => pageIndex = index);
              _controller.forward(from: 0);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: "Home"),
              NavigationDestination(icon: Icon(Icons.search), label: "Search"),
              NavigationDestination(
                icon: Icon(Icons.add_home_outlined),
                label: "Create",
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: "Favorites",
              ),
              NavigationDestination(icon: Icon(Icons.chat), label: "Messages"),
              NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),

          // SMOOTH GLOW UNDER SELECTED TAB
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Positioned(
                bottom: 4,
                left: pageIndex * tabWidth + tabWidth * 0.15,
                child: Container(
                  width: tabWidth * 0.7,
                  height: 4,
                  decoration: BoxDecoration(
                    color: glowColor.withOpacity(0.5 + 0.5 * _animation.value),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.4 * _animation.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
