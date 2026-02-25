import '../constants/app_constants.dart';

class Calculations {
  /// Pobiera cel na podstawie porównania wagi aktualnej i docelowej.
  /// - waga docelowa < aktualna → schudnięcie
  /// - waga docelowa > aktualna → przytycie
  /// - waga docelowa ≈ aktualna (różnica < 0.5 kg) → utrzymanie
  static String deriveGoalFromWeights({
    required double currentWeightKg,
    required double targetWeightKg,
  }) {
    const epsilon = 0.5;
    final diff = targetWeightKg - currentWeightKg;
    if (diff < -epsilon) {
      return AppConstants.goalWeightLoss;
    }
    if (diff > epsilon) {
      return AppConstants.goalWeightGain;
    }
    return AppConstants.goalMaintain;
  }

  /// Sprawdza czy wybrany cel jest zgodny z wagami.
  static bool isGoalMatchingWeights({
    required String goal,
    required double currentWeightKg,
    required double targetWeightKg,
  }) {
    final derivedGoal = deriveGoalFromWeights(
      currentWeightKg: currentWeightKg,
      targetWeightKg: targetWeightKg,
    );
    return goal == derivedGoal;
  }
  /// Oblicza BMR (Basal Metabolic Rate) używając wzoru Harris-Benedict
  static double calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    // Wzór Harris-Benedict
    if (gender == AppConstants.genderMale) {
      // Mężczyźni: BMR = 88.362 + (13.397 × waga w kg) + (4.799 × wzrost w cm) - (5.677 × wiek w latach)
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      // Kobiety: BMR = 447.593 + (9.247 × waga w kg) + (3.098 × wzrost w cm) - (4.330 × wiek w latach)
      return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }
  }

  /// Oblicza TDEE (Total Daily Energy Expenditure) na podstawie BMR i poziomu aktywności
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    switch (activityLevel) {
      case AppConstants.activitySedentary:
        return bmr * 1.2; // Siedzący tryb życia
      case AppConstants.activityLight:
        return bmr * 1.375; // Lekka aktywność (1-3 razy w tygodniu)
      case AppConstants.activityModerate:
        return bmr * 1.55; // Umiarkowana aktywność (3-5 razy w tygodniu)
      case AppConstants.activityIntense:
        return bmr * 1.725; // Intensywna aktywność (6-7 razy w tygodniu)
      case AppConstants.activityVeryIntense:
        return bmr * 1.9; // Bardzo intensywna aktywność (2x dziennie)
      default:
        return bmr * 1.2;
    }
  }

  /// Oblicza makroskładniki na podstawie TDEE, celu i wagi docelowej
  static Map<String, double> calculateMacros({
    required double tdee,
    required String goal,
    required double targetWeightKg,
  }) {
    double targetCalories;
    double proteinG;
    double fatG;
    double carbsG;

    switch (goal) {
      case AppConstants.goalWeightLoss:
        // Utrata wagi: deficyt 500 kcal/dzień (ok. 0.5 kg/tydzień)
        targetCalories = tdee - 500;
        break;
      case AppConstants.goalWeightGain:
        // Przybranie wagi: nadwyżka 250 kcal/dzień (ok. 0.25 kg/tydzień)
        targetCalories = tdee + 250;
        break;
      case AppConstants.goalMaintain:
      default:
        // Utrzymanie wagi
        targetCalories = tdee;
        break;
    }

    // Białko: 2g na kg wagi docelowej; tłuszcze: procent z AppConstants
    var proteinCalories = targetWeightKg * AppConstants.proteinPerKg * 4;
    var fatCalories = targetCalories * AppConstants.fatPercentage;
    fatG = fatCalories / 9;
    proteinG = proteinCalories / 4;

    // Min. 50g węglowodanów (wytyczne zdrowego odżywiania)
    const minCarbsKcal = 50.0 * 4;
    final availableForPf = (targetCalories - minCarbsKcal).clamp(0.0, double.infinity);
    if (proteinCalories + fatCalories > availableForPf && availableForPf > 0) {
      final scale = availableForPf / (proteinCalories + fatCalories);
      proteinCalories *= scale;
      fatCalories *= scale;
      proteinG = proteinCalories / 4;
      fatG = fatCalories / 9;
    }
    final carbsCalories = targetCalories - proteinCalories - fatCalories;
    carbsG = (carbsCalories / 4).clamp(50.0, double.infinity);

    return {
      'calories': targetCalories,
      'protein': proteinG,
      'fat': fatG,
      'carbs': carbsG,
    };
  }

  /// Oblicza makroskładniki na podstawie docelowych kalorii (bez przeliczania TDEE).
  static Map<String, double> calculateMacrosFromCalories({
    required double targetCalories,
    required double targetWeightKg,
  }) {
    var proteinCalories = targetWeightKg * AppConstants.proteinPerKg * 4;
    var fatCalories = targetCalories * AppConstants.fatPercentage;
    var fatG = fatCalories / 9;
    var proteinG = proteinCalories / 4;
    const minCarbsKcal = 50.0 * 4;
    final availableForPf = (targetCalories - minCarbsKcal).clamp(0.0, double.infinity);
    if (proteinCalories + fatCalories > availableForPf && availableForPf > 0) {
      final scale = availableForPf / (proteinCalories + fatCalories);
      proteinCalories *= scale;
      fatCalories *= scale;
      proteinG = proteinCalories / 4;
      fatG = fatCalories / 9;
    }
    final carbsCalories = targetCalories - proteinCalories - fatCalories;
    final carbsG = (carbsCalories / 4).clamp(50.0, double.infinity);
    return {
      'calories': targetCalories,
      'protein': proteinG,
      'fat': fatG,
      'carbs': carbsG,
    };
  }

  /// Oblicza szacowany termin osiągnięcia celu
  static DateTime calculateTargetDate({
    required double currentWeight,
    required double targetWeight,
    required String goal,
  }) {
    final difference = (targetWeight - currentWeight).abs();
    
    double weeklyChange;
    switch (goal) {
      case AppConstants.goalWeightLoss:
        weeklyChange = 0.5; // 0.5 kg/tydzień dla utraty wagi
        break;
      case AppConstants.goalWeightGain:
        weeklyChange = 0.25; // 0.25 kg/tydzień dla przybrania wagi
        break;
      case AppConstants.goalMaintain:
      default:
        // Dla utrzymania wagi, termin jest bardzo odległy (np. 1 rok)
        return DateTime.now().add(const Duration(days: 365));
    }

    if (weeklyChange == 0) {
      return DateTime.now().add(const Duration(days: 365));
    }

    final weeksNeeded = (difference / weeklyChange).ceil();
    return DateTime.now().add(Duration(days: weeksNeeded * 7));
  }

  /// Oblicza BMI (Body Mass Index)
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Oblicza zakres wag dla normy BMI (18.5 - 24.9) dla danego wzrostu.
  /// Zwraca (wagaMin, wagaMax) w kg.
  static (double, double) weightRangeForNormalBMI(double heightCm) {
    final heightM = heightCm / 100;
    final heightSq = heightM * heightM;
    return (18.5 * heightSq, 24.9 * heightSq);
  }

  /// Oblicza WHR (Waist-to-Hip Ratio)
  static double calculateWHR({
    required double waistCm,
    required double hipsCm,
  }) {
    if (hipsCm == 0) return 0;
    return waistCm / hipsCm;
  }

  /// Dzienny cel picia wody (ml) na podstawie wagi ciała.
  /// Wzór: ok. 35 ml na każdy kg masy (rekomendacje żywieniowe).
  /// Zaokrąglone do 50 ml w górę dla czytelności.
  static double calculateDailyWaterGoalMl(double weightKg) {
    final raw = weightKg * AppConstants.waterMlPerKg;
    const step = 50.0;
    return (raw / step).ceil() * step;
  }

  /// Krótki opis, jak został policzony cel wody (do wyświetlenia w ustawieniach profilu).
  static String waterGoalExplanation(double weightKg) {
    final goal = calculateDailyWaterGoalMl(weightKg);
    final mlPerKg = AppConstants.waterMlPerKg.toInt();
    return 'Obliczone z Twojej wagi: $mlPerKg ml na każdy kg ($weightKg kg → ok. ${(weightKg * AppConstants.waterMlPerKg).round()} ml, zaokrąglone do $goal ml). Możesz zmienić cel ręcznie.';
  }
}
