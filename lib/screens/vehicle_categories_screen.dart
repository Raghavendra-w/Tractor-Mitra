import 'package:flutter/material.dart';
import 'machine_list_screen.dart';

class VehicleCategoriesScreen extends StatelessWidget {
  const VehicleCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Machine")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _categoryTile(
            context,
            title: "Tractor",
            icon: Icons.agriculture,
            category: "tractor",
          ),
          _categoryTile(
            context,
            title: "Harvester",
            icon: Icons.grass,
            category: "harvester",
          ),
          _categoryTile(
            context,
            title: "JCB",
            icon: Icons.construction,
            category: "jcb",
          ),
          _categoryTile(
            context,
            title: "Trolley",
            icon: Icons.local_shipping,
            category: "trolley",
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String category,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),

        // 🔴 THIS WAS THE MISSING / BROKEN PART
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MachineListScreen(category: category),
            ),
          );
        },
      ),
    );
  }
}
