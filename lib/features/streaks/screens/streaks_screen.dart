import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/streak.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';

final streaksProvider = FutureProvider.autoDispose<List<Streak>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getStreaks(userId);
});

class StreaksScreen extends ConsumerWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final streaksAsync = ref.watch(streaksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreStreaksTitle),
      ),
      body: streaksAsync.when(
        data: (streaks) {
          if (streaks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.moreNoStreaks,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.moreNoStreaksHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(streaksProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: streaks.map((streak) => _buildStreakCard(context, streak)).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.moreErrorWithDetails(error: error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(streaksProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _streakDisplayName(AppLocalizations l10n, String type) {
    switch (type) {
      case AppConstants.streakMeals:
        return l10n.moreStreakMeals;
      case AppConstants.streakWater:
        return l10n.moreWater;
      case AppConstants.streakActivities:
        return l10n.moreStreakActivities;
      case AppConstants.streakWeight:
        return l10n.moreStreakWeight;
      default:
        return type;
    }
  }

  Widget _buildStreakCard(BuildContext context, Streak streak) {
    final l10n = context.l10n;
    final icon = _getStreakIcon(streak.streakType);
    final color = _getStreakColor(streak.streakType);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _streakDisplayName(l10n, streak.streakType),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (streak.lastDate != null)
                        Text(
                          l10n.moreLastTime(date: _formatDate(streak.lastDate!)),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakStat(
                  context,
                  l10n.moreCurrentStreak,
                  '${streak.currentStreak}',
                  streak.currentStreak > 0 ? Colors.orange : Colors.grey,
                ),
                _buildStreakStat(
                  context,
                  l10n.moreLongestStreak,
                  '${streak.longestStreak}',
                  Colors.blue,
                ),
              ],
            ),
            if (streak.currentStreak > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: streak.longestStreak > 0
                    ? (streak.currentStreak / streak.longestStreak).clamp(0.0, 1.0)
                    : 1.0,
                backgroundColor: Colors.grey.shade200,
                minHeight: 6,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  IconData _getStreakIcon(String type) {
    switch (type) {
      case AppConstants.streakMeals:
        return Icons.restaurant;
      case AppConstants.streakWater:
        return Icons.water_drop;
      case AppConstants.streakActivities:
        return Icons.fitness_center;
      case AppConstants.streakWeight:
        return Icons.monitor_weight;
      default:
        return Icons.local_fire_department;
    }
  }

  Color _getStreakColor(String type) {
    switch (type) {
      case AppConstants.streakMeals:
        return Colors.green;
      case AppConstants.streakWater:
        return Colors.blue;
      case AppConstants.streakActivities:
        return Colors.orange;
      case AppConstants.streakWeight:
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
