import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/models/meal.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';

class IngredientsMealScreen extends StatefulWidget {
  const IngredientsMealScreen({super.key});

  @override
  State<IngredientsMealScreen> createState() => _IngredientsMealScreenState();
}

class _IngredientsMealScreenState extends State<IngredientsMealScreen> {
  final List<Ingredient> _ingredients = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _mealType;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Oblicz sumę wartości odżywczych ze wszystkich składników
  Map<String, double> _calculateTotals() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    double totalWeight = 0;

    for (var ingredient in _ingredients) {
      totalCalories += ingredient.calories;
      totalProtein += ingredient.proteinG;
      totalFat += ingredient.fatG;
      totalCarbs += ingredient.carbsG;
      totalWeight += ingredient.amountG;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
      'weight': totalWeight,
    };
  }

  Future<void> _addIngredient() async {
    final result = await showDialog<Ingredient>(
      context: context,
      builder: (context) => _AddIngredientDialog(),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
      });
    }
  }

  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final result = await showDialog<Ingredient>(
      context: context,
      builder: (context) => _AddIngredientDialog(ingredient: ingredient),
    );

    if (result != null) {
      setState(() {
        _ingredients[index] = result;
      });
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj przynajmniej jeden składnik')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      final totals = _calculateTotals();
      final service = SupabaseService();

      final meal = Meal(
        userId: userId,
        name: _nameController.text.trim().isEmpty ? AppConstants.defaultMealName : _nameController.text.trim(),
        calories: totals['calories']!,
        proteinG: totals['protein']!,
        fatG: totals['fat']!,
        carbsG: totals['carbs']!,
        weightG: totals['weight']!,
        mealType: _mealType,
        source: AppConstants.mealSourceIngredients,
      );

      await service.createMeal(meal);

      if (mounted) {
        context.pop(true);
        SuccessMessage.show(context, 'Posiłek dodany pomyślnie!', duration: const Duration(seconds: 2));
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, error: e);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posiłek ze składników'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Nazwa posiłku
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa posiłku (opcjonalnie)',
                      hintText: 'Puste = "Bez nazwy"',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Typ posiłku
                  DropdownButtonFormField<String>(
                    initialValue: _mealType,
                    decoration: const InputDecoration(
                      labelText: 'Typ posiłku - opcjonalnie',
                    ),
                    items: const [
                      DropdownMenuItem(value: AppConstants.mealBreakfast, child: Text('Śniadanie')),
                      DropdownMenuItem(value: AppConstants.mealLunch, child: Text('Obiad')),
                      DropdownMenuItem(value: AppConstants.mealDinner, child: Text('Kolacja')),
                      DropdownMenuItem(value: AppConstants.mealSnack, child: Text('Przekąska')),
                    ],
                    onChanged: (value) {
                      setState(() => _mealType = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Podsumowanie
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Podsumowanie',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Kalorie', totals['calories']!.toStringAsFixed(0), 'kcal'),
                              _buildSummaryItem('Białko', totals['protein']!.toStringAsFixed(1), 'g'),
                              _buildSummaryItem('Tłuszcze', totals['fat']!.toStringAsFixed(1), 'g'),
                              _buildSummaryItem('Węgle', totals['carbs']!.toStringAsFixed(1), 'g'),
                            ],
                          ),
                          if (totals['weight']! > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Całkowita waga: ${totals['weight']!.toStringAsFixed(0)} g',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lista składników
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Składniki (${_ingredients.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add),
                        label: const Text('Dodaj składnik'),
                      ),
                    ],
                  ),
                  if (_ingredients.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Brak składników',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dodaj składniki, aby zbudować posiłek',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(ingredient.name),
                          subtitle: Text(
                            '${ingredient.amountG.toStringAsFixed(0)}g • '
                            '${ingredient.calories.toStringAsFixed(0)} kcal',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editIngredient(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _ingredients.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            // Przycisk zapisu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMeal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Zapisz posiłek',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
}

class _AddIngredientDialog extends StatefulWidget {
  final Ingredient? ingredient;

  const _AddIngredientDialog({this.ingredient});

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  bool _caloriesManuallyEdited = false;
  bool _isUpdatingCaloriesFromMacros = false;

  double? _calculateCaloriesFromMacros() {
    final p = double.tryParse(_proteinController.text) ?? 0;
    final f = double.tryParse(_fatController.text) ?? 0;
    final c = double.tryParse(_carbsController.text) ?? 0;
    if (p == 0 && f == 0 && c == 0) return null;
    return (p * 4) + (f * 9) + (c * 4);
  }

  void _updateCaloriesFromMacros() {
    if (_caloriesManuallyEdited) return;
    final calculated = _calculateCaloriesFromMacros();
    if (calculated != null && calculated > 0) {
      _isUpdatingCaloriesFromMacros = true;
      _caloriesController.text = calculated.toStringAsFixed(0);
      _isUpdatingCaloriesFromMacros = false;
    }
  }

  double _getCalories() {
    final fromField = double.tryParse(_caloriesController.text);
    if (fromField != null && fromField >= 0) return fromField;
    return _calculateCaloriesFromMacros() ?? 0;
  }

  @override
  void initState() {
    super.initState();
    final ing = widget.ingredient;
    _nameController = TextEditingController(text: ing?.name ?? '');
    _amountController = TextEditingController(text: ing?.amountG.toStringAsFixed(0) ?? '');
    _caloriesController = TextEditingController(text: ing?.caloriesPer100G.toStringAsFixed(0) ?? '');
    _proteinController = TextEditingController(text: ing?.proteinPer100G.toStringAsFixed(1) ?? '0');
    _fatController = TextEditingController(text: ing?.fatPer100G.toStringAsFixed(1) ?? '0');
    _carbsController = TextEditingController(text: ing?.carbsPer100G.toStringAsFixed(1) ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ingredient != null ? 'Edytuj składnik' : 'Dodaj składnik'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 400),
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa składnika (opcjonalnie)',
                  hintText: 'Puste = "Bez nazwy"',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Ilość (g)',
                  hintText: '100',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj ilość';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Podaj poprawną ilość';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Wartości odżywcze (na 100g):',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Kalorie (kcal/100g)',
                  hintText: 'Puste = policzy z makroskładników',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                onChanged: (_) => setState(() {
                  if (!_isUpdatingCaloriesFromMacros) _caloriesManuallyEdited = true;
                }),
                validator: (value) {
                  final calories = value != null && value.isNotEmpty
                      ? double.tryParse(value)
                      : _calculateCaloriesFromMacros();
                  if (calories == null || calories < 0) {
                    return 'Podaj kalorie lub uzupełnij makroskładniki';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Białko (g/100g)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: 'Tłuszcze (g/100g)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                  labelText: 'Węglowodany (g/100g)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final ingredient = Ingredient(
                id: widget.ingredient?.id ?? const Uuid().v4(),
                name: _nameController.text.trim().isEmpty ? AppConstants.defaultMealName : _nameController.text.trim(),
                amountG: double.parse(_amountController.text),
                caloriesPer100G: _getCalories(),
                proteinPer100G: double.tryParse(_proteinController.text) ?? 0,
                fatPer100G: double.tryParse(_fatController.text) ?? 0,
                carbsPer100G: double.tryParse(_carbsController.text) ?? 0,
              );
              context.pop(ingredient);
            }
          },
          child: Text(widget.ingredient != null ? 'Zapisz' : 'Dodaj'),
        ),
      ],
    );
  }
}
