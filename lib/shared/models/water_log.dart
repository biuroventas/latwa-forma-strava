class WaterLog {
  final String? id;
  final String userId;
  final double amountMl;
  final DateTime? createdAt;

  WaterLog({
    this.id,
    required this.userId,
    required this.amountMl,
    this.createdAt,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      amountMl: (json['amount_ml'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount_ml': amountMl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
