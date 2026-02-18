class UserProfile {
  final String? id;
  final String userId;
  final String gender;
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String activityLevel;
  final String goal;
  final double? bmr;
  final double? tdee;
  final double? targetCalories;
  final double? targetProteinG;
  final double? targetFatG;
  final double? targetCarbsG;
  final DateTime? targetDate;
  final double? weeklyWeightChange; // kg/tydzień
  final double? waterGoalMl;
  final String subscriptionTier; // 'free' | 'premium'
  final DateTime? subscriptionExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.id,
    required this.userId,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.activityLevel,
    required this.goal,
    this.bmr,
    this.tdee,
    this.targetCalories,
    this.targetProteinG,
    this.targetFatG,
    this.targetCarbsG,
    this.targetDate,
    this.weeklyWeightChange,
    this.waterGoalMl,
    this.subscriptionTier = 'free',
    this.subscriptionExpiresAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPremium =>
      subscriptionTier == 'premium' &&
      (subscriptionExpiresAt == null || subscriptionExpiresAt!.isAfter(DateTime.now()));

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      heightCm: (json['height_cm'] as num).toDouble(),
      currentWeightKg: (json['current_weight_kg'] as num).toDouble(),
      targetWeightKg: (json['target_weight_kg'] as num).toDouble(),
      activityLevel: json['activity_level'] as String,
      goal: json['goal'] as String,
      bmr: json['bmr'] != null ? (json['bmr'] as num).toDouble() : null,
      tdee: json['tdee'] != null ? (json['tdee'] as num).toDouble() : null,
      targetCalories: json['target_calories'] != null ? (json['target_calories'] as num).toDouble() : null,
      targetProteinG: json['target_protein_g'] != null ? (json['target_protein_g'] as num).toDouble() : null,
      targetFatG: json['target_fat_g'] != null ? (json['target_fat_g'] as num).toDouble() : null,
      targetCarbsG: json['target_carbs_g'] != null ? (json['target_carbs_g'] as num).toDouble() : null,
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date'] as String) : null,
      weeklyWeightChange: json['weekly_weight_change'] != null ? (json['weekly_weight_change'] as num).toDouble() : null,
      waterGoalMl: json['water_goal_ml'] != null ? (json['water_goal_ml'] as num).toDouble() : null,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      subscriptionExpiresAt:
          json['subscription_expires_at'] != null
              ? DateTime.parse(json['subscription_expires_at'] as String)
              : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'gender': gender,
      'age': age,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'target_weight_kg': targetWeightKg,
      'activity_level': activityLevel,
      'goal': goal,
      if (bmr != null) 'bmr': bmr,
      if (tdee != null) 'tdee': tdee,
      if (targetCalories != null) 'target_calories': targetCalories,
      if (targetProteinG != null) 'target_protein_g': targetProteinG,
      if (targetFatG != null) 'target_fat_g': targetFatG,
      if (targetCarbsG != null) 'target_carbs_g': targetCarbsG,
      if (targetDate != null) 'target_date': targetDate!.toIso8601String().split('T')[0],
      if (weeklyWeightChange != null) 'weekly_weight_change': weeklyWeightChange,
      if (waterGoalMl != null) 'water_goal_ml': waterGoalMl,
      'subscription_tier': subscriptionTier,
      if (subscriptionExpiresAt != null)
        'subscription_expires_at': subscriptionExpiresAt!.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? gender,
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? goal,
    double? bmr,
    double? tdee,
    double? targetCalories,
    double? targetProteinG,
    double? targetFatG,
    double? targetCarbsG,
    DateTime? targetDate,
    double? weeklyWeightChange,
    double? waterGoalMl,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetFatG: targetFatG ?? this.targetFatG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetDate: targetDate ?? this.targetDate,
      weeklyWeightChange: weeklyWeightChange ?? this.weeklyWeightChange,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
