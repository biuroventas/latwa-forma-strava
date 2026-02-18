import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/success_message.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/models/meal.dart';
final mealsListProvider = FutureProvider.autoDispose.family<List<Meal>, DateTime>((ref, date) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getMeals(userId, date: date);
});

class MealsListScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const MealsListScreen({
    super.key,
    required this.date,
  });

  @override
  ConsumerState<MealsListScreen> createState() => _MealsListScreenState();
}

class _MealsListScreenState extends ConsumerState<MealsListScreen> {
  late DateTime _displayedDate;

  @override
  void initState() {
    super.initState();
    _displayedDate = widget.date;
  }

  bool get _canGoNext {
    final today = DateTime.now();
    final next = _displayedDate.add(const Duration(days: 1));
    return next.year < today.year ||
        (next.year == today.year && next.month < today.month) ||
        (next.year == today.year && next.month == today.month && next.day <= today.day);
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsListProvider(_displayedDate));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Wróć do dashboardu',
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() => _displayedDate = _displayedDate.subtract(const Duration(days: 1)));
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _displayedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && mounted) setState(() => _displayedDate = picked);
                    },
                    child: Text('Posiłki - ${_formatDate(_displayedDate)}'),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _canGoNext
                  ? () {
                      setState(() => _displayedDate = _displayedDate.add(const Duration(days: 1)));
                    }
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Ulubione posiłki',
            onPressed: () async {
              final result = await context.push<bool>(AppRoutes.favorites, extra: _displayedDate);
              if (result == true && context.mounted) ref.invalidate(mealsListProvider(_displayedDate));
            },
          ),
        ],
      ),
      body: mealsAsync.when(
        data: (meals) {
          if (meals.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(mealsListProvider(_displayedDate)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: EmptyStateWidget(
                    icon: Icons.restaurant,
                    title: 'Brak posiłków na ten dzień',
                    subtitle: 'Użyj przycisku + aby dodać posiłek',
                  ),
                ),
              ),
            );
          }

          double totalCalories = 0;
          double totalProtein = 0;
          double totalFat = 0;
          double totalCarbs = 0;

          for (var meal in meals) {
            totalCalories += meal.calories;
            totalProtein += meal.proteinG;
            totalFat += meal.fatG;
            totalCarbs += meal.carbsG;
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mealsListProvider(_displayedDate)),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Podsumowanie dnia',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(context, 'Kalorie', totalCalories.toStringAsFixed(0), 'kcal'),
                              _buildSummaryItem(context, 'Białko', totalProtein.toStringAsFixed(0), 'g'),
                              _buildSummaryItem(context, 'Tłuszcze', totalFat.toStringAsFixed(0), 'g'),
                              _buildSummaryItem(context, 'Węgle', totalCarbs.toStringAsFixed(0), 'g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: meals.length,
                    (context, index) {
                    final meal = meals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: _getMealTypeIcon(meal.mealType),
                        title: Text(
                          meal.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${meal.calories.toStringAsFixed(0)} kcal • '
                          'B: ${meal.proteinG.toStringAsFixed(0)}g • '
                          'T: ${meal.fatG.toStringAsFixed(0)}g • '
                          'W: ${meal.carbsG.toStringAsFixed(0)}g',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await context.push<bool>(AppRoutes.mealsAdd, extra: meal);
                                if (result == true && context.mounted) ref.invalidate(mealsListProvider(_displayedDate));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await DeleteConfirmationDialog.show(
                                  context,
                                  title: 'Usuń posiłek',
                                  content: 'Czy na pewno chcesz usunąć "${meal.name}"?',
                                );
                                if (confirmed) {
                                  try {
                                    final service = SupabaseService();
                                    await service.deleteMeal(meal.id!);
                                    if (context.mounted) {
                                      ref.invalidate(mealsListProvider(_displayedDate));
                                      SuccessMessage.show(context, 'Posiłek usunięty');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ErrorHandler.showSnackBar(context, error: e);
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(mealsListProvider(_displayedDate)),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>(AppRoutes.mealsAdd, extra: _displayedDate);
          if (result == true && context.mounted) ref.invalidate(mealsListProvider(_displayedDate));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          '$label ($unit)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Icon _getMealTypeIcon(String? mealType) {
    switch (mealType) {
      case 'breakfast':
        return const Icon(Icons.breakfast_dining, color: Colors.orange);
      case 'lunch':
        return const Icon(Icons.lunch_dining, color: Colors.blue);
      case 'dinner':
        return const Icon(Icons.dinner_dining, color: Colors.purple);
      case 'snack':
        return const Icon(Icons.cookie, color: Colors.brown);
      default:
        return const Icon(Icons.restaurant, color: Colors.grey);
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
