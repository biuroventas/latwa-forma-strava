import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/models/water_log.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/streak_updater.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../core/providers/profile_provider.dart';

final waterLogsForDateProvider = FutureProvider.autoDispose.family<List<WaterLog>, DateTime>((ref, date) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');
  final service = SupabaseService();
  return await service.getWaterLogs(userId, date: date);
});

final totalWaterForDateProvider = FutureProvider.autoDispose.family<double, DateTime>((ref, date) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');
  final service = SupabaseService();
  return await service.getTotalWaterForDate(userId, date);
});

class WaterTrackingScreen extends ConsumerStatefulWidget {
  const WaterTrackingScreen({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  ConsumerState<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends ConsumerState<WaterTrackingScreen> {
  late DateTime _displayedDate;

  @override
  void initState() {
    super.initState();
    _displayedDate = widget.initialDate;
  }

  bool get _isToday {
    final now = DateTime.now();
    return _displayedDate.year == now.year &&
        _displayedDate.month == now.month &&
        _displayedDate.day == now.day;
  }

  Future<void> _addWater(WidgetRef ref, BuildContext? context, double amount) async {
    if (!_isToday) return;
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('Użytkownik nie jest zalogowany');

      final waterLog = WaterLog(
        userId: userId,
        amountMl: amount,
        createdAt: DateTime.now(),
      );

      final service = SupabaseService();
      await service.createWaterLog(waterLog);
      await StreakUpdater.updateStreak(userId, AppConstants.streakWater, DateTime.now());

      ref.invalidate(waterLogsForDateProvider(_displayedDate));
      ref.invalidate(totalWaterForDateProvider(_displayedDate));
      ref.invalidate(dashboardDataProvider(_displayedDate));

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dodano ${amount.toStringAsFixed(0)} ml wody')),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas dodawania wody: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateWater(WidgetRef ref, WaterLog log, double newAmount) async {
    try {
      final service = SupabaseService();
      await service.updateWaterLog(WaterLog(
        id: log.id,
        userId: log.userId,
        amountMl: newAmount,
        createdAt: log.createdAt,
      ));
      ref.invalidate(waterLogsForDateProvider(_displayedDate));
      ref.invalidate(totalWaterForDateProvider(_displayedDate));
      ref.invalidate(dashboardDataProvider(_displayedDate));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zaktualizowano: ${newAmount.toStringAsFixed(0)} ml')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas aktualizacji: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteWater(WidgetRef ref, WaterLog log) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Usuń wpis',
      content: 'Czy na pewno chcesz usunąć wpis ${log.amountMl.toStringAsFixed(0)} ml?',
    );
    if (!confirmed || !mounted) return;
    try {
      final service = SupabaseService();
      await service.deleteWaterLog(log.id!);
      ref.invalidate(waterLogsForDateProvider(_displayedDate));
      ref.invalidate(totalWaterForDateProvider(_displayedDate));
      ref.invalidate(dashboardDataProvider(_displayedDate));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wpis usunięty')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas usuwania: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, WaterLog log) {
    final controller = TextEditingController(text: log.amountMl.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edytuj ilość'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ilość (ml)',
            hintText: '1–5000 ml',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 1 && amount <= 5000) {
                context.pop();
                _updateWater(ref, log, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ilość musi być od 1 do 5000 ml'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dodaj wodę'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Ilość (ml)',
                hintText: 'np. 250',
                helperText: 'Maksymalnie 5000 ml na jeden wpis',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 1 && amount <= 5000) {
                context.pop();
                _addWater(ref, context, amount);
              } else if (amount != null && amount > 5000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maksymalna ilość to 5000 ml na wpis'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Podaj ilość od 1 do 5000 ml'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditGoalDialog(BuildContext context, WidgetRef ref, double currentGoal) async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) return;
    final controller = TextEditingController(text: currentGoal.toStringAsFixed(0));
    if (!context.mounted) return;
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cel dzienny picia wody'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Cel (ml)',
                hintText: 'np. 2000',
                helperText: 'Zalecane jest min. 2l',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '.'));
              if (v != null && v >= 500 && v <= 10000) {
                Navigator.of(ctx).pop(v);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Podaj wartość od 500 do 10000 ml'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    try {
      final updated = profile.copyWith(waterGoalMl: value);
      await SupabaseService().updateProfile(updated);
      if (!context.mounted) return;
      ref.invalidate(profileProvider);
      ref.invalidate(dashboardDataProvider(DateTime.now()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cel wody zaktualizowany')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final totalWater = ref.watch(totalWaterForDateProvider(_displayedDate));
    final waterLogs = ref.watch(waterLogsForDateProvider(_displayedDate));
    final profile = ref.watch(profileProvider).valueOrNull;
    final waterGoal = profile?.waterGoalMl ?? AppConstants.defaultWaterGoal;

    final now = DateTime.now();
    final canGoNext = () {
      final next = _displayedDate.add(const Duration(days: 1));
      final nextDay = DateTime(next.year, next.month, next.day);
      final todayDay = DateTime(now.year, now.month, now.day);
      return !nextDay.isAfter(todayDay);
    }();

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
                        lastDate: now,
                      );
                      if (picked != null && mounted) setState(() => _displayedDate = picked);
                    },
                    child: Text(_isToday ? 'Woda – Dzisiaj' : 'Woda – ${_formatDate(_displayedDate)}'),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext
                  ? () => setState(() => _displayedDate = _displayedDate.add(const Duration(days: 1)))
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Zmień cel dzienny picia wody',
              onPressed: () => _showEditGoalDialog(context, ref, waterGoal),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(waterLogsForDateProvider(_displayedDate));
          ref.invalidate(totalWaterForDateProvider(_displayedDate));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(
                      width: 4,
                      color: Colors.blue.shade400,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop, size: 44, color: Colors.blue.shade500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Każda kropla się liczy!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Nawodnienie to podstawa formy.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      totalWater.when(
                        data: (total) {
                          final percentage = (total / waterGoal * 100).clamp(0, 100);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${total.toStringAsFixed(0)} / ${waterGoal.toStringAsFixed(0)} ml',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey.shade200,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (error, stackTrace) => Text('Błąd: $error', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isToday) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildWaterChip(context, ref, 100),
                    _buildWaterChip(context, ref, 200),
                    _buildWaterChip(context, ref, 250),
                    _buildWaterChip(context, ref, 350),
                    _buildWaterChip(context, ref, 500),
                    ActionChip(
                      avatar: Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.primary),
                      label: const Text('Własna'),
                      onPressed: () => _showCustomAmountDialog(context, ref),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Przegląd – edycja i usuwanie możliwe. Dodawanie tylko na dzisiaj.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Wpisy',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              waterLogs.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        _isToday ? 'Brak wpisów' : 'Brak wpisów',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Column(
                    children: logs.map((log) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          elevation: 1,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.water_drop, size: 20, color: Colors.blue.shade400),
                            title: Text(
                              '${log.amountMl.toStringAsFixed(0)} ml',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(6),
                                    minimumSize: const Size(36, 36),
                                  ),
                                  tooltip: 'Edytuj',
                                  onPressed: () => _showEditDialog(context, ref, log),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(6),
                                    minimumSize: const Size(36, 36),
                                  ),
                                  tooltip: 'Usuń',
                                  onPressed: () => _deleteWater(ref, log),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Błąd: $error', style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterChip(BuildContext context, WidgetRef ref, double amount) {
    return ActionChip(
      avatar: Icon(Icons.water_drop, size: 16, color: Theme.of(context).colorScheme.primary),
      label: Text('${amount.toStringAsFixed(0)} ml'),
      onPressed: () => _addWater(ref, context, amount),
    );
  }
}
