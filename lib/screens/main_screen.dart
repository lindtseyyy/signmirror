import 'package:flutter/material.dart';
import 'package:signmirror_flutter/screens/dashboard_screen.dart';
import 'package:signmirror_flutter/screens/dictionary_screen.dart';
import 'package:signmirror_flutter/screens/lessons_screen.dart';
import 'package:signmirror_flutter/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // The "State"

  // 1. List of your separate Page widgets
  static const List<Widget> _pages = [
    DashboardScreen(),
    LessonsScreen(),
    DictionaryScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 75,
        selectedIndex:
            _selectedIndex, // Notice it's 'selectedIndex', not 'currentIndex'
        onDestinationSelected:
            _onItemTapped, // Notice it's 'onDestinationSelected', not 'onTap'
        // --- STYLING ---
        indicatorColor: const Color(
          0xff2D68FF,
        ).withValues(alpha: 0.1), // The "pill" background
        backgroundColor: Color(
          0xff304166,
        ), // Or your card color Color(0xff2A2C41)
        elevation: 2,

        // Controls if labels show for all, none, or only selected
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: 'Dictionary',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
