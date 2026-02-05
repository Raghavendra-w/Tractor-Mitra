class BookingModel {
  final int? id;
  final int tractorId;
  final int hours;
  final int totalPrice;
  final bool completed;
  final DateTime createdAt;

  BookingModel({
    this.id,
    required this.tractorId,
    required this.hours,
    required this.totalPrice,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tractor': tractorId,
      'hours': hours,
      'total_price': totalPrice,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int?,
      tractorId: json['tractor'] as int,
      hours: json['hours'] as int,
      totalPrice: json['total_price'] as int,
      completed: json['completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  BookingModel copyWith({
    int? id,
    int? tractorId,
    int? hours,
    int? totalPrice,
    bool? completed,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      tractorId: tractorId ?? this.tractorId,
      hours: hours ?? this.hours,
      totalPrice: totalPrice ?? this.totalPrice,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
