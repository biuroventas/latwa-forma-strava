import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/calculations.dart';
import '../../../shared/models/user_profile.dart';
import '../../weight/screens/weight_tracking_screen.dart';

class BMICalculatorScreen extends ConsumerWidget {
  final UserProfile? profile;

  const BMICalculatorScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double? bmi;
    String? category;
    Color? categoryColor;

    final latestWeightAsync = ref.watch(latestWeightKgProvider);
    final weight = latestWeightAsync.valueOrNull ?? profile?.currentWeightKg;
    final height = profile?.heightCm;
    if (weight != null && height != null) {
      bmi = Calculations.calculateBMI(
        weightKg: weight,
        heightCm: height,
      );
      category = _getBMICategory(bmi);
      categoryColor = _getBMIColor(bmi);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bmi != null && weight != null && height != null) ...[
              Card(
                color: categoryColor?.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Twoje BMI',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Obliczono na podstawie:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Aktualna waga: ${weight.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '• Wzrost: ${height.toStringAsFixed(0)} cm',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (ctx) {
                                final (minKg, maxKg) = Calculations.weightRangeForNormalBMI(height);
                                return Text(
                                  'Aby być w normie (BMI 18,5–24,9), dąż do wagi w przedziale od ${minKg.toStringAsFixed(1)} do ${maxKg.toStringAsFixed(1)} kg.',
                                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Uzupełnij profil (waga i wzrost), aby zobaczyć swoje BMI',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Skala BMI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildBMIRange(context, 'Niedowaga', '< 18.5', Colors.blue),
            _buildBMIRange(context, 'Normalna', '18.5 - 24.9', Colors.green),
            _buildBMIRange(context, 'Nadwaga', '25.0 - 29.9', Colors.orange),
            _buildBMIRange(context, 'Otyłość I stopnia', '30.0 - 34.9', Colors.red),
            _buildBMIRange(context, 'Otyłość II stopnia', '35.0 - 39.9', Colors.red.shade700),
            _buildBMIRange(context, 'Otyłość III stopnia', '≥ 40.0', Colors.red.shade900),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wzór BMI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMI = waga (kg) / wzrost (m)²',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMI to wskaźnik masy ciała, który pomaga ocenić, czy waga jest odpowiednia do wzrostu.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIRange(BuildContext context, String label, String range, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(label),
        trailing: Text(
          range,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Niedowaga';
    if (bmi < 25) return 'Normalna';
    if (bmi < 30) return 'Nadwaga';
    if (bmi < 35) return 'Otyłość I stopnia';
    if (bmi < 40) return 'Otyłość II stopnia';
    return 'Otyłość III stopnia';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    if (bmi < 35) return Colors.red;
    if (bmi < 40) return Colors.red.shade700;
    return Colors.red.shade900;
  }
}
