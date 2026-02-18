class GoalChallenge {
  final String? id;
  final String userId;
  final String type; // 'weight_loss', 'calorie_deficit', 'water', 'exercise', 'streak'
  final String title;
  final String description;
  final double? targetValue;
  final double? currentValue;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GoalChallenge({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.targetValue,
    this.currentValue,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory GoalChallenge.fromJson(Map<String, dynamic> json) {
    return GoalChallenge(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      targetValue: json['target_value'] != null ? (json['target_value'] as num).toDouble() : null,
      currentValue: json['current_value'] != null ? (json['current_value'] as num).toDouble() : null,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      if (targetValue != null) 'target_value': targetValue,
      if (currentValue != null) 'current_value': currentValue,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  double get progress {
    if (targetValue == null || targetValue == 0) return 0;
    if (currentValue == null) return 0;
    return (currentValue! / targetValue!).clamp(0.0, 1.0);
  }
}
