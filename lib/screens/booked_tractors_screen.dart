import 'package:flutter/material.dart';

class BookedTractorsScreen extends StatelessWidget {
  const BookedTractorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: const Center(child: Text("Booked tractors list will appear here")),
    );
  }
}
