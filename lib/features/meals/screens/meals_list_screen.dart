import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/main_tab_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/success_message.dart';
import '../../../shared/services/meal_copy_helper.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/models/meal.dart';
import '../../dashboard/screens/dashboard_screen.dart';

/// Gałąź „Posiłki” w MainTabShell (StatefulShellBranch index 1).
const _mealsTabBranchIndex = 1;

final mealsListProvider =
    FutureProvider.autoDispose.family<List<Meal>, DateTime>((ref, date) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getMeals(userId, date: dayKey(date));
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
  bool _isCopying = false;

  DateTime get _day => dayKey(_displayedDate);

  @override
  void initState() {
    super.initState();
    _displayedDate = dayKey(widget.date);
  }

  bool get _canGoNext {
    final today = dayKey(DateTime.now());
    final next = _day.add(const Duration(days: 1));
    return !next.isAfter(today);
  }

  Future<void> _refreshMealsAndDashboard() async {
    ref.invalidate(mealsListProvider(_day));
    await ref.read(mealsListProvider(_day).future);
    ref.invalidate(dashboardDataProvider(_day));
    final today = dayKey(DateTime.now());
    if (_day != today) {
      ref.invalidate(dashboardDataProvider(today));
    }
  }

  Future<void> _copyYesterday() async {
    if (_isCopying) return;
    final l10n = context.l10n;
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isCopying = true);
    try {
      final copied = await MealCopyHelper.copyMealsFromDay(
        context: context,
        l10n: l10n,
        userId: userId,
        sourceDay: _day.subtract(const Duration(days: 1)),
        targetDay: _day,
      );
      if (!mounted || copied == null) return;
      await _refreshMealsAndDashboard();
      if (!mounted) return;
      SuccessMessage.show(
        context,
        l10n.trackCopiedMealsCount(count: copied),
        l10n: l10n,
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, l10n: context.l10n, error: e);
      }
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Przy każdym wejściu / ponownym tapnięciu zakładki Posiłki — świeże dane.
    ref.listen<int>(mainTabVisitProvider(_mealsTabBranchIndex), (prev, next) {
      if (prev != next) ref.invalidate(mealsListProvider(_day));
    });

    final mealsAsync = ref.watch(mealsListProvider(_day));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.trackBackToDashboard,
                onPressed: () => context.pop(),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() => _displayedDate = _day.subtract(const Duration(days: 1)));
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
                        initialDate: _day,
                        firstDate: DateTime(2020),
                        lastDate: dayKey(DateTime.now()),
                      );
                      if (picked != null && mounted) {
                        setState(() => _displayedDate = dayKey(picked));
                      }
                    },
                    child: Text(l10n.trackMealsDateTitle(date: _formatDate(_day))),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _canGoNext
                  ? () {
                      setState(() => _displayedDate = _day.add(const Duration(days: 1)));
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
            icon: _isCopying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.copy_rounded),
            tooltip: _isCopying ? l10n.trackCopying : l10n.trackCopyYesterday,
            onPressed: _isCopying ? null : _copyYesterday,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: l10n.trackFavoriteMealsTooltip,
            onPressed: () async {
              final result = await context.push<bool>(AppRoutes.favorites, extra: _day);
              if (result == true && context.mounted) {
                await _refreshMealsAndDashboard();
              }
            },
          ),
        ],
      ),
      body: mealsAsync.when(
        data: (meals) {
          if (meals.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshMealsAndDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: EmptyStateWidget(
                    icon: Icons.restaurant,
                    title: l10n.trackNoMealsForDay,
                    subtitle: l10n.trackUsePlusToAddMeal,
                    action: OutlinedButton.icon(
                      onPressed: _isCopying ? null : _copyYesterday,
                      icon: _isCopying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.copy_rounded),
                      label: Text(_isCopying ? l10n.trackCopying : l10n.trackCopyYesterday),
                    ),
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
            onRefresh: _refreshMealsAndDashboard,
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
                            l10n.trackDaySummary,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(context, l10n.trackCalories, totalCalories.toStringAsFixed(0), 'kcal'),
                              _buildSummaryItem(context, l10n.trackProtein, totalProtein.toStringAsFixed(0), 'g'),
                              _buildSummaryItem(context, l10n.trackFat, totalFat.toStringAsFixed(0), 'g'),
                              _buildSummaryItem(context, l10n.trackCarbsShort, totalCarbs.toStringAsFixed(0), 'g'),
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
                        leading: _getMealTypeIcon(
                          meal.mealType ??
                              MealCopyHelper.inferMealTypeFromHour(
                                meal.createdAt ?? DateTime.now(),
                              ),
                        ),
                        title: Text(
                          meal.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          l10n.trackMealMacrosLine(
                            kcal: meal.calories.toStringAsFixed(0),
                            protein: meal.proteinG.toStringAsFixed(0),
                            fat: meal.fatG.toStringAsFixed(0),
                            carbs: meal.carbsG.toStringAsFixed(0),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result = await context.push<bool>(AppRoutes.mealsAdd, extra: meal);
                                if (result == true && context.mounted) {
                                  await _refreshMealsAndDashboard();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await DeleteConfirmationDialog.show(
                                  context,
                                  title: l10n.trackDeleteMealTitle,
                                  content: l10n.trackDeleteMealConfirm(name: meal.name),
                                );
                                if (confirmed == true) {
                                  try {
                                    final service = SupabaseService();
                                    await service.deleteMeal(meal.id!);
                                    if (!context.mounted) return;
                                    await _refreshMealsAndDashboard();
                                    if (!context.mounted) return;
                                    SuccessMessage.show(context, l10n.trackMealDeleted, l10n: l10n);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ErrorHandler.showSnackBar(context, l10n: l10n, error: e);
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
              Text(l10n.trackErrorWithDetails(error: '$error')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(mealsListProvider(_day)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>(AppRoutes.mealsAdd, extra: _day);
          if (result == true && context.mounted) {
            await _refreshMealsAndDashboard();
          }
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
