import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/meal.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/utils/streak_updater.dart';

/// Ekran dodawania posiłku po zeskanowaniu kodu - użytkownik wpisuje wagę,
/// kalorie i makroskładniki przeliczają się automatycznie na podstawie danych z Open Food Facts.
class BarcodeProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final DateTime? date;

  const BarcodeProductScreen({super.key, required this.product, this.date});

  @override
  State<BarcodeProductScreen> createState() => _BarcodeProductScreenState();
}

class _BarcodeProductScreenState extends State<BarcodeProductScreen> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  double get _calPer100 => (widget.product['calories'] as num?)?.toDouble() ?? 0.0;
  double get _proteinPer100 => (widget.product['proteinG'] as num?)?.toDouble() ?? 0.0;
  double get _fatPer100 => (widget.product['fatG'] as num?)?.toDouble() ?? 0.0;
  double get _carbsPer100 => (widget.product['carbsG'] as num?)?.toDouble() ?? 0.0;

  /// Przelicza wartości na podstawie wagi (na 100g -> na porcję)
  double? get _weightG => double.tryParse(_weightController.text);
  double get _totalCalories =>
      _weightG != null && _weightG! > 0 ? (_weightG! / 100) * _calPer100 : 0.0;
  double get _totalProtein =>
      _weightG != null && _weightG! > 0 ? (_weightG! / 100) * _proteinPer100 : 0.0;
  double get _totalFat =>
      _weightG != null && _weightG! > 0 ? (_weightG! / 100) * _fatPer100 : 0.0;
  double get _totalCarbs =>
      _weightG != null && _weightG! > 0 ? (_weightG! / 100) * _carbsPer100 : 0.0;

  DateTime get _effectiveCreatedAt {
    final d = widget.date ?? DateTime.now();
    return DateTime(d.year, d.month, d.day, 12, 0);
  }

  @override
  void initState() {
    super.initState();
    _weightController.addListener(() => setState(() {}));
    final prefilledWeight = widget.product['weightG'] as double?;
    if (prefilledWeight != null && prefilledWeight > 0) {
      _weightController.text = prefilledWeight.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveDirectly() async {
    if (_weightG == null || _weightG! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trackEnterProductWeight)),
      );
      return;
    }

    setState(() => _isSaving = true);
    final l10n = context.l10n;
    final defaultMealName = l10n.trackDefaultMealName;
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.trackUserNotLoggedIn);

      await StreakUpdater.updateStreak(
        userId,
        AppConstants.streakMeals,
        widget.date ?? DateTime.now(),
      );

      final meal = Meal(
        userId: userId,
        name: widget.product['name'] as String? ?? defaultMealName,
        calories: _totalCalories,
        proteinG: _totalProtein,
        fatG: _totalFat,
        carbsG: _totalCarbs,
        saturatedFatG: 0,
        sugarG: 0,
        fiberG: 0,
        saltG: 0,
        weightG: _weightG,
        source: AppConstants.mealSourceBarcode,
        createdAt: _effectiveCreatedAt,
      );

      await SupabaseService().createMeal(meal);

      if (!mounted) return;
      context.pop(true);
      SuccessMessage.show(context, l10n.trackMealAddedSuccess, l10n: l10n);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showSnackBar(context, l10n: l10n, error: e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openEditScreen() {
    if (_weightG == null || _weightG! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trackEnterProductWeight)),
      );
      return;
    }

    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) {
      ErrorHandler.showSnackBar(
        context,
        l10n: context.l10n,
        error: Exception(context.l10n.trackUserNotLoggedIn),
      );
      return;
    }

    context.push(AppRoutes.mealsAdd, extra: Meal(
      userId: userId,
      name: widget.product['name'] as String? ?? context.l10n.trackDefaultMealName,
      calories: _totalCalories,
      proteinG: _totalProtein,
      fatG: _totalFat,
      carbsG: _totalCarbs,
      saturatedFatG: 0,
      sugarG: 0,
      fiberG: 0,
      saltG: 0,
      weightG: _weightG,
      source: AppConstants.mealSourceBarcode,
      createdAt: _effectiveCreatedAt,
    )).then((result) {
      if (result == true && mounted) context.pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackAddProduct),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'] as String? ?? l10n.trackProduct,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.product['brand'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.trackBrand(brand: '${widget.product['brand']}'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.trackNutritionPer100g,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPer100Item('kcal', _calPer100.toStringAsFixed(0)),
                    _buildPer100Item(l10n.trackMacroAbbrevProtein, _proteinPer100.toStringAsFixed(1)),
                    _buildPer100Item(l10n.trackMacroAbbrevFat, _fatPer100.toStringAsFixed(1)),
                    _buildPer100Item(l10n.trackMacroAbbrevCarbs, _carbsPer100.toStringAsFixed(1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: l10n.trackWeightGRequired,
                hintText: l10n.trackWeightHintExample,
                helperText: l10n.trackWeightHelper,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                final w = double.tryParse(v ?? '');
                if (w == null || w <= 0) return l10n.trackEnterProductWeight;
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_weightG != null && _weightG! > 0) ...[
              Text(
                l10n.trackYourPortion,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTotalItem(context, 'kcal', _totalCalories.toStringAsFixed(0)),
                      _buildTotalItem(context, l10n.trackProtein, _totalProtein.toStringAsFixed(1)),
                      _buildTotalItem(context, l10n.trackFat, _totalFat.toStringAsFixed(1)),
                      _buildTotalItem(context, l10n.trackCarbsShort, _totalCarbs.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDirectly,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(l10n.trackAddMeal),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSaving ? null : _openEditScreen,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(l10n.trackEditBeforeSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPer100Item(String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text('$label/100g', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTotalItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }
}
