import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';

class MyTractorsScreen extends StatefulWidget {
  const MyTractorsScreen({super.key});

  @override
  State<MyTractorsScreen> createState() => _MyTractorScreenState();
}

class _MyTractorScreenState extends State<MyTractorsScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===============================
  // CONTROLLERS
  // ===============================
  final nameController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final regController = TextEditingController();
  final chassisController = TextEditingController();
  final priceController = TextEditingController();

  // ===============================
  // DROPDOWNS / SWITCHES
  // ===============================
  String vehicleType = "tractor";
  String priceUnit = "hour";
  bool insured = false;
  bool available = true;

  // ===============================
  // IMAGE
  // ===============================
  XFile? image;
  Uint8List? imageBytes;

  bool loading = false;

  // ===============================
  // 📸 PICK IMAGE
  // ===============================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      image = picked;
      imageBytes = await picked.readAsBytes();
      setState(() {});
    }
  }

  // ===============================
  // ➕ SUBMIT VEHICLE (FIXED)
  // ===============================
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

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await ApiService.addTractorWithImage(
        ownerId: OwnerSession.ownerId!,
        name: nameController.text.trim(),
        category: vehicleType,
        model: modelController.text.trim(),
        year: yearController.text.isEmpty
            ? DateTime.now().year
            : int.parse(yearController.text),
        registrationNumber: regController.text.trim(),
        chassisNumber: chassisController.text.trim(),
        insured: insured,
        pricePerHour: int.parse(priceController.text),
        available: available,
        image: image, // ✅ IMAGE STILL SUPPORTED
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 SESSION GUARD
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

    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// =========================
              /// 📸 IMAGE PICKER
              /// =========================
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageBytes == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40),
                              SizedBox(height: 8),
                              Text("Upload Vehicle Photo"),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: vehicleType,
                items: const [
                  DropdownMenuItem(value: "tractor", child: Text("Tractor")),
                  DropdownMenuItem(
                    value: "harvester",
                    child: Text("Harvester"),
                  ),
                  DropdownMenuItem(value: "jcb", child: Text("JCB")),
                ],
                onChanged: (val) => setState(() => vehicleType = val!),
                decoration: const InputDecoration(labelText: "Vehicle Type"),
              ),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Vehicle Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: "Model"),
              ),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Year"),
              ),

              TextFormField(
                controller: regController,
                decoration: const InputDecoration(
                  labelText: "Registration Number",
                ),
              ),

              TextFormField(
                controller: chassisController,
                decoration: const InputDecoration(labelText: "Chassis Number"),
              ),

              SwitchListTile(
                title: const Text("Insured"),
                value: insured,
                onChanged: (v) => setState(() => insured = v),
              ),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost (₹)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              SwitchListTile(
                title: const Text("Available for Booking"),
                value: available,
                onChanged: (v) => setState(() => available = v),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Add Vehicle"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
