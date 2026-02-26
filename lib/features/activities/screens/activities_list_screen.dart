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
import '../../../shared/models/activity.dart';
import '../../dashboard/screens/dashboard_screen.dart';

final activitiesListProvider = FutureProvider.autoDispose.family<List<Activity>, DateTime>((ref, date) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getActivities(userId, date: date);
});

class ActivitiesListScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const ActivitiesListScreen({
    super.key,
    required this.date,
  });

  @override
  ConsumerState<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends ConsumerState<ActivitiesListScreen> {
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
    final activitiesAsync = ref.watch(activitiesListProvider(_displayedDate));

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
                    child: Text('Aktywności - ${_formatDate(_displayedDate)}'),
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
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(activitiesListProvider(_displayedDate)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: EmptyStateWidget(
                    icon: Icons.fitness_center,
                    title: 'Brak aktywności na ten dzień',
                    action: TextButton(
                      onPressed: () async {
                        final result = await context.push<bool>(AppRoutes.activitiesAdd, extra: _displayedDate);
                        if (result == true && context.mounted) ref.invalidate(activitiesListProvider(_displayedDate));
                      },
                      child: const Text('Dodaj pierwszą aktywność'),
                    ),
                  ),
                ),
              ),
            );
          }

          double totalBurned = 0;
          int totalDuration = 0;

          for (var activity in activities) {
            if (!activity.excludedFromBalance) {
              totalBurned += activity.caloriesBurned;
              totalDuration += activity.durationMinutes ?? 0;
            }
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(activitiesListProvider(_displayedDate)),
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
                              _buildSummaryItem(context, 'Spalone', totalBurned.toStringAsFixed(0), 'kcal'),
                              _buildSummaryItem(context, 'Czas', _formatDuration(totalDuration), ''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                    final activity = activities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: Icon(
                              activity.isFromGarmin ? Icons.watch : Icons.fitness_center,
                              color: activity.isFromGarmin
                                  ? Colors.blue.shade700
                                  : _getIntensityColor(activity.intensity),
                            ),
                            title: Text(
                              activity.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${activity.caloriesBurned.toStringAsFixed(0)} kcal'
                              '${activity.durationMinutes != null ? ' • ${activity.durationMinutes} min' : ''}'
                              '${activity.intensity != null ? ' • ${_getIntensityText(activity.intensity!)}' : ''}'
                              '${activity.excludedFromBalance ? ' • nie w bilansie' : ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await context.push<bool>(AppRoutes.activitiesAdd, extra: activity);
                                    if (result == true && context.mounted) {
                                      ref.invalidate(activitiesListProvider(_displayedDate));
                                      ref.invalidate(dashboardDataProvider(_displayedDate));
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirmed = await DeleteConfirmationDialog.show(
                                      context,
                                      title: 'Usuń aktywność',
                                      content: 'Czy na pewno chcesz usunąć "${activity.name}"?',
                                    );
                                    if (confirmed) {
                                      try {
                                        final service = SupabaseService();
                                        await service.deleteActivity(activity.id!);
                                        if (context.mounted) {
                                          ref.invalidate(activitiesListProvider(_displayedDate));
                                          ref.invalidate(dashboardDataProvider(_displayedDate));
                                          SuccessMessage.show(context, 'Aktywność usunięta');
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
                          if (activity.id != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nie licz w bilansie (spalone)',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: activity.excludedFromBalance,
                                    onChanged: (bool value) async {
                                      try {
                                        final service = SupabaseService();
                                        await service.updateActivity(
                                          activity.copyWith(excludedFromBalance: value),
                                        );
                                        if (context.mounted) {
                                          ref.invalidate(activitiesListProvider(_displayedDate));
                                          ref.invalidate(dashboardDataProvider(_displayedDate));
                                          SuccessMessage.show(
                                            context,
                                            value ? 'Aktywność wyłączona z bilansu' : 'Aktywność wliczana do bilansu',
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ErrorHandler.showSnackBar(context, error: e);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                    },
                    childCount: activities.length,
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
                onPressed: () => ref.invalidate(activitiesListProvider(_displayedDate)),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>(AppRoutes.activitiesAdd, extra: _displayedDate);
          if (result == true && context.mounted) ref.invalidate(activitiesListProvider(_displayedDate));
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
          unit.isNotEmpty ? '$label ($unit)' : label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Color _getIntensityColor(String? intensity) {
    switch (intensity) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'very_high':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getIntensityText(String intensity) {
    switch (intensity) {
      case 'low':
        return 'Niska';
      case 'moderate':
        return 'Umiarkowana';
      case 'high':
        return 'Wysoka';
      case 'very_high':
        return 'Bardzo wysoka';
      default:
        return intensity;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours h $mins min' : '$hours h';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
