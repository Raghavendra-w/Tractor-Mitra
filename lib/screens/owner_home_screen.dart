import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text("Owner Dashboard Overview", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
