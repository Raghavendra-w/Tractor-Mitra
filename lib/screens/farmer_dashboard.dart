import 'package:flutter/material.dart';
import 'machine_list_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Your Vehicle"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FarmerProfileScreen(farmerName: "Varun"),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _machineCard(
            context,
            title: "Tractor",
            description: "Ideal for plowing, tilling, and planting fields.",
            icon: Icons.agriculture,
            category: "tractor",
          ),
          _machineCard(
            context,
            title: "Harvester",
            description: "Efficient for harvesting crops like wheat and rice.",
            icon: Icons.grass,
            category: "harvester",
          ),
          _machineCard(
            context,
            title: "Sugarcane Harvester",
            description: "Specialized machinery for sugarcane harvesting.",
            icon: Icons.agriculture_outlined,
            category: "harvester",
          ),
          _machineCard(
            context,
            title: "JCB",
            description: "Perfect for digging, lifting, and heavy-duty work.",
            icon: Icons.construction,
            category: "jcb",
          ),
          _machineCard(
            context,
            title: "Trolley",
            description: "Used for transporting crops and materials.",
            icon: Icons.local_shipping,
            category: "trolley",
          ),
        ],
      ),
    );
  }

  // ==========================
  // 🚜 MACHINE CARD
  // ==========================
  Widget _machineCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineListScreen(category: category),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 🔹 LEFT TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 RIGHT ICON
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.shade50,
                child: Icon(icon, size: 34, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
