class TractorModel {
  final int? id;
  final String name;
  final int pricePerHour;
  final bool available;
  final String? image;

  TractorModel({
    this.id,
    required this.name,
    required this.pricePerHour,
    this.available = true,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_per_hour': pricePerHour,
      'available': available,
      'image': image ?? '',
    };
  }

  factory TractorModel.fromJson(Map<String, dynamic> json) {
    return TractorModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      pricePerHour: json['price_per_hour'] as int,
      available: json['available'] as bool? ?? true,
      image: json['image'] as String?,
    );
  }

  TractorModel copyWith({
    int? id,
    String? name,
    int? pricePerHour,
    bool? available,
    String? image,
  }) {
    return TractorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      available: available ?? this.available,
      image: image ?? this.image,
    );
  }
}
