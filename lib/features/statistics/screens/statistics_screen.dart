import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/calculations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../goal_verification.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../shared/widgets/premium_gate.dart';

final weeklyStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  final today = DateTime.now();
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  double totalCalories = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double totalCarbs = 0;
  double totalBurned = 0;
  double totalWater = 0;
  final dailyCalories = <double>[];

  for (int i = 0; i < 7; i++) {
    final date = weekStart.add(Duration(days: i));
    final meals = await service.getMeals(userId, date: date);
    final activities = await service.getActivities(userId, date: date);
    final water = await service.getTotalWaterForDate(userId, date);

    double dayCalories = 0;
    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.proteinG;
      totalFat += meal.fatG;
      totalCarbs += meal.carbsG;
      dayCalories += meal.calories;
    }

    for (var activity in activities) {
      totalBurned += activity.caloriesBurned;
    }

    totalWater += water;
    dailyCalories.add(dayCalories);
  }

  return {
    'totalCalories': totalCalories,
    'avgCalories': totalCalories / 7,
    'totalProtein': totalProtein,
    'totalFat': totalFat,
    'totalCarbs': totalCarbs,
    'totalBurned': totalBurned,
    'totalWater': totalWater,
    'dailyCalories': dailyCalories,
  };
});

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _isApplyingVerification = false;
  final _weeklySummaryKey = GlobalKey();

  Future<void> _shareWeeklySummaryScreenshot() async {
    final boundary = _weeklySummaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final l10n = context.l10n;

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        completer.complete();
        return;
      }
      try {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!mounted) {
          completer.complete();
          return;
        }
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          completer.complete();
          return;
        }
        final bytes = byteData.buffer.asUint8List();
        if (kIsWeb) {
          final now = DateTime.now();
          final xFile = XFile.fromData(bytes, name: 'tygodniowe_${now.day}_${now.month}.png');
          await Share.shareXFiles([xFile], text: l10n.moreShareWeeklySummaryText);
        } else {
          final tempDir = await getTemporaryDirectory();
          final now = DateTime.now();
          final file = File('${tempDir.path}/tygodniowe_${now.day}_${now.month}.png');
          await file.writeAsBytes(bytes);
          final box = boundary as RenderBox;
          final shareRect = box.localToGlobal(Offset.zero) & box.size;
          await Share.shareXFiles(
            [XFile(file.path)],
            text: l10n.moreShareWeeklySummaryText,
            sharePositionOrigin: shareRect,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.moreShareError(error: e.toString()))),
          );
        }
      } finally {
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(weeklyStatsProvider);
    final verificationAsync = ref.watch(goalVerificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreStatisticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_fire_department),
            tooltip: l10n.moreStreaksTooltip,
            onPressed: () => context.push(AppRoutes.streaks),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weeklyStatsProvider);
              ref.invalidate(goalVerificationProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVerificationSection(verificationAsync),
                  const SizedBox(height: 24),
                  RepaintBoundary(
                    key: _weeklySummaryKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.moreWeeklySummary,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              tooltip: l10n.moreShareTooltip,
                              onPressed: () async {
                                final canProceed = await checkPremiumOrNavigate(
                                  context,
                                  ref,
                                  featureName: l10n.moreShareWeeklyStatsFeature,
                                );
                                if (canProceed && mounted) _shareWeeklySummaryScreenshot();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatsCard(
                          context,
                          l10n.moreAvgDailyCalories,
                          '${(stats['avgCalories'] as double).toStringAsFixed(0)} kcal',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildStatsCard(
                          context,
                          l10n.moreTotalCaloriesWeek,
                          '${(stats['totalCalories'] as double).toStringAsFixed(0)} kcal',
                          Icons.restaurant,
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildStatsCard(
                          context,
                          l10n.moreBurnedCaloriesWeek,
                          '${(stats['totalBurned'] as double).toStringAsFixed(0)} kcal',
                          Icons.fitness_center,
                          Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildStatsCard(
                          context,
                          l10n.moreWaterWeek,
                          '${(stats['totalWater'] as double).toStringAsFixed(0)} ml',
                          Icons.water_drop,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.moreCaloriesDuringWeek,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _buildWeeklyChart(stats['dailyCalories'] as List<double>),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.moreMacrosWeek,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMacroCard(
                    context,
                    stats['totalProtein'] as double,
                    stats['totalFat'] as double,
                    stats['totalCarbs'] as double,
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
              Text(l10n.moreErrorWithDetails(error: error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(weeklyStatsProvider);
                  ref.invalidate(goalVerificationProvider);
                },
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSection(AsyncValue<GoalVerificationResult> verificationAsync) {
    return verificationAsync.when(
      data: (v) => _VerificationCard(
        result: v,
        isApplying: _isApplyingVerification,
        onApply: () => _applyVerification(v),
        onRefresh: () {
          ref.invalidate(goalVerificationProvider);
          ref.invalidate(weeklyStatsProvider);
        },
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Future<void> _applyVerification(GoalVerificationResult v) async {
    if (v.profile == null || v.correctedTargetCalories == null) return;
    final l10n = context.l10n;

    setState(() => _isApplyingVerification = true);

    try {
      final macros = Calculations.calculateMacrosFromCalories(
        targetCalories: v.correctedTargetCalories!,
        targetWeightKg: v.profile!.targetWeightKg,
      );

      final updatedProfile = v.profile!.copyWith(
        targetCalories: v.correctedTargetCalories,
        targetProteinG: macros['protein'],
        targetFatG: macros['fat'],
        targetCarbsG: macros['carbs'],
      );

      final service = SupabaseService();
      await service.updateProfile(updatedProfile);

      try {
        await service.saveGoalHistory(
          userId: v.profile!.userId,
          oldTargetCalories: v.currentTargetCalories,
          newTargetCalories: v.correctedTargetCalories,
          reason: l10n.moreGoalHistoryReason,
        );
      } catch (_) {
        // Ignoruj błąd historii – profil został zaktualizowany
      }

      ref.invalidate(goalVerificationProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(dashboardDataProvider(DateTime.now()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.moreGoalUpdated(
                calories: v.correctedTargetCalories!.toStringAsFixed(0),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.moreErrorWithDetails(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplyingVerification = false);
    }
  }

  Widget _buildStatsCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<double> dailyCalories) {
    final l10n = context.l10n;
    final maxCalories = dailyCalories.reduce((a, b) => a > b ? a : b);
    // Zaokrąglenie do 500 w górę + 20% margines – unika nakładania się etykiet (np. 6000 i 6131)
    final rawMax = (maxCalories * 1.2).ceilToDouble();
    final chartMax = (rawMax / 500).ceil() * 500.0;
    final interval = chartMax <= 2000 ? 500.0 : 1000.0;

    final days = [
      l10n.moreDayMon,
      l10n.moreDayTue,
      l10n.moreDayWed,
      l10n.moreDayThu,
      l10n.moreDayFri,
      l10n.moreDaySat,
      l10n.moreDaySun,
    ];
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayLabel = groupIndex < days.length ? days[groupIndex] : '${groupIndex + 1}';
              return BarTooltipItem(
                '$dayLabel: ${rod.toY.toStringAsFixed(0)} kcal',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
            getTooltipColor: (_) => Colors.orange.shade800,
            tooltipRoundedRadius: 8,
          ),
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: chartMax,
        barGroups: dailyCalories.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.orange,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context, double protein, double fat, double carbs) {
    final l10n = context.l10n;
    final total = protein + fat + carbs;
    final proteinPercent = (total > 0 ? (protein / total * 100) : 0).toDouble();
    final fatPercent = (total > 0 ? (fat / total * 100) : 0).toDouble();
    final carbsPercent = (total > 0 ? (carbs / total * 100) : 0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroStat(context, l10n.moreProtein, protein.toDouble(), proteinPercent, Colors.blue),
                _buildMacroStat(context, l10n.moreFat, fat.toDouble(), fatPercent, Colors.orange),
                _buildMacroStat(context, l10n.moreCarbs, carbs.toDouble(), carbsPercent, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: (proteinPercent * 10).toInt().clamp(1, 1000),
                  child: Container(
                    height: 8,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  flex: (fatPercent * 10).toInt().clamp(1, 1000),
                  child: Container(
                    height: 8,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  flex: (carbsPercent * 10).toInt().clamp(1, 1000),
                  child: Container(
                    height: 8,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroStat(BuildContext context, String label, double value, double percent, Color color) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(0)}g',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final GoalVerificationResult result;
  final bool isApplying;
  final VoidCallback onApply;
  final VoidCallback onRefresh;

  const _VerificationCard({
    required this.result,
    required this.isApplying,
    required this.onApply,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final surface = Theme.of(context).colorScheme.surface;
    final weightChange = result.weightChangeKg == 0
        ? l10n.moreWeightStable
        : result.weightChangeKg > 0
            ? l10n.moreWeightIncrease(kg: result.weightChangeKg.toStringAsFixed(1))
            : l10n.moreWeightDecrease(kg: result.weightChangeKg.toStringAsFixed(1));

    return Material(
      color: surface,
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.moreGoalVerification,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!result.hasEnoughData) ...[
              Text(
                l10n.moreGoalVerificationHint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.moreProgressDaysWithData(days: result.daysWithData),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.daysWithData / 7,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
            ] else if (result.suggestionText != null) ...[
              Text(
                l10n.moreBasedOnLast7Days,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.moreAvgCaloriesPerDayBullet(
                  calories: result.avgDailyCalories.toStringAsFixed(0),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                l10n.moreWeightBullet(change: weightChange),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                result.suggestionText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isApplying ? null : onApply,
                  icon: isApplying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(isApplying ? l10n.moreSaving : l10n.moreApplyCorrectedGoal),
                ),
              ),
            ] else ...[
              Text(
                l10n.moreGoalAligned,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (result.realTDEE != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.moreRealTdee(
                      calories: result.realTDEE!.toStringAsFixed(0),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
