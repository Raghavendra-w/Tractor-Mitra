import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';
import 'add_equipment_screen.dart';

class MyTractorsScreen extends StatefulWidget {
  const MyTractorsScreen({super.key});

  @override
  State<MyTractorsScreen> createState() => _MyTractorsScreenState();
}

class _MyTractorsScreenState extends State<MyTractorsScreen> {
  late Future<List<dynamic>> tractorsFuture;

  @override
  void initState() {
    super.initState();
    tractorsFuture = ApiService.getOwnerTractors(OwnerSession.ownerId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tractors"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tractorsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tractors = snapshot.data!;
          if (tractors.isEmpty) {
            return const Center(child: Text("No tractors added yet"));
          }

          return ListView.builder(
            itemCount: tractors.length,
            itemBuilder: (context, index) {
              final t = tractors[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.agriculture, color: Colors.green),
                  title: Text(t['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Model: ${t['model'] ?? '-'}"),
                      Text("HP: ${t['horsepower'] ?? '-'}"),
                      Text("₹${t['price_per_hour']} / hr"),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "add",
                        child: Text("Add Equipment"),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == "add") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEquipmentScreen(tractorId: t['id']),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
