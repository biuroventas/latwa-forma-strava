import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latwa_forma/l10n/app_localizations.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/real_tdee_estimator.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/services/supabase_service.dart';

/// Wynik weryfikacji celu na podstawie ostatnich 7 dni.
class GoalVerificationResult {
  final bool hasEnoughData;
  final int daysWithData;
  final double avgDailyCalories;
  final double weightChangeKg;
  final double? realTDEE;
  final double? correctedTargetCalories;
  final double? currentTargetCalories;
  final double? calculatorTDEE;
  final String? suggestionText;
  final String goal;
  final UserProfile? profile;

  const GoalVerificationResult({
    required this.hasEnoughData,
    required this.daysWithData,
    required this.avgDailyCalories,
    required this.weightChangeKg,
    this.realTDEE,
    this.correctedTargetCalories,
    this.currentTargetCalories,
    this.calculatorTDEE,
    this.suggestionText,
    required this.goal,
    this.profile,
  });
}

final goalVerificationProvider = FutureProvider.autoDispose<GoalVerificationResult>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  final today = DateTime.now();
  final startDate = today.subtract(const Duration(days: 6));
  final l10n = lookupAppLocalizations(currentAppLocale());

  final profile = await service.getProfile(userId);
  if (profile == null) {
    return const GoalVerificationResult(
      hasEnoughData: false,
      daysWithData: 0,
      avgDailyCalories: 0,
      weightChangeKg: 0,
      goal: AppConstants.goalMaintain,
    );
  }

  double totalCalories = 0;
  int daysWithCalories = 0;

  for (int i = 0; i < 7; i++) {
    final date = startDate.add(Duration(days: i));
    final meals = await service.getMeals(userId, date: date);

    double dayCalories = 0;
    for (var meal in meals) {
      dayCalories += meal.calories;
    }
    totalCalories += dayCalories;
    if (dayCalories > 0) daysWithCalories++;
  }

  final avgDailyCalories = daysWithCalories > 0 ? totalCalories / 7 : 0.0;

  final weightLogs = await service.getWeightLogsInRange(
    userId,
    startDate: startDate,
    endDate: today,
  );

  double weightChangeKg = 0;
  if (weightLogs.length >= 2) {
    final first = weightLogs.first;
    final last = weightLogs.last;
    weightChangeKg = last.weightKg - first.weightKg;
  }

  final hasEnoughData = RealTdeeEstimator.hasEnoughData(
    daysWithCalories: daysWithCalories,
    weightLogsInRange: weightLogs.length,
  );

  double? realTDEE;
  double? correctedTargetCalories;
  String? suggestionText;

  if (hasEnoughData && avgDailyCalories > 100) {
    realTDEE = RealTdeeEstimator.estimateRealTDEE(
      avgDailyCalories: avgDailyCalories,
      weightChangeKgPerWeek: weightChangeKg,
    );

    final deficitKcal = profile.weeklyWeightChange != null && profile.goal == AppConstants.goalWeightLoss
        ? profile.weeklyWeightChange! * 7700 / 7
        : null;
    final surplusKcal = profile.weeklyWeightChange != null && profile.goal == AppConstants.goalWeightGain
        ? profile.weeklyWeightChange! * 7700 / 7
        : null;

    correctedTargetCalories = RealTdeeEstimator.getCorrectedTargetCalories(
      realTDEE: realTDEE,
      goal: profile.goal,
      deficitKcal: deficitKcal,
      surplusKcal: surplusKcal,
    );

    final currentTarget = profile.targetCalories ?? profile.tdee ?? 0;
    final diff = (correctedTargetCalories - currentTarget).abs();

    if (diff > 100) {
      final realStr = realTDEE.toStringAsFixed(0);
      final calcStr = (profile.tdee ?? 0).toStringAsFixed(0);
      final corrStr = correctedTargetCalories.toStringAsFixed(0);
      final avgStr = avgDailyCalories.toStringAsFixed(0);

      switch (profile.goal) {
        case AppConstants.goalWeightLoss:
          if (weightChangeKg >= 0) {
            suggestionText = l10n.moreSuggestionWeightLossFlat(
              avg: avgStr,
              real: realStr,
              corr: corrStr,
            );
          } else {
            suggestionText = l10n.moreSuggestionWeightLossDown(
              avg: avgStr,
              real: realStr,
              corr: corrStr,
            );
          }
          break;
        case AppConstants.goalWeightGain:
          if (weightChangeKg <= 0) {
            suggestionText = l10n.moreSuggestionWeightGainFlat(
              avg: avgStr,
              real: realStr,
              corr: corrStr,
            );
          } else {
            suggestionText = l10n.moreSuggestionWeightGainUp(
              avg: avgStr,
              real: realStr,
              corr: corrStr,
            );
          }
          break;
        default:
          suggestionText = l10n.moreSuggestionMaintain(
            real: realStr,
            calc: calcStr,
            corr: corrStr,
          );
      }
    }
  }

  return GoalVerificationResult(
    hasEnoughData: hasEnoughData,
    daysWithData: daysWithCalories,
    avgDailyCalories: avgDailyCalories,
    weightChangeKg: weightChangeKg,
    realTDEE: realTDEE,
    correctedTargetCalories: correctedTargetCalories,
    currentTargetCalories: profile.targetCalories ?? profile.tdee,
    calculatorTDEE: profile.tdee,
    suggestionText: suggestionText,
    goal: profile.goal,
    profile: profile,
  );
});
