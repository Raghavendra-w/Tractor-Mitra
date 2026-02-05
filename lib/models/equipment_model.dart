import 'dart:typed_data';

class EquipmentModel {
  final String name;
  int price;
  Uint8List? imageBytes;
  bool selected;

  EquipmentModel({
    required this.name,
    this.price = 0,
    this.imageBytes,
    this.selected = false,
  });
}
