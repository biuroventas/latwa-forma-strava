import 'package:flutter_test/flutter_test.dart';
import 'package:latwa_forma/core/constants/app_constants.dart';
import 'package:latwa_forma/core/utils/real_tdee_estimator.dart';

void main() {
  group('RealTdeeEstimator', () {
    group('estimateRealTDEE', () {
      test('estimates TDEE when maintaining weight', () {
        final tdee = RealTdeeEstimator.estimateRealTDEE(
          avgDailyCalories: 2000,
          weightChangeKgPerWeek: 0,
        );
        expect(tdee, 2000);
      });

      test('estimates higher TDEE when losing weight', () {
        // Chudnięcie 0.5 kg/tydzień przy 2000 kcal → realne TDEE ~2550
        final tdee = RealTdeeEstimator.estimateRealTDEE(
          avgDailyCalories: 2000,
          weightChangeKgPerWeek: -0.5,
        );
        expect(tdee, closeTo(2550, 10));
      });

      test('estimates lower TDEE when gaining weight', () {
        final tdee = RealTdeeEstimator.estimateRealTDEE(
          avgDailyCalories: 2000,
          weightChangeKgPerWeek: 0.25,
        );
        expect(tdee, closeTo(1725, 10));
      });
    });

    group('getCorrectedTargetCalories', () {
      test('applies deficit for weight loss', () {
        final target = RealTdeeEstimator.getCorrectedTargetCalories(
          realTDEE: 2200,
          goal: AppConstants.goalWeightLoss,
        );
        expect(target, 1700);
      });

      test('applies surplus for weight gain', () {
        final target = RealTdeeEstimator.getCorrectedTargetCalories(
          realTDEE: 2200,
          goal: AppConstants.goalWeightGain,
        );
        expect(target, 2450);
      });

      test('returns real TDEE for maintain', () {
        final target = RealTdeeEstimator.getCorrectedTargetCalories(
          realTDEE: 2200,
          goal: AppConstants.goalMaintain,
        );
        expect(target, 2200);
      });
    });

    group('hasEnoughData', () {
      test('returns false with insufficient days', () {
        expect(
          RealTdeeEstimator.hasEnoughData(
            daysWithCalories: 3,
            weightLogsInRange: 5,
          ),
          false,
        );
      });

      test('returns false with insufficient weight logs', () {
        expect(
          RealTdeeEstimator.hasEnoughData(
            daysWithCalories: 7,
            weightLogsInRange: 0,
          ),
          false,
        );
      });

      test('returns true with sufficient data', () {
        expect(
          RealTdeeEstimator.hasEnoughData(
            daysWithCalories: 7,
            weightLogsInRange: 2,
          ),
          true,
        );
      });
    });
  });
}
