// navigation/nav_bar.dart
// Glow V2 with underline moved higher under icons — nothing else changed.

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
  late Animation<double> _anim;

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

    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glowColor = isDark
        ? const Color.fromARGB(255, 177, 3, 207)
        : const Color.fromARGB(255, 2, 48, 197);

    return Scaffold(
      body: screens[pageIndex],

      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
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

          /// 🔥 Underline Glow (Moved Higher)
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              return Positioned(
                bottom: 14, // ⬆️ RAISED FROM 6 → now closer to icons!
                left: pageIndex * tabWidth + tabWidth * 0.2,
                child: Transform.scale(
                  scale: 0.9 + (_anim.value * 0.15),
                  child: Container(
                    width: tabWidth * 0.6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: glowColor.withOpacity(0.55 + (_anim.value * 0.25)),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.45 * _anim.value),
                          blurRadius: 12,
                          spreadRadius: 2 * _anim.value,
                        ),
                      ],
                    ),
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
