import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/streak_updater.dart';
import '../../../core/utils/success_message.dart';
import '../../../shared/models/favorite_meal.dart';
import '../../../shared/models/favorite_activity.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/services/supabase_service.dart';

final favoriteMealsProvider = FutureProvider.autoDispose<List<FavoriteMeal>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');
  final service = SupabaseService();
  return await service.getFavoriteMeals(userId);
});

final favoriteActivitiesProvider = FutureProvider.autoDispose<List<FavoriteActivity>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');
  final service = SupabaseService();
  return await service.getFavoriteActivities(userId);
});

class FavoriteMealsScreen extends ConsumerWidget {
  final DateTime? initialDate;

  const FavoriteMealsScreen({super.key, this.initialDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteMeals = ref.watch(favoriteMealsProvider);
    final favoriteActivities = ref.watch(favoriteActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione'),
      ),
      body: favoriteMeals.when(
        data: (meals) {
          return favoriteActivities.when(
            data: (activities) {
              if (meals.isEmpty && activities.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'Brak ulubionych',
                  subtitle: 'Dodaj posiłki lub aktywności do ulubionych przy ich zapisywaniu',
                  iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(favoriteMealsProvider);
                  ref.invalidate(favoriteActivitiesProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Sekcja: Ulubione posiłki
                    _sectionHeader(context, Icons.restaurant, 'Ulubione posiłki', Colors.green),
                    if (meals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          'Brak ulubionych posiłków',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    else
                      ...meals.map((meal) => _mealCard(context, ref, meal)),
                    const SizedBox(height: 24),
                    // Sekcja: Ulubione aktywności
                    _sectionHeader(context, Icons.fitness_center, 'Ulubione aktywności', Colors.orange),
                    if (activities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          'Brak ulubionych aktywności',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    else
                      ...activities.map((activity) => _activityCard(context, ref, activity)),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Błąd: $err'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(favoriteActivitiesProvider),
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Błąd: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(favoriteMealsProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _mealCard(BuildContext context, WidgetRef ref, FavoriteMeal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${meal.calories.toStringAsFixed(0)} kcal',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'B: ${meal.proteinG.toStringAsFixed(1)}g | T: ${meal.fatG.toStringAsFixed(1)}g | W: ${meal.carbsG.toStringAsFixed(1)}g',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).colorScheme.primary,
              tooltip: initialDate != null
                  ? 'Dodaj do posiłków ${initialDate!.day}.${initialDate!.month}.${initialDate!.year}'
                  : 'Dodaj do dzisiejszych posiłków',
              onPressed: () => _quickAddMeal(context, ref, meal, initialDate),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edytuj',
              onPressed: () async {
                final result = await context.push<bool>(AppRoutes.editFavorite, extra: meal);
                if (result == true && context.mounted) ref.invalidate(favoriteMealsProvider);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              tooltip: 'Usuń z ulubionych',
              onPressed: () => _deleteFavoriteMeal(context, ref, meal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(BuildContext context, WidgetRef ref, FavoriteActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 28),
        title: Text(activity.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${activity.caloriesBurned.toStringAsFixed(0)} kcal spalone',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (activity.durationMinutes != null) ...[
              const SizedBox(height: 2),
              Text('${activity.durationMinutes} min', style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).colorScheme.primary,
              tooltip: initialDate != null
                  ? 'Dodaj do aktywności ${initialDate!.day}.${initialDate!.month}.${initialDate!.year}'
                  : 'Dodaj do dzisiejszych aktywności',
              onPressed: () => _quickAddActivity(context, ref, activity, initialDate),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              tooltip: 'Usuń z ulubionych',
              onPressed: () => _deleteFavoriteActivity(context, ref, activity),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickAddMeal(
    BuildContext context,
    WidgetRef ref,
    FavoriteMeal favoriteMeal, [
    DateTime? date,
  ]) async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;
      final effectiveDate = date ?? DateTime.now();
      final createdAt = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day, 12, 0);
      final service = SupabaseService();
      final meal = favoriteMeal.toMeal(createdAt: createdAt);
      await service.createMeal(meal);
      await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, effectiveDate);
      if (context.mounted) {
        SuccessMessage.show(
          context,
          date != null
              ? '${favoriteMeal.name} dodany do posiłków ${date.day}.${date.month}.${date.year}'
              : '${favoriteMeal.name} dodany do dzisiejszych posiłków',
        );
        context.pop(true);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }

  Future<void> _quickAddActivity(
    BuildContext context,
    WidgetRef ref,
    FavoriteActivity favoriteActivity, [
    DateTime? date,
  ]) async {
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;
      final effectiveDate = date ?? DateTime.now();
      final createdAt = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day, 12, 0);
      final service = SupabaseService();
      final activity = favoriteActivity.toActivity(createdAt: createdAt);
      await service.createActivity(activity);
      await StreakUpdater.updateStreak(userId, AppConstants.streakActivities, effectiveDate);
      if (context.mounted) {
        SuccessMessage.show(
          context,
          date != null
              ? '${favoriteActivity.name} dodana do aktywności ${date.day}.${date.month}.${date.year}'
              : '${favoriteActivity.name} dodana do dzisiejszych aktywności',
        );
        context.pop(true);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }

  Future<void> _deleteFavoriteMeal(BuildContext context, WidgetRef ref, FavoriteMeal favoriteMeal) async {
    if (favoriteMeal.id == null) return;
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Usuń z ulubionych',
      content: 'Czy na pewno chcesz usunąć "${favoriteMeal.name}" z ulubionych?',
    );
    if (!confirmed) return;
    try {
      await SupabaseService().deleteFavoriteMeal(favoriteMeal.id!);
      if (context.mounted) {
        ref.invalidate(favoriteMealsProvider);
        SuccessMessage.show(context, 'Usunięto z ulubionych');
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }

  Future<void> _deleteFavoriteActivity(BuildContext context, WidgetRef ref, FavoriteActivity favoriteActivity) async {
    if (favoriteActivity.id == null) return;
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Usuń z ulubionych',
      content: 'Czy na pewno chcesz usunąć "${favoriteActivity.name}" z ulubionych?',
    );
    if (!confirmed) return;
    try {
      await SupabaseService().deleteFavoriteActivity(favoriteActivity.id!);
      if (context.mounted) {
        ref.invalidate(favoriteActivitiesProvider);
        SuccessMessage.show(context, 'Usunięto z ulubionych');
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }
}
