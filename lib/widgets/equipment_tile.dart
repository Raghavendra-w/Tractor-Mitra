import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/equipment_model.dart';

class EquipmentTile extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback onChanged;

  const EquipmentTile({
    super.key,
    required this.equipment,
    required this.onChanged,
  });

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      equipment.imageBytes = await picked.readAsBytes();
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: equipment.selected,
                  onChanged: (val) {
                    equipment.selected = val!;
                    onChanged();
                  },
                ),
                Expanded(
                  child: Text(
                    equipment.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.image), onPressed: pickImage),
              ],
            ),

            if (equipment.selected) ...[
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price per hour (₹)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  equipment.price = int.tryParse(val) ?? 0;
                },
              ),

              const SizedBox(height: 8),

              if (equipment.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    equipment.imageBytes!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
