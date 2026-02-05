import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';

class AddTractorStepperScreen extends StatefulWidget {
  const AddTractorStepperScreen({super.key});

  @override
  State<AddTractorStepperScreen> createState() =>
      _AddTractorStepperScreenState();
}

class _AddTractorStepperScreenState extends State<AddTractorStepperScreen> {
  int currentStep = 0;

  /// STEP 1 – BASIC DETAILS
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final hpController = TextEditingController();

  String condition = "Good";
  String category = "tractor";

  /// STEP 2 – PRICING
  final priceHourController = TextEditingController();
  final priceDayController = TextEditingController();

  /// STEP 3 – EQUIPMENT
  final Map<String, bool> equipment = {
    "Rotavator": false,
    "Cultivator": false,
    "Plough": false,
    "Trolley": false,
  };

  /// STEP 4 – IMAGE
  XFile? image;
  Uint8List? imageBytes;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageBytes = await picked.readAsBytes();
      setState(() => image = picked);
    }
  }

  /// FINAL SUBMIT
  Future<void> submit() async {
    if (OwnerSession.ownerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Owner not logged in")));
      return;
    }

    await ApiService.addTractorWithImage(
      name: nameController.text,
      pricePerHour: int.parse(priceHourController.text),
      ownerId: OwnerSession.ownerId!,
      category: category,
      image: image,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tractor"),
        backgroundColor: Colors.green,
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 4) {
            setState(() => currentStep++);
          } else {
            submit();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep--);
          }
        },
        steps: [
          /// STEP 1 – BASIC DETAILS
          Step(
            title: const Text("Basic Details"),
            content: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Tractor Name"),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: "Brand"),
                ),
                TextField(
                  controller: hpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Horse Power"),
                ),
                DropdownButtonFormField(
                  value: condition,
                  items: ["New", "Good", "Average"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => condition = v!,
                  decoration: const InputDecoration(labelText: "Condition"),
                ),
                DropdownButtonFormField(
                  value: category,
                  items: ["tractor", "harvester", "jcb", "trolley"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => category = v!,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
              ],
            ),
          ),

          /// STEP 2 – PRICING
          Step(
            title: const Text("Pricing"),
            content: Column(
              children: [
                TextField(
                  controller: priceHourController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price / Hour (₹)",
                  ),
                ),
                TextField(
                  controller: priceDayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price / Day (₹)",
                  ),
                ),
              ],
            ),
          ),

          /// STEP 3 – EQUIPMENT
          Step(
            title: const Text("Equipment"),
            content: Column(
              children: equipment.keys.map((key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: equipment[key],
                  onChanged: (v) => setState(() => equipment[key] = v!),
                );
              }).toList(),
            ),
          ),

          /// STEP 4 – IMAGE
          Step(
            title: const Text("Photos"),
            content: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: imageBytes == null
                      ? Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(child: Text("Tap to add image")),
                        )
                      : Image.memory(
                          imageBytes!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),

          /// STEP 5 – REVIEW
          Step(
            title: const Text("Review"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${nameController.text}"),
                Text("HP: ${hpController.text}"),
                Text("Price/hr: ₹${priceHourController.text}"),
                Text(
                  "Equipment: ${equipment.entries.where((e) => e.value).map((e) => e.key).join(', ')}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
