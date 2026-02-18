import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/models/weight_log.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/streak_updater.dart';
import '../../dashboard/screens/dashboard_screen.dart';

final weightLogsProvider = FutureProvider.autoDispose<List<WeightLog>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getWeightLogs(userId, limit: 30); // Ostatnie 30 pomiarów
});

/// Ostatnia (najnowsza) waga z wpisów w statystykach/wadze.
/// Używane m.in. w kalkulatorze BMI do aktualizacji na bieżąco.
final latestWeightKgProvider = FutureProvider.autoDispose<double?>((ref) async {
  final logs = await ref.watch(weightLogsProvider.future);
  if (logs.isEmpty) return null;
  return logs.first.weightKg; // logs są posortowane malejąco po dacie
});

class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen> {
  final _weightController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Domyślnie dzisiaj
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveWeight() async {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj wagę')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 30 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj poprawną wagę (30-300 kg)')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      final weightLog = WeightLog(
        userId: userId,
        weightKg: weight,
        createdAt: _selectedDate,
      );

      final service = SupabaseService();
      await service.createWeightLog(weightLog);
      // Aktualizuj streak dla wagi
      await StreakUpdater.updateStreak(userId, AppConstants.streakWeight, _selectedDate ?? DateTime.now());

      _weightController.clear();
      setState(() {
        _selectedDate = DateTime.now(); // Reset do dzisiaj
      });
      ref.invalidate(weightLogsProvider);
      // Odśwież dashboard
      ref.invalidate(dashboardDataProvider(DateTime.now()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waga zapisana pomyślnie!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightLogsAsync = ref.watch(weightLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waga'),
      ),
      body: weightLogsAsync.when(
        data: (logs) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karta z opisem – nad tłem (surface + cień)
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 1,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Regularne pomiary pomagają trzymać cel. Każdy wpis przybliża Cię do wymarzonej formy!',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Formularz dodawania wagi
                        TextField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Waga (kg)',
                            hintText: 'np. 75.5',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        // Wybór daty
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 2 lata wstecz
                              lastDate: DateTime.now(), // Nie można wybrać przyszłości
                              helpText: 'Wybierz datę pomiaru',
                              cancelText: 'Anuluj',
                              confirmText: 'Wybierz',
                            );
                            if (picked != null) {
                              // Jeśli wybrano datę, ustaw również godzinę (domyślnie 12:00)
                              final dateTime = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                _selectedDate?.hour ?? 12,
                                _selectedDate?.minute ?? 0,
                              );
                              setState(() {
                                _selectedDate = dateTime;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Data pomiaru',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                                  : 'Wybierz datę',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        if (_selectedDate != null && 
                            (_selectedDate!.day != DateTime.now().day ||
                             _selectedDate!.month != DateTime.now().month ||
                             _selectedDate!.year != DateTime.now().year))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Pomiar zostanie zapisany z wybraną datą',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveWeight,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator()
                                : const Text('Zapisz wagę'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Wykres
                if (logs.isNotEmpty) ...[
                  Text(
                    'Historia wagi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildWeightChart(logs),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lista ostatnich pomiarów
                  Text(
                    'Ostatnie pomiary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...logs.take(10).map((log) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.monitor_weight, color: Colors.blue),
                          title: Text('${log.weightKg.toStringAsFixed(1)} kg'),
                          subtitle: Text(
                            log.createdAt != null
                                ? _formatDate(log.createdAt!)
                                : 'Brak daty',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Usuń pomiar'),
                                  content: Text(
                                    'Czy na pewno chcesz usunąć pomiar ${log.weightKg.toStringAsFixed(1)} kg?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: const Text('Anuluj'),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Usuń'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && log.id != null) {
                                try {
                                  final service = SupabaseService();
                                  await service.deleteWeightLog(log.id!);
                                  if (context.mounted) {
                                    ref.invalidate(weightLogsProvider);
                                    ref.invalidate(dashboardDataProvider(DateTime.now()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pomiar usunięty')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Błąd: $e')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      )),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.monitor_weight_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Brak pomiarów wagi',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dodaj pierwszy pomiar, aby zobaczyć historię',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                onPressed: () => ref.invalidate(weightLogsProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<WeightLog> logs) {
    if (logs.isEmpty) {
      return const Center(child: Text('Brak danych do wyświetlenia'));
    }

    // Sortuj po dacie (od najstarszych)
    final sortedLogs = List<WeightLog>.from(logs)..sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    final minWeight = sortedLogs.map((l) => l.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedLogs.map((l) => l.weightKg).reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final chartMin = (minWeight - range * 0.1).clamp(0, double.infinity);
    final chartMax = maxWeight + range * 0.1;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= sortedLogs.length) return LineTooltipItem('', const TextStyle());
              final log = sortedLogs[idx];
              final dateStr = log.createdAt != null
                  ? '${log.createdAt!.day}.${log.createdAt!.month}.${log.createdAt!.year}'
                  : '-';
              return LineTooltipItem(
                '$dateStr: ${log.weightKg.toStringAsFixed(1)} kg',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
            getTooltipColor: (_) => Theme.of(context).colorScheme.primary,
            tooltipRoundedRadius: 8,
          ),
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
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
                if (value.toInt() >= sortedLogs.length) return const Text('');
                final log = sortedLogs[value.toInt()];
                if (log.createdAt == null) return const Text('');
                return Text(
                  '${log.createdAt!.day}/${log.createdAt!.month}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (sortedLogs.length - 1).toDouble(),
        minY: chartMin.toDouble(),
        maxY: chartMax.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: sortedLogs.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.weightKg.toDouble());
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
