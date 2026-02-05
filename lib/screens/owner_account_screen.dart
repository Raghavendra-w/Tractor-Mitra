import 'package:flutter/material.dart';
import '../utils/owner_session.dart';
import 'app_preferences_screen.dart';
import '../services/api_service.dart';

class OwnerAccountScreen extends StatefulWidget {
  const OwnerAccountScreen({super.key});

  @override
  State<OwnerAccountScreen> createState() => _OwnerAccountScreenState();
}

class _OwnerAccountScreenState extends State<OwnerAccountScreen> {
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();

    // ✅ UPDATED: pass ownerId correctly
    if (OwnerSession.ownerId != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.getOwnerAccount(OwnerSession.ownerId!);
      setState(() => profile = data);
    } catch (e) {
      debugPrint("Profile load failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 SESSION EXPIRED GUARD
    if (OwnerSession.ownerId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Session expired. Please login again.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // ⏳ LOADING STATE
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ SAFE FALLBACKS
    final String name = profile!['name'] ?? "Owner";
    final String mobile = profile!['mobile'] ?? "-";
    final String email = profile!['email'] ?? "-";
    final String address = profile!['address'] ?? "India";
    final String imageUrl = profile!['image'] ?? "https://i.pravatar.cc/150";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Account"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 👤 PROFILE IMAGE
            CircleAvatar(radius: 45, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(height: 12),

            /// NAME
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Vehicle Owner"),
            ),

            const SizedBox(height: 24),

            /// 📄 PERSONAL INFO
            _infoCard(icon: Icons.phone, title: "Phone Number", value: mobile),
            _infoCard(icon: Icons.email, title: "Email", value: email),
            _infoCard(
              icon: Icons.location_on,
              title: "Address",
              value: address,
            ),

            const SizedBox(height: 16),

            /// ⚙️ APP PREFERENCES
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("App Preferences"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppPreferencesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            /// 🚪 LOGOUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                OwnerSession.logout();
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  /// INFO CARD
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
