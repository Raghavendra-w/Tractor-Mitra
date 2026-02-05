import 'package:flutter/material.dart';
import 'booked_tractors_screen.dart';
import 'chat_screen.dart';
import 'live_location_screen.dart';

class FarmerProfileScreen extends StatelessWidget {
  final String farmerName;

  const FarmerProfileScreen({super.key, required this.farmerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 FARMER HEADER
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage(
                "assets/images/farmer_avatar.png",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              farmerName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 📋 BOOKED TRACTORS
            _profileTile(
              icon: Icons.list_alt,
              title: "My Booked Tractors",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookedTractorsScreen(),
                  ),
                );
              },
            ),

            // 📍 LIVE LOCATION
            _profileTile(
              icon: Icons.location_on,
              title: "Live Tractor Location",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveLocationScreen()),
                );
              },
            ),

            // 💬 CHAT
            _profileTile(
              icon: Icons.chat,
              title: "Chat with Owner",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),

            // ⚙️ SETTINGS (OPTIONAL)
            _profileTile(icon: Icons.settings, title: "Settings", onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
