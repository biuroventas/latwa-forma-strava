/// Proste polskie posiłki. Kalorie i makro są dla całej porcji, nie na 100 g.
class MealIdea {
  const MealIdea({
    required this.id,
    required this.kcal,
    required this.grams,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final String id;
  final double kcal;
  final double grams;
  final double protein;
  final double fat;
  final double carbs;

  String name(String languageCode) {
    final table = switch (languageCode) {
      'en' => _en,
      'uk' => _uk,
      _ => _pl,
    };
    return table[id] ?? _pl[id] ?? id;
  }

  /// Format ekranu produktu: wartości na 100 g i proponowana porcja.
  Map<String, dynamic> toProduct(String languageCode) {
    final factor = grams > 0 ? 100 / grams : 1.0;
    return {
      'name': name(languageCode),
      'barcode': 'idea:$id',
      'calories': kcal * factor,
      'proteinG': protein * factor,
      'fatG': fat * factor,
      'carbsG': carbs * factor,
      'weightG': grams,
      'source': 'idea',
    };
  }

  static List<MealIdea> forRemaining(double remainingKcal, {int limit = 3}) {
    if (remainingKcal < 150) return const [];
    final fits = _ideas.where((idea) => idea.kcal <= remainingKcal + 40).toList()
      ..sort((a, b) => (remainingKcal - a.kcal).abs().compareTo((remainingKcal - b.kcal).abs()));
    if (fits.isEmpty) return _ideas.where((idea) => idea.kcal <= 350).take(limit).toList();
    return fits.take(limit).toList();
  }
}

const _ideas = <MealIdea>[
  MealIdea(id: 'owsianka', kcal: 350, grams: 300, protein: 12, fat: 8, carbs: 55),
  MealIdea(id: 'jajecznica', kcal: 220, grams: 120, protein: 16, fat: 16, carbs: 2),
  MealIdea(id: 'kanapka', kcal: 280, grams: 90, protein: 14, fat: 8, carbs: 36),
  MealIdea(id: 'twarog', kcal: 220, grams: 200, protein: 24, fat: 4, carbs: 22),
  MealIdea(id: 'jogurt', kcal: 250, grams: 220, protein: 14, fat: 6, carbs: 34),
  MealIdea(id: 'zupa', kcal: 300, grams: 400, protein: 12, fat: 8, carbs: 40),
  MealIdea(id: 'salatka', kcal: 320, grams: 280, protein: 28, fat: 12, carbs: 18),
  MealIdea(id: 'kurczak-warzywa', kcal: 380, grams: 320, protein: 40, fat: 10, carbs: 28),
  MealIdea(id: 'makaron', kcal: 480, grams: 320, protein: 20, fat: 14, carbs: 68),
  MealIdea(id: 'kurczak-ryz', kcal: 540, grams: 400, protein: 42, fat: 10, carbs: 68),
  MealIdea(id: 'nalesniki', kcal: 420, grams: 250, protein: 16, fat: 14, carbs: 56),
  MealIdea(id: 'losos', kcal: 460, grams: 280, protein: 32, fat: 22, carbs: 28),
];

const _pl = {
  'owsianka': 'Owsianka z bananem',
  'jajecznica': 'Jajecznica z dwóch jaj',
  'kanapka': 'Kanapka z szynką',
  'twarog': 'Twaróg z owocami',
  'jogurt': 'Jogurt z płatkami',
  'zupa': 'Zupa i kromka chleba',
  'salatka': 'Sałatka z tuńczykiem',
  'kurczak-warzywa': 'Kurczak z warzywami',
  'makaron': 'Makaron z serem',
  'kurczak-ryz': 'Kurczak z ryżem',
  'nalesniki': 'Dwa naleśniki',
  'losos': 'Łosoś z ziemniakami',
};

const _en = {
  'owsianka': 'Oatmeal with banana',
  'jajecznica': 'Two-egg scramble',
  'kanapka': 'Ham sandwich',
  'twarog': 'Cottage cheese with fruit',
  'jogurt': 'Yogurt with oats',
  'zupa': 'Soup and a slice of bread',
  'salatka': 'Tuna salad',
  'kurczak-warzywa': 'Chicken with vegetables',
  'makaron': 'Pasta with cheese',
  'kurczak-ryz': 'Chicken with rice',
  'nalesniki': 'Two pancakes',
  'losos': 'Salmon with potatoes',
};

const _uk = {
  'owsianka': 'Вівсянка з бананом',
  'jajecznica': 'Яєчня з двох яєць',
  'kanapka': 'Бутерброд із шинкою',
  'twarog': 'Сир із фруктами',
  'jogurt': 'Йогурт із пластівцями',
  'zupa': 'Суп і скибка хліба',
  'salatka': 'Салат з тунцем',
  'kurczak-warzywa': 'Курка з овочами',
  'makaron': 'Макарони з сиром',
  'kurczak-ryz': 'Курка з рисом',
  'nalesniki': 'Два млинці',
  'losos': 'Лосось з картоплею',
};
