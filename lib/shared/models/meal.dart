class Meal {
  final String? id;
  final String userId;
  final String name;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double? weightG;
  final String? mealType;
  final String source;
  final DateTime? createdAt;

  Meal({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.weightG,
    this.mealType,
    this.source = 'manual',
    this.createdAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      weightG: json['weight_g'] != null ? (json['weight_g'] as num).toDouble() : null,
      mealType: json['meal_type'] as String?,
      source: json['source'] as String? ?? 'manual',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'calories': calories,
      'protein_g': proteinG,
      'fat_g': fatG,
      'carbs_g': carbsG,
      if (weightG != null) 'weight_g': weightG,
      if (mealType != null) 'meal_type': mealType,
      'source': source,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
