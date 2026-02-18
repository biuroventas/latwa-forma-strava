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
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/services/supabase_service.dart';

final favoriteMealsProvider = FutureProvider.autoDispose<List<FavoriteMeal>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getFavoriteMeals(userId);
});

class FavoriteMealsScreen extends ConsumerWidget {
  final DateTime? initialDate;

  const FavoriteMealsScreen({super.key, this.initialDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteMeals = ref.watch(favoriteMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione posiłki'),
      ),
      body: favoriteMeals.when(
        data: (meals) {
          if (meals.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Brak ulubionych posiłków',
              subtitle: 'Dodaj posiłki do ulubionych, aby szybko je dodawać',
              iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoriteMealsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                          'B: ${meal.proteinG.toStringAsFixed(1)}g | '
                          'T: ${meal.fatG.toStringAsFixed(1)}g | '
                          'W: ${meal.carbsG.toStringAsFixed(1)}g',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Szybkie dodanie
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).colorScheme.primary,
                          tooltip: initialDate != null
                              ? 'Dodaj do posiłków ${initialDate!.day}.${initialDate!.month}.${initialDate!.year}'
                              : 'Dodaj do dzisiejszych posiłków',
                          onPressed: () => _quickAddMeal(context, ref, meal, initialDate),
                        ),
                        // Edytuj
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edytuj',
                          onPressed: () async {
                            final result = await context.push<bool>(AppRoutes.editFavorite, extra: meal);
                            if (result == true && context.mounted) ref.invalidate(favoriteMealsProvider);
                          },
                        ),
                        // Usuń z ulubionych
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          tooltip: 'Usuń z ulubionych',
                          onPressed: () => _deleteFavorite(context, ref, meal),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      final createdAt = DateTime(
        effectiveDate.year,
        effectiveDate.month,
        effectiveDate.day,
        12,
        0,
      );

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
        context.pop();
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }

  Future<void> _deleteFavorite(BuildContext context, WidgetRef ref, FavoriteMeal favoriteMeal) async {
    if (favoriteMeal.id == null) return;

    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Usuń z ulubionych',
      content: 'Czy na pewno chcesz usunąć "${favoriteMeal.name}" z ulubionych?',
    );

    if (!confirmed) return;

    try {
      final service = SupabaseService();
      await service.deleteFavoriteMeal(favoriteMeal.id!);
      if (context.mounted) {
        ref.invalidate(favoriteMealsProvider);
        SuccessMessage.show(context, 'Usunięto z ulubionych');
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, error: e);
    }
  }
}
