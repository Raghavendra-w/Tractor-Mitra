class Tractor {
  final int id;
  final String name;
  final int pricePerHour;
  final bool available;

  Tractor({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.available,
  });

  factory Tractor.fromJson(Map<String, dynamic> json) {
    return Tractor(
      id: json['id'],
      name: json['name'],
      pricePerHour: json['price_per_hour'],
      available: json['available'] ?? true, // ✅ FIX
    );
  }
}
