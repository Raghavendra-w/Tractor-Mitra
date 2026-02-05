import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool notificationsEnabled = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (OwnerSession.ownerId == null) return;

    try {
      final data = await ApiService.getPreferences(OwnerSession.ownerId!);

      setState(() {
        notificationsEnabled = data['notifications'] ?? true;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _update(bool value) async {
    setState(() => notificationsEnabled = value);

    await ApiService.updatePreferences(
      ownerId: OwnerSession.ownerId!,
      notifications: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Preferences")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SwitchListTile(
              title: const Text("Enable Notifications"),
              value: notificationsEnabled,
              onChanged: _update,
            ),
    );
  }
}
