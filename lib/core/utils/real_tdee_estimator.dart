import '../constants/app_constants.dart';

/// Szacuje realne TDEE i poprawiony cel kaloryczny na podstawie danych użytkownika.
///
/// Wzór: TDEE ≈ średnie kalorie − (zmiana wagi kg/tydzień × 7700 / 7)
/// 1 kg tkanki tłuszczowej ≈ 7700 kcal.
class RealTdeeEstimator {
  static const int _minDaysWithData = 5;
  static const int _minWeightLogs = 1; // 1 = zakładamy brak zmiany, 2+ = liczymy trend
  static const double _kcalPerKgBodyFat = 7700;
  static const double _defaultDeficitKcal = 500; // ~0.5 kg/tydzień
  static const double _defaultSurplusKcal = 250; // ~0.25 kg/tydzień

  /// Szacuje realne TDEE na podstawie średnich kalorii i zmiany wagi.
  ///
  /// [weightChangeKgPerWeek] - zmiana wagi w kg na tydzień (ujemna = chudnięcie, dodatnia = przybieranie)
  static double estimateRealTDEE({
    required double avgDailyCalories,
    required double weightChangeKgPerWeek,
  }) {
    return avgDailyCalories - (weightChangeKgPerWeek * _kcalPerKgBodyFat / 7);
  }

  /// Oblicza poprawiony cel kaloryczny na podstawie realnego TDEE i celu użytkownika.
  static double getCorrectedTargetCalories({
    required double realTDEE,
    required String goal,
    double? deficitKcal,
    double? surplusKcal,
  }) {
    switch (goal) {
      case AppConstants.goalWeightLoss:
        return realTDEE - (deficitKcal ?? _defaultDeficitKcal);
      case AppConstants.goalWeightGain:
        return realTDEE + (surplusKcal ?? _defaultSurplusKcal);
      case AppConstants.goalMaintain:
      default:
        return realTDEE;
    }
  }

  /// Sprawdza czy mamy wystarczająco danych do weryfikacji.
  static bool hasEnoughData({
    required int daysWithCalories,
    required int weightLogsInRange,
  }) {
    return daysWithCalories >= _minDaysWithData && weightLogsInRange >= _minWeightLogs;
  }

  static int get minDaysWithData => _minDaysWithData;
}
