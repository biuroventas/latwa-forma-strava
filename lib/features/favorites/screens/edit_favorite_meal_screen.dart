import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/favorite_meal.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';

class EditFavoriteMealScreen extends StatefulWidget {
  final FavoriteMeal favoriteMeal;

  const EditFavoriteMealScreen({super.key, required this.favoriteMeal});

  @override
  State<EditFavoriteMealScreen> createState() => _EditFavoriteMealScreenState();
}

class _EditFavoriteMealScreenState extends State<EditFavoriteMealScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  List<Ingredient> _ingredients = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.favoriteMeal.name);
    _caloriesController = TextEditingController(text: widget.favoriteMeal.calories.toStringAsFixed(0));
    _proteinController = TextEditingController(text: widget.favoriteMeal.proteinG.toStringAsFixed(1));
    _fatController = TextEditingController(text: widget.favoriteMeal.fatG.toStringAsFixed(1));
    _carbsController = TextEditingController(text: widget.favoriteMeal.carbsG.toStringAsFixed(1));
    
    // Wczytaj składniki jeśli istnieją
    if (widget.favoriteMeal.ingredients != null) {
      final ingredientsList = widget.favoriteMeal.ingredients!['ingredients'] as List?;
      if (ingredientsList != null) {
        _ingredients = ingredientsList.map((ing) {
          return Ingredient(
            id: const Uuid().v4(),
            name: ing['name'] as String,
            amountG: (ing['amountG'] as num).toDouble(),
            caloriesPer100G: (ing['caloriesPer100G'] as num).toDouble(),
            proteinPer100G: (ing['proteinPer100G'] as num?)?.toDouble() ?? 0,
            fatPer100G: (ing['fatPer100G'] as num?)?.toDouble() ?? 0,
            carbsPer100G: (ing['carbsPer100G'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final result = await showDialog<Ingredient>(
      context: context,
      builder: (context) => _AddIngredientDialog(),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
        _recalculateFromIngredients();
      });
    }
  }

  void _recalculateFromIngredients() {
    if (_ingredients.isEmpty) return;

    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (var ingredient in _ingredients) {
      totalCalories += ingredient.calories;
      totalProtein += ingredient.proteinG;
      totalFat += ingredient.fatG;
      totalCarbs += ingredient.carbsG;
    }

    setState(() {
      _caloriesController.text = totalCalories.toStringAsFixed(0);
      _proteinController.text = totalProtein.toStringAsFixed(1);
      _fatController.text = totalFat.toStringAsFixed(1);
      _carbsController.text = totalCarbs.toStringAsFixed(1);
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final ingredientsJson = _ingredients.map((ing) => {
        'name': ing.name,
        'amountG': ing.amountG,
        'caloriesPer100G': ing.caloriesPer100G,
        'proteinPer100G': ing.proteinPer100G,
        'fatPer100G': ing.fatPer100G,
        'carbsPer100G': ing.carbsPer100G,
      }).toList();

      final updatedMeal = FavoriteMeal(
        id: widget.favoriteMeal.id,
        userId: userId,
        name: _nameController.text.trim().isEmpty ? AppConstants.defaultMealName : _nameController.text.trim(),
        calories: double.parse(_caloriesController.text),
        proteinG: double.parse(_proteinController.text),
        fatG: double.parse(_fatController.text),
        carbsG: double.parse(_carbsController.text),
        ingredients: {'ingredients': ingredientsJson},
      );

      final service = SupabaseService();
      await service.updateFavoriteMeal(updatedMeal);

      if (mounted) {
        context.pop(true);
        SuccessMessage.show(context, 'Zaktualizowano ulubiony posiłek');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj ulubiony posiłek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa posiłku (opcjonalnie)',
                hintText: 'Puste = "Bez nazwy"',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Kalorie (kcal)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Białko (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: 'Tłuszcze (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Węglowodany (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            if (_ingredients.isNotEmpty) ...[
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.amountG.toStringAsFixed(0)}g'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(index);
                          _recalculateFromIngredients();
                        });
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _recalculateFromIngredients,
                child: const Text('Przelicz z składników'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddIngredientDialog extends StatefulWidget {
  const _AddIngredientDialog();

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
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController(text: '0');
    _fatController = TextEditingController(text: '0');
    _carbsController = TextEditingController(text: '0');
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
      title: const Text('Dodaj składnik'),
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
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj ilość';
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
                id: const Uuid().v4(),
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
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}
