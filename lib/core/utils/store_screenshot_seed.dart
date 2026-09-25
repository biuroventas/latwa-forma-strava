import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../constants/app_constants.dart';
import '../../shared/models/activity.dart';
import '../../shared/models/meal.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/water_log.dart';
import '../../shared/services/supabase_service.dart';

/// Tylko przy `flutter run --dart-define=STORE_SCREENSHOTS=true`.
const bool kStoreScreenshots = bool.fromEnvironment('STORE_SCREENSHOTS');

Future<void> seedStoreScreenshotsIfEnabled() async {
  if (!kStoreScreenshots || !SupabaseConfig.isInitialized) return;

  try {
    var user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      final res = await SupabaseConfig.auth.signInAnonymously();
      user = res.user;
    }
    if (user == null) {
      debugPrint('STORE_SCREENSHOTS: brak usera');
      return;
    }

    final service = SupabaseService();
    var profile = await service.getProfile(user.id);
    profile ??= await service.createProfile(
      UserProfile(
        userId: user.id,
        gender: AppConstants.genderMale,
        age: 32,
        heightCm: 178,
        currentWeightKg: 82,
        targetWeightKg: 76,
        activityLevel: AppConstants.activityModerate,
        goal: AppConstants.goalWeightLoss,
        bmr: 1780,
        tdee: 2480,
        targetCalories: 2100,
        targetProteinG: 160,
        targetFatG: 65,
        targetCarbsG: 220,
        waterGoalMl: 2500,
      ),
    );

    final today = DateTime.now();
    final meals = await service.getMeals(user.id, date: today);
    if (meals.isEmpty) {
      await service.createMeal(Meal(
        userId: user.id,
        name: 'Owsianka z owocami',
        calories: 420,
        proteinG: 18,
        fatG: 12,
        carbsG: 58,
        fiberG: 8,
        mealType: AppConstants.mealBreakfast,
        source: AppConstants.mealSourceManual,
      ));
      await service.createMeal(Meal(
        userId: user.id,
        name: 'Kurczak z ryżem i warzywami',
        calories: 680,
        proteinG: 48,
        fatG: 18,
        carbsG: 72,
        mealType: AppConstants.mealLunch,
        source: AppConstants.mealSourceManual,
      ));
      await service.createMeal(Meal(
        userId: user.id,
        name: 'Sałatka z łososiem',
        calories: 520,
        proteinG: 36,
        fatG: 28,
        carbsG: 22,
        mealType: AppConstants.mealDinner,
        source: AppConstants.mealSourceManual,
      ));
    }

    final water = await service.getWaterLogs(user.id, date: today);
    if (water.isEmpty) {
      await service.createWaterLog(WaterLog(userId: user.id, amountMl: 500));
      await service.createWaterLog(WaterLog(userId: user.id, amountMl: 350));
      await service.createWaterLog(WaterLog(userId: user.id, amountMl: 250));
    }

    final activities = await service.getActivities(user.id, date: today);
    if (activities.isEmpty) {
      await service.createActivity(Activity(
        userId: user.id,
        name: 'Spacer',
        caloriesBurned: 180,
        durationMinutes: 35,
        activityType: 'WALKING',
      ));
    }

    debugPrint('STORE_SCREENSHOTS: dane demo gotowe (${profile.userId})');
  } catch (e, st) {
    debugPrint('STORE_SCREENSHOTS seed: $e\n$st');
  }
}
