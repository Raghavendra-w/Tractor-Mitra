import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../utils/owner_session.dart';

class AddTractorScreen extends StatefulWidget {
  const AddTractorScreen({super.key});

  @override
  State<AddTractorScreen> createState() => _AddTractorScreenState();
}

class _AddTractorScreenState extends State<AddTractorScreen> {
  // =========================
  // DROPDOWNS
  // =========================
  String vehicleType = "Tractor";
  String costUnit = "Per Hour";
  String selectedCategory = "tractor";

  final List<String> categories = ["tractor", "harvester", "jcb", "trolley"];

  // =========================
  // CONTROLLERS
  // =========================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController regController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool insured = false;
  bool available = true;

  // =========================
  // IMAGE
  // =========================
  XFile? image;
  Uint8List? imageBytes;

  bool isLoading = false;

  // =========================
  // IMAGE PICKER
  // =========================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        image = picked;
        imageBytes = bytes;
      });
    }
  }

  // =========================
  // SUBMIT (FINAL FIXED)
  // =========================
  Future<void> submit() async {
    if (OwnerSession.ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expired. Please login again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.addTractorWithImage(
        ownerId: OwnerSession.ownerId!, // 🔴 VERY IMPORTANT
        name: "$vehicleType - ${nameController.text.trim()}",
        category: selectedCategory,
        pricePerHour: int.parse(priceController.text),
        model: modelController.text.trim(),
        year: int.parse(yearController.text),
        registrationNumber: regController.text.trim(),
        chassisNumber: chassisController.text.trim(),
        insured: insured,
        available: available,
        image: image,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vehicle added successfully 🚜"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Vehicle"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: imageBytes == null
                  ? Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40),
                            SizedBox(height: 8),
                            Text("Upload Vehicle Photo"),
                          ],
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: vehicleType,
              items: const [
                DropdownMenuItem(value: "Tractor", child: Text("Tractor")),
                DropdownMenuItem(value: "JCB", child: Text("JCB")),
                DropdownMenuItem(value: "Harvester", child: Text("Harvester")),
              ],
              onChanged: (v) => setState(() => vehicleType = v!),
              decoration: const InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Vehicle Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: "Model",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Year",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: regController,
              decoration: const InputDecoration(
                labelText: "Registration Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: chassisController,
              decoration: const InputDecoration(
                labelText: "Chassis Number",
                border: OutlineInputBorder(),
              ),
            ),

            SwitchListTile(
              title: const Text("Insured"),
              value: insured,
              onChanged: (v) => setState(() => insured = v),
            ),

            SwitchListTile(
              title: const Text("Available for Booking"),
              value: available,
              onChanged: (v) => setState(() => available = v),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price Per Hour (₹)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Vehicle", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
