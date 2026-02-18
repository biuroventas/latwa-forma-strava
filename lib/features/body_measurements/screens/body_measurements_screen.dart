import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/models/body_measurement.dart';

final bodyMeasurementsProvider = FutureProvider.autoDispose.family<List<BodyMeasurement>, String>((ref, type) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getBodyMeasurements(userId, measurementType: type, limit: 30);
});

class BodyMeasurementsScreen extends ConsumerStatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  ConsumerState<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends ConsumerState<BodyMeasurementsScreen> {
  final _valueController = TextEditingController();
  final _customTypeController = TextEditingController();
  String _selectedType = 'waist';
  DateTime? _selectedDate;
  bool _isSaving = false;
  bool _isCustomType = false;

  final List<Map<String, String>> _measurementTypes = [
    {'value': 'waist', 'label': 'Talia'},
    {'value': 'hips', 'label': 'Biodra'},
    {'value': 'chest', 'label': 'Klatka piersiowa'},
    {'value': 'arm', 'label': 'Ramię'},
    {'value': 'thigh', 'label': 'Udo'},
    {'value': 'custom', 'label': 'Własny'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Domyślnie dzisiaj
  }

  String get _effectiveType {
    if (_isCustomType) {
      final custom = _customTypeController.text.trim();
      if (custom.isEmpty) return 'custom'; // placeholder – nie zapisuj
      return custom.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    }
    return _selectedType;
  }

  String get _effectiveLabel {
    if (_isCustomType && _customTypeController.text.trim().isNotEmpty) {
      return _customTypeController.text.trim();
    }
    return _measurementTypes.firstWhere(
      (t) => t['value'] == _selectedType,
      orElse: () => {'label': _selectedType},
    )['label']!;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (_valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj wartość pomiaru')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj poprawną wartość (większą od 0)')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      final typeToSave = _effectiveType;
      if (_isCustomType && typeToSave == 'custom') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wpisz nazwę własnego typu pomiaru (np. biceps)')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final measurement = BodyMeasurement(
        userId: userId,
        measurementType: typeToSave,
        valueCm: value,
        createdAt: _selectedDate,
      );

      final service = SupabaseService();
      await service.createBodyMeasurement(measurement);

      _valueController.clear();
      setState(() {
        _selectedDate = DateTime.now(); // Reset do dzisiaj
      });
      ref.invalidate(bodyMeasurementsProvider(_selectedType));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pomiar zapisany pomyślnie!')),
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
    final measurementsAsync = ref.watch(bodyMeasurementsProvider(_effectiveType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomiary ciała'),
      ),
      body: measurementsAsync.when(
        data: (measurements) {
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
                          'Śledź wymiary regularnie — każdy pomiar to dowód Twojego postępu i krok do wymarzonej sylwetki!',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Wybór typu pomiaru
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Typ pomiaru',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          items: _measurementTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Text(type['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                                _isCustomType = value == 'custom';
                                if (!_isCustomType) _customTypeController.clear();
                                _valueController.clear();
                              });
                              ref.invalidate(bodyMeasurementsProvider(_effectiveType));
                            }
                          },
                        ),
                        if (_isCustomType) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Nazwa pomiaru',
                              hintText: 'np. Biceps, Brzuch',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.edit),
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Formularz dodawania pomiaru
                        TextField(
                          controller: _valueController,
                          decoration: const InputDecoration(
                            labelText: 'Wartość (cm)',
                            hintText: 'np. 85.5',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
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
                            onPressed: _isSaving ? null : _saveMeasurement,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator()
                                : const Text('Zapisz pomiar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Wykres
                if (measurements.isNotEmpty) ...[
                  Text(
                    'Historia pomiarów - $_effectiveLabel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildMeasurementChart(measurements),
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
                  ...measurements.take(10).map((measurement) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.straighten, color: Colors.blue),
                          title: Text('${measurement.valueCm.toStringAsFixed(1)} cm'),
                          subtitle: Text(
                            measurement.createdAt != null
                                ? _formatDate(measurement.createdAt!)
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
                                    'Czy na pewno chcesz usunąć pomiar ${measurement.valueCm.toStringAsFixed(1)} cm?',
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

                              if (confirmed == true && measurement.id != null) {
                                try {
                                  final service = SupabaseService();
                                  await service.deleteBodyMeasurement(measurement.id!);
                                  if (context.mounted) {
                                    ref.invalidate(bodyMeasurementsProvider(_effectiveType));
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
                            Icons.straighten_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Brak pomiarów',
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
                onPressed: () => ref.invalidate(bodyMeasurementsProvider(_effectiveType)),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementChart(List<BodyMeasurement> measurements) {
    if (measurements.isEmpty) {
      return const Center(child: Text('Brak danych do wyświetlenia'));
    }

    // Sortuj po dacie (od najstarszych)
    final sortedMeasurements = List<BodyMeasurement>.from(measurements)..sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    final minValue = sortedMeasurements.map((m) => m.valueCm).reduce((a, b) => a < b ? a : b);
    final maxValue = sortedMeasurements.map((m) => m.valueCm).reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final chartMin = (minValue - range * 0.1).clamp(0, double.infinity);
    final chartMax = maxValue + range * 0.1;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= sortedMeasurements.length) return LineTooltipItem('', const TextStyle());
              final m = sortedMeasurements[idx];
              final dateStr = m.createdAt != null
                  ? '${m.createdAt!.day}.${m.createdAt!.month}.${m.createdAt!.year}'
                  : '-';
              return LineTooltipItem(
                '$dateStr: ${m.valueCm.toStringAsFixed(1)} cm',
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
                if (value.toInt() >= sortedMeasurements.length) return const Text('');
                final measurement = sortedMeasurements[value.toInt()];
                if (measurement.createdAt == null) return const Text('');
                return Text(
                  '${measurement.createdAt!.day}/${measurement.createdAt!.month}',
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
        maxX: (sortedMeasurements.length - 1).toDouble(),
        minY: chartMin.toDouble(),
        maxY: chartMax.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: sortedMeasurements.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.valueCm.toDouble());
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
