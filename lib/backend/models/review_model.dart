class ReviewModel {
  final int? id;
  final int tractorId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    this.id,
    required this.tractorId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tractor': tractorId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      tractorId: json['tractor'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  ReviewModel copyWith({
    int? id,
    int? tractorId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      tractorId: tractorId ?? this.tractorId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
