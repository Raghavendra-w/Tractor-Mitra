import 'package:flutter/material.dart';

import '../utils/owner_session.dart';
import 'owner_login_screen.dart';

import 'owner_dashboard.dart';
import 'my_tractors_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_account_screen.dart';
import 'owner_notifications_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _currentIndex = 0;

  // ✅ ALL OWNER SCREENS (MERGED)
  final List<Widget> _screens = const [
    OwnerDashboard(), // 📊 Dashboard
    MyTractorsScreen(), // 🚜 Vehicles
    OwnerBookingsScreen(), // 📅 Bookings
    OwnerAccountScreen(), // 👤 Account
    OwnerNotificationsScreen(), // 🔔 Notifications
  ];

  @override
  Widget build(BuildContext context) {
    // 🔐 HARD LOGIN GUARD (KEPT)
    if (OwnerSession.ownerId == null) {
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
          (_) => false,
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],

      /// ✅ BOTTOM NAVIGATION (FULL + STABLE)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: "Vehicles",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
        ],
      ),
    );
  }
}
