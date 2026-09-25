import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/main_tab_provider.dart';
import '../../core/utils/streak_updater.dart';
import '../models/meal.dart';
import 'supabase_service.dart';

/// Wspólna logika kopiowania posiłków i szybkiego dodawania z szablonu.
class MealCopyHelper {
  MealCopyHelper._();

  static String inferMealTypeFromHour(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 11) return AppConstants.mealBreakfast;
    if (hour >= 11 && hour < 15) return AppConstants.mealLunch;
    if (hour >= 15 && hour < 18) return AppConstants.mealSnack;
    if (hour >= 18 && hour < 22) return AppConstants.mealDinner;
    return AppConstants.mealSnack;
  }

  static DateTime createdAtForSelectedDay(DateTime selectedDay, {DateTime? reference}) {
    final ref = reference ?? DateTime.now();
    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      ref.hour,
      ref.minute,
      ref.second,
    );
  }

  /// Kopiuje posiłki z [sourceDay] na [targetDay]. Zwraca liczbę skopiowanych posiłków lub null przy anulowaniu / braku danych.
  static Future<int?> copyMealsFromDay({
    required BuildContext context,
    required AppLocalizations l10n,
    required String userId,
    required DateTime sourceDay,
    required DateTime targetDay,
  }) async {
    final service = SupabaseService();
    final source = dayKey(sourceDay);
    final target = dayKey(targetDay);

    final meals = await service.getMeals(userId, date: source);
    if (!context.mounted) return null;
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trackNoMealsYesterday)),
      );
      return null;
    }

    final existing = await service.getMeals(userId, date: target);
    if (!context.mounted) return null;
    if (existing.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.trackCopyConfirmTitle),
          content: Text(l10n.trackCopyConfirmBody(count: existing.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.trackCopyAgain),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return null;
    }

    final noon = DateTime(target.year, target.month, target.day, 12);
    for (var i = 0; i < meals.length; i++) {
      final meal = meals[i];
      await service.createMeal(Meal(
        userId: userId,
        name: meal.name,
        calories: meal.calories,
        proteinG: meal.proteinG,
        fatG: meal.fatG,
        carbsG: meal.carbsG,
        saturatedFatG: meal.saturatedFatG,
        sugarG: meal.sugarG,
        fiberG: meal.fiberG,
        saltG: meal.saltG,
        weightG: meal.weightG,
        mealType: meal.mealType ?? inferMealTypeFromHour(noon.add(Duration(minutes: i))),
        source: meal.source,
        createdAt: noon.add(Duration(minutes: i)),
      ));
    }
    await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, target);
    return meals.length;
  }

  /// Jedno tapnięcie — nowy posiłek na [selectedDay] na podstawie wcześniejszego wpisu.
  static Future<void> quickCreateFromMeal({
    required String userId,
    required Meal template,
    required DateTime selectedDay,
  }) async {
    final service = SupabaseService();
    final createdAt = createdAtForSelectedDay(selectedDay);
    await service.createMeal(Meal(
      userId: userId,
      name: template.name,
      calories: template.calories,
      proteinG: template.proteinG,
      fatG: template.fatG,
      carbsG: template.carbsG,
      saturatedFatG: template.saturatedFatG,
      sugarG: template.sugarG,
      fiberG: template.fiberG,
      saltG: template.saltG,
      weightG: template.weightG,
      mealType: template.mealType ?? inferMealTypeFromHour(createdAt),
      source: template.source,
      createdAt: createdAt,
    ));
    await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, dayKey(selectedDay));
  }
}
