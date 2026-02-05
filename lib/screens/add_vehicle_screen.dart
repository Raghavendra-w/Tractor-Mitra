import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final modelController = TextEditingController();
  final regController = TextEditingController();
  final ownerController = TextEditingController();
  final chassisController = TextEditingController();
  final costController = TextEditingController();

  String vehicleType = "Tractor";
  String year = "2024";
  String costUnit = "Per Hour";
  bool insured = true;
  bool available = true;

  XFile? image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ApiService.addTractor(
      ownerId: OwnerSession.ownerId!,
      vehicleType: vehicleType,
      model: modelController.text.trim(),
      year: year,
      registrationNumber: regController.text.trim(),
      ownerName: ownerController.text.trim(),
      chassisNumber: chassisController.text.trim(),
      insured: insured,
      price: int.parse(costController.text),
      unit: costUnit,
      available: available,
      image: image,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Vehicle"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Chip(label: Text("Active Vehicle")),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// VEHICLE TYPE
              const Text("Vehicle"),
              const SizedBox(height: 6),
              DropdownButtonFormField(
                value: vehicleType,
                items: const [
                  DropdownMenuItem(value: "Tractor", child: Text("Tractor")),
                  DropdownMenuItem(
                    value: "Harvester",
                    child: Text("Harvester"),
                  ),
                ],
                onChanged: (v) => setState(() => vehicleType = v!),
              ),

              const SizedBox(height: 16),

              /// MODEL & YEAR
              const Text("Vehicle Model & Year"),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        hintText: "Enter model",
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: year,
                      items: List.generate(
                        10,
                        (i) => DropdownMenuItem(
                          value: (2024 - i).toString(),
                          child: Text((2024 - i).toString()),
                        ),
                      ),
                      onChanged: (v) => setState(() => year = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// REGISTRATION
              const Text("Registration Number"),
              TextFormField(
                controller: regController,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              /// OWNER NAME
              const Text("Owner Name (As per RC)"),
              TextFormField(
                controller: ownerController,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              /// CHASSIS
              const Text("Chassis Number (As per RC)"),
              TextFormField(
                controller: chassisController,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              /// INSURED
              const Text("Is Your Vehicle Insured?"),
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: insured,
                    onChanged: (_) => setState(() => insured = true),
                  ),
                  const Text("Yes"),
                  Radio(
                    value: false,
                    groupValue: insured,
                    onChanged: (_) => setState(() => insured = false),
                  ),
                  const Text("No"),
                ],
              ),

              const SizedBox(height: 16),

              /// COST
              const Text("Cost"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: "₹ "),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: costUnit,
                      items: const [
                        DropdownMenuItem(
                          value: "Per Hour",
                          child: Text("Per Hour"),
                        ),
                        DropdownMenuItem(
                          value: "Per Acre",
                          child: Text("Per Acre"),
                        ),
                      ],
                      onChanged: (v) => setState(() => costUnit = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// PHOTOS
              const Text("Photos (Max size: 5MB)"),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Upload Photos"),
              ),

              const SizedBox(height: 16),

              /// AVAILABILITY
              SwitchListTile(
                title: const Text("Available for Booking"),
                subtitle: const Text(
                  "You can change vehicle visibility at any time.",
                ),
                value: available,
                onChanged: (v) => setState(() => available = v),
              ),

              const SizedBox(height: 24),

              /// ACTIONS
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
                      onPressed: submit,
                      child: const Text("Add"),
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
