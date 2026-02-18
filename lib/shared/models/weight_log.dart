class WeightLog {
  final String? id;
  final String userId;
  final double weightKg;
  final DateTime? createdAt;

  WeightLog({
    this.id,
    required this.userId,
    required this.weightKg,
    this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'weight_kg': weightKg,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
