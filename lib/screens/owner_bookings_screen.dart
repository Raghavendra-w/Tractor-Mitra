import 'package:flutter/material.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        backgroundColor: Colors.green,
      ),
      body: const Center(child: Text("Owner bookings list")),
    );
  }
}
