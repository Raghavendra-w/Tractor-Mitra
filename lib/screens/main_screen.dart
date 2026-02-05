import 'package:flutter/material.dart';

import 'vehicle_categories_screen.dart';
import 'my_bookings_screen.dart';
import 'my_tractors_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ✅ SCREENS MUST MATCH TAB COUNT
  final List<Widget> _screens = const [
    VehicleCategoriesScreen(), // Home
    MyBookingsScreen(), // Bookings
    MyTractorsScreen(), // Owner Tractors
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      // ✅ FIXED BOTTOM NAV (3 TABS ONLY)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture_outlined),
            label: "My Tractors",
          ),
        ],
      ),
    );
  }
}
