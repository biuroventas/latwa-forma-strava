class Ingredient {
  final String id;
  final String name;
  final double amountG; // Ilość w gramach
  final double caloriesPer100G;
  final double proteinPer100G;
  final double fatPer100G;
  final double carbsPer100G;

  Ingredient({
    required this.id,
    required this.name,
    required this.amountG,
    required this.caloriesPer100G,
    this.proteinPer100G = 0,
    this.fatPer100G = 0,
    this.carbsPer100G = 0,
  });

  // Oblicz wartości odżywcze dla danej ilości
  double get calories => (caloriesPer100G * amountG) / 100;
  double get proteinG => (proteinPer100G * amountG) / 100;
  double get fatG => (fatPer100G * amountG) / 100;
  double get carbsG => (carbsPer100G * amountG) / 100;

  Ingredient copyWith({
    String? id,
    String? name,
    double? amountG,
    double? caloriesPer100G,
    double? proteinPer100G,
    double? fatPer100G,
    double? carbsPer100G,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amountG: amountG ?? this.amountG,
      caloriesPer100G: caloriesPer100G ?? this.caloriesPer100G,
      proteinPer100G: proteinPer100G ?? this.proteinPer100G,
      fatPer100G: fatPer100G ?? this.fatPer100G,
      carbsPer100G: carbsPer100G ?? this.carbsPer100G,
    );
  }
}
