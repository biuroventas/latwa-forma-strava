import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/utils/calculations.dart';
import '../../../shared/models/user_profile.dart';
import '../../weight/screens/weight_tracking_screen.dart';

class BMICalculatorScreen extends ConsumerWidget {
  final UserProfile? profile;

  const BMICalculatorScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
      category = _getBMICategory(l10n, bmi);
      categoryColor = _getBMIColor(bmi);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreBmiCalculatorTitle),
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
                        l10n.moreYourBmi,
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
                              l10n.moreCalculatedBasedOn,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.moreCurrentWeightBullet(weight: weight.toStringAsFixed(1)),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              l10n.moreHeightBullet(height: height.toStringAsFixed(0)),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (ctx) {
                                final (minKg, maxKg) = Calculations.weightRangeForNormalBMI(height);
                                return Text(
                                  ctx.l10n.moreNormalBmiRangeHint(
                                    minKg: minKg.toStringAsFixed(1),
                                    maxKg: maxKg.toStringAsFixed(1),
                                  ),
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
                    l10n.moreCompleteProfileForBmi,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              l10n.moreBmiScale,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildBMIRange(context, l10n.moreBmiUnderweight, '< 18.5', Colors.blue),
            _buildBMIRange(context, l10n.moreBmiNormal, '18.5 - 24.9', Colors.green),
            _buildBMIRange(context, l10n.moreBmiOverweight, '25.0 - 29.9', Colors.orange),
            _buildBMIRange(context, l10n.moreBmiObesity1, '30.0 - 34.9', Colors.red),
            _buildBMIRange(context, l10n.moreBmiObesity2, '35.0 - 39.9', Colors.red.shade700),
            _buildBMIRange(context, l10n.moreBmiObesity3, '≥ 40.0', Colors.red.shade900),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.moreBmiFormulaTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.moreBmiFormula,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.moreBmiExplanation,
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

  String _getBMICategory(AppLocalizations l10n, double bmi) {
    if (bmi < 18.5) return l10n.moreBmiUnderweight;
    if (bmi < 25) return l10n.moreBmiNormal;
    if (bmi < 30) return l10n.moreBmiOverweight;
    if (bmi < 35) return l10n.moreBmiObesity1;
    if (bmi < 40) return l10n.moreBmiObesity2;
    return l10n.moreBmiObesity3;
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
