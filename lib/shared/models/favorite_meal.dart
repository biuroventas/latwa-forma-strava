import 'meal.dart';
import 'package:latwa_forma/core/constants/app_constants.dart';

class FavoriteMeal {
  final String? id;
  final String userId;
  final String name;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final Map<String, dynamic>? ingredients; // JSONB - lista składników
  final DateTime? createdAt;

  FavoriteMeal({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.ingredients,
    this.createdAt,
  });

  factory FavoriteMeal.fromJson(Map<String, dynamic> json) {
    return FavoriteMeal(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      ingredients: json['ingredients'] as Map<String, dynamic>?,
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
      if (ingredients != null) 'ingredients': ingredients,
    };
  }

  // Konwersja do Meal (dla szybkiego dodawania do dziennego logu)
  Meal toMeal({String? mealType, DateTime? createdAt}) {
    return Meal(
      userId: userId,
      name: name,
      calories: calories,
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
      mealType: mealType,
      source: AppConstants.mealSourceManual,
      createdAt: createdAt,
    );
  }
}
