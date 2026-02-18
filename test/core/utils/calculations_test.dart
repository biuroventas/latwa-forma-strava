import 'package:flutter_test/flutter_test.dart';
import 'package:latwa_forma/core/constants/app_constants.dart';
import 'package:latwa_forma/core/utils/calculations.dart';

void main() {
  group('Calculations', () {
    group('deriveGoalFromWeights', () {
      test('returns weight_loss when target < current', () {
        expect(
          Calculations.deriveGoalFromWeights(
            currentWeightKg: 80,
            targetWeightKg: 70,
          ),
          AppConstants.goalWeightLoss,
        );
      });

      test('returns weight_gain when target > current', () {
        expect(
          Calculations.deriveGoalFromWeights(
            currentWeightKg: 70,
            targetWeightKg: 80,
          ),
          AppConstants.goalWeightGain,
        );
      });

      test('returns maintain when difference < 0.5 kg', () {
        expect(
          Calculations.deriveGoalFromWeights(
            currentWeightKg: 80,
            targetWeightKg: 80.3,
          ),
          AppConstants.goalMaintain,
        );
      });
    });

    group('calculateBMR', () {
      test('calculates male BMR correctly', () {
        final bmr = Calculations.calculateBMR(
          gender: AppConstants.genderMale,
          weightKg: 80,
          heightCm: 180,
          age: 30,
        );
        expect(bmr, closeTo(1850, 50));
      });

      test('calculates female BMR correctly', () {
        final bmr = Calculations.calculateBMR(
          gender: AppConstants.genderFemale,
          weightKg: 60,
          heightCm: 165,
          age: 25,
        );
        expect(bmr, closeTo(1380, 50));
      });
    });

    group('calculateTDEE', () {
      test('sedentary multiplier', () {
        final tdee = Calculations.calculateTDEE(
          bmr: 1500,
          activityLevel: AppConstants.activitySedentary,
        );
        expect(tdee, 1800);
      });

      test('moderate multiplier', () {
        final tdee = Calculations.calculateTDEE(
          bmr: 1500,
          activityLevel: AppConstants.activityModerate,
        );
        expect(tdee, 2325);
      });
    });

    group('calculateMacros', () {
      test('weight loss reduces calories', () {
        final macros = Calculations.calculateMacros(
          tdee: 2000,
          goal: AppConstants.goalWeightLoss,
          targetWeightKg: 70,
        );
        expect(macros['calories'], 1500);
        expect(macros['protein'], 140);
      });

      test('weight gain adds calories', () {
        final macros = Calculations.calculateMacros(
          tdee: 2000,
          goal: AppConstants.goalWeightGain,
          targetWeightKg: 80,
        );
        expect(macros['calories'], 2250);
        expect(macros['protein'], 160);
      });
    });

    group('calculateBMI', () {
      test('normal BMI', () {
        final bmi = Calculations.calculateBMI(
          weightKg: 70,
          heightCm: 175,
        );
        expect(bmi, closeTo(22.9, 0.1));
      });

      test('overweight BMI', () {
        final bmi = Calculations.calculateBMI(
          weightKg: 90,
          heightCm: 175,
        );
        expect(bmi, closeTo(29.4, 0.1));
      });
    });

    group('weightRangeForNormalBMI', () {
      test('returns correct range for 175 cm', () {
        final (min, max) = Calculations.weightRangeForNormalBMI(175);
        expect(min, closeTo(56.7, 0.1));
        expect(max, closeTo(76.3, 0.1));
      });
    });

    group('calculateWHR', () {
      test('calculates WHR', () {
        final whr = Calculations.calculateWHR(waistCm: 80, hipsCm: 100);
        expect(whr, 0.8);
      });

      test('returns 0 for zero hips', () {
        expect(
          Calculations.calculateWHR(waistCm: 80, hipsCm: 0),
          0,
        );
      });
    });
  });
}
