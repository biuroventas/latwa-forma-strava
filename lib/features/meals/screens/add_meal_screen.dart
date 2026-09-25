import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/meal.dart';
import '../../../shared/models/favorite_meal.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/streak_updater.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/services/analytics_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/premium_gate.dart';
import 'eating_out_bottom_sheet.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final Meal? meal;
  final DateTime? date;

  const AddMealScreen({super.key, this.meal, this.date});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  late final TextEditingController _carbsController;
  late final TextEditingController _saturatedFatController;
  late final TextEditingController _sugarController;
  late final TextEditingController _fiberController;
  late final TextEditingController _saltController;
  late final TextEditingController _weightController;
  String? _mealType;
  bool _isLoading = false;
  bool _caloriesManuallyEdited = false;
  bool _isUpdatingCaloriesFromMacros = false;
  bool _addToFavorites = false;
  List<Meal> _recentMeals = [];

  /// Inicjalizacja tekstu: puste gdy brak wartości lub 0, żeby użytkownik nie musiał usuwać "0".
  static String _optionalNum(String? value, bool isDecimal) {
    if (value == null || value.isEmpty) return '';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return '';
    return isDecimal ? n.toStringAsFixed(1) : n.toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameController = TextEditingController(text: meal?.name ?? '');
    _caloriesController = TextEditingController(
      text: (meal != null && meal.calories > 0) ? meal.calories.toStringAsFixed(0) : '',
    );
    _proteinController = TextEditingController(text: meal != null ? _optionalNum(meal.proteinG.toString(), false) : '');
    _fatController = TextEditingController(text: meal != null ? _optionalNum(meal.fatG.toString(), false) : '');
    _carbsController = TextEditingController(text: meal != null ? _optionalNum(meal.carbsG.toString(), false) : '');
    _saturatedFatController = TextEditingController(text: meal != null ? _optionalNum(meal.saturatedFatG.toString(), true) : '');
    _sugarController = TextEditingController(text: meal != null ? _optionalNum(meal.sugarG.toString(), true) : '');
    _fiberController = TextEditingController(text: meal != null ? _optionalNum(meal.fiberG.toString(), true) : '');
    _saltController = TextEditingController(text: meal != null ? _optionalNum(meal.saltG.toString(), true) : '');
    _weightController = TextEditingController(
      text: (meal?.weightG != null && meal!.weightG! > 0) ? meal.weightG!.toStringAsFixed(0) : '',
    );
    _mealType = meal?.mealType;
    if (meal == null) _loadRecentMeals();
  }

  Future<void> _loadRecentMeals() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final meals = await SupabaseService().getRecentDistinctMeals(userId);
      if (mounted) setState(() => _recentMeals = meals);
    } catch (_) {}
  }

  void _applyRecentMeal(Meal meal) {
    _nameController.text = meal.name;
    _caloriesController.text = meal.calories > 0 ? meal.calories.toStringAsFixed(0) : '';
    _proteinController.text = _optionalNum(meal.proteinG.toString(), false);
    _fatController.text = _optionalNum(meal.fatG.toString(), false);
    _carbsController.text = _optionalNum(meal.carbsG.toString(), false);
    _saturatedFatController.text = _optionalNum(meal.saturatedFatG.toString(), true);
    _sugarController.text = _optionalNum(meal.sugarG.toString(), true);
    _fiberController.text = _optionalNum(meal.fiberG.toString(), true);
    _saltController.text = _optionalNum(meal.saltG.toString(), true);
    _weightController.text =
        (meal.weightG != null && meal.weightG! > 0) ? meal.weightG!.toStringAsFixed(0) : '';
    _mealType = meal.mealType;
    _caloriesManuallyEdited = true;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _saturatedFatController.dispose();
    _sugarController.dispose();
    _fiberController.dispose();
    _saltController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _parseOptionalDouble(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = context.l10n;
    final defaultMealName = l10n.trackDefaultMealName;

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(l10n.trackUserNotLoggedIn);
      }

      final service = SupabaseService();
      
      final effectiveDate = widget.date ?? widget.meal?.createdAt ?? DateTime.now();
      await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, effectiveDate);

      if (widget.meal != null && widget.meal!.id != null) {
        // Edycja istniejącego posiłku
        final updatedMeal = Meal(
          id: widget.meal!.id,
          userId: userId,
          name: _nameController.text.trim().isEmpty ? defaultMealName : _nameController.text.trim(),
          calories: _getCalories(),
          proteinG: double.tryParse(_proteinController.text) ?? 0,
          fatG: double.tryParse(_fatController.text) ?? 0,
          carbsG: double.tryParse(_carbsController.text) ?? 0,
          saturatedFatG: _parseOptionalDouble(_saturatedFatController),
          sugarG: _parseOptionalDouble(_sugarController),
          fiberG: _parseOptionalDouble(_fiberController),
          saltG: _parseOptionalDouble(_saltController),
          weightG: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          mealType: _mealType,
          source: widget.meal!.source,
        );
        await service.updateMeal(updatedMeal);
      } else {
        // Tworzenie nowego posiłku
        final calories = _getCalories();
        final createdAt = DateTime(
          effectiveDate.year,
          effectiveDate.month,
          effectiveDate.day,
          12,
          0,
        );
        final source = widget.meal?.source ?? AppConstants.mealSourceManual;
        final meal = Meal(
          userId: userId,
          name: _nameController.text.trim().isEmpty ? defaultMealName : _nameController.text.trim(),
          calories: calories,
          proteinG: double.tryParse(_proteinController.text) ?? 0,
          fatG: double.tryParse(_fatController.text) ?? 0,
          carbsG: double.tryParse(_carbsController.text) ?? 0,
          saturatedFatG: _parseOptionalDouble(_saturatedFatController),
          sugarG: _parseOptionalDouble(_sugarController),
          fiberG: _parseOptionalDouble(_fiberController),
          saltG: _parseOptionalDouble(_saltController),
          weightG: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          mealType: _mealType,
          source: source,
          createdAt: createdAt,
        );
        await service.createMeal(meal);
        AnalyticsService.instance.logMealAdded(source: source);
      }

      if (mounted && _addToFavorites) {
        final name = _nameController.text.trim().isEmpty ? defaultMealName : _nameController.text.trim();
        final favorite = FavoriteMeal(
          userId: userId,
          name: name,
          calories: _getCalories(),
          proteinG: double.tryParse(_proteinController.text) ?? 0,
          fatG: double.tryParse(_fatController.text) ?? 0,
          carbsG: double.tryParse(_carbsController.text) ?? 0,
        );
        await service.createFavoriteMeal(favorite);
      }

      if (mounted) {
        context.pop(true);
        SuccessMessage.show(context, _addToFavorites ? context.l10n.trackMealSavedAndFavorited : context.l10n.trackMealAddedSuccess, l10n: context.l10n, duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, l10n: context.l10n, error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Oblicza kalorie z makroskładników: Białko 4 kcal/g, Tłuszcze 9 kcal/g, Węglowodany 4 kcal/g
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

  Future<void> _navigateToOption(String option) async {
    if (option == 'eating_out' || option == 'ai' || option == 'ingredients') {
      final l10n = context.l10n;
      final featureName = option == 'eating_out'
          ? l10n.trackFeatureEatingOut
          : option == 'ai'
              ? l10n.trackFeatureAiMealAnalysis
              : l10n.trackFeatureIngredientsMeal;
      final canProceed = await checkPremiumOrNavigate(context, ref, featureName: featureName);
      if (!canProceed || !mounted) return;
    }
    bool? result;
    switch (option) {
      case 'eating_out':
        result = await showEatingOutBottomSheet(context, date: widget.date ?? DateTime.now());
        break;
      case 'ai':
        result = await context.push<bool>(AppRoutes.aiPhoto, extra: widget.date);
        break;
      case 'ingredients':
        result = await context.push<bool>(AppRoutes.ingredientsMeal, extra: widget.date);
        break;
      case 'barcode':
        result = await context.push<bool>(AppRoutes.barcodeScanner, extra: widget.date);
        break;
      case 'search_products':
        result = await context.push<bool>(AppRoutes.productSearch, extra: widget.date);
        break;
      case 'favorites':
        result = await context.push<bool>(
          AppRoutes.favorites,
          extra: widget.date ?? DateTime.now(),
        );
        break;
    }
    // ignore: use_build_context_synchronously - guarded by mounted
    if (mounted && result == true) context.pop(true);
  }

  /// Wysokość jednego kafelka „Szybkie dodawanie” – wspólna dla wszystkich, żeby tekst się nie ucinał.
  static const double _quickAddTileHeight = 88.0;

  Widget _buildAddOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required String option,
    double? minWidth,
    double? height,
  }) {
    final surface = Theme.of(context).colorScheme.surface;
    final useHeight = height ?? _quickAddTileHeight;
    return Material(
      color: surface,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToOption(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: useHeight,
          constraints: minWidth != null ? BoxConstraints(minWidth: minWidth) : null,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Szerokość kolumny „Szybkie dodawanie” – jedna dla wszystkich przycisków, żeby tekst się nie ucinał.
  static const double _quickAddColumnWidth = 130.0;

  Widget _buildTilesColumn(BuildContext context) {
    return Container(
      width: _quickAddColumnWidth,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.trackQuickAdd,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.storefront, label: context.l10n.trackOptionEatingOut, color: Colors.orange, option: 'eating_out'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.camera_alt, label: context.l10n.trackOptionAiAnalysis, color: Colors.purple, option: 'ai'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.restaurant_menu, label: context.l10n.trackOptionIngredients, color: Colors.teal, option: 'ingredients'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.qr_code_scanner, label: context.l10n.trackOptionBarcode, color: Colors.blue, option: 'barcode'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.search, label: context.l10n.trackOptionSearchProduct, color: Colors.indigo, option: 'search_products'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAddOptionTile(context: context, icon: Icons.favorite_border, label: context.l10n.trackOptionFavorites, color: Colors.pink, option: 'favorites'),
          ),
        ],
      ),
    );
  }

  Widget _buildTilesRow(BuildContext context) {
    const gap = 6.0;
    const tileHeight = 78.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildCompactTile(context, Icons.storefront, context.l10n.trackOptionEatingOut, Colors.orange, 'eating_out', tileHeight)),
            SizedBox(width: gap),
            Expanded(child: _buildCompactTile(context, Icons.camera_alt, context.l10n.trackOptionAiAnalysis, Colors.purple, 'ai', tileHeight)),
            SizedBox(width: gap),
            Expanded(child: _buildCompactTile(context, Icons.restaurant_menu, context.l10n.trackOptionIngredients, Colors.teal, 'ingredients', tileHeight)),
            SizedBox(width: gap),
            Expanded(child: _buildCompactTile(context, Icons.qr_code_scanner, context.l10n.trackOptionBarcode, Colors.blue, 'barcode', tileHeight)),
            SizedBox(width: gap),
            Expanded(child: _buildCompactTile(context, Icons.search, context.l10n.trackSearchShort, Colors.indigo, 'search_products', tileHeight)),
            SizedBox(width: gap),
            Expanded(child: _buildCompactTile(context, Icons.favorite_border, context.l10n.trackOptionFavorites, Colors.pink, 'favorites', tileHeight)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context, IconData icon, String label, Color color, String option, double height) {
    final surface = Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _navigateToOption(option),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: height,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 500;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal != null ? context.l10n.trackEditMeal : context.l10n.trackAddMeal),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                        children: _buildFormChildren(),
                      ),
                    ),
                  ),
                  _buildTilesColumn(context),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTilesRow(context),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildFormChildren(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    final l10n = context.l10n;
    return [
            if (widget.meal == null && _recentMeals.isNotEmpty) ...[
              Text(
                l10n.trackRecentFoods,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final meal in _recentMeals)
                    ActionChip(
                      label: Text(meal.name),
                      onPressed: () => _applyRecentMeal(meal),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.trackMealNameOptional,
                      hintText: l10n.trackHintEmptyDefaultName,
                    ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: l10n.trackCaloriesKcal,
                hintText: l10n.trackHintCaloriesFromMacros,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {
                if (!_isUpdatingCaloriesFromMacros) _caloriesManuallyEdited = true;
              }),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                final calories = value != null && value.isNotEmpty
                    ? double.tryParse(value)
                    : _calculateCaloriesFromMacros();
                if (calories == null || calories < 0) {
                  return l10n.trackEnterCaloriesOrMacros;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.trackProtein,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _proteinController,
              decoration: InputDecoration(
                labelText: l10n.trackProteinG,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.trackFat,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _fatController,
              decoration: InputDecoration(
                labelText: l10n.trackFatG,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextFormField(
                controller: _saturatedFatController,
                decoration: InputDecoration(
                  labelText: l10n.trackIncludingSaturatedG,
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.trackCarbs,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _carbsController,
              decoration: InputDecoration(
                labelText: l10n.trackCarbsG,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (_) => setState(() => _updateCaloriesFromMacros()),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextFormField(
                controller: _sugarController,
                decoration: InputDecoration(
                  labelText: l10n.trackIncludingSugarsG,
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextFormField(
                controller: _fiberController,
                decoration: InputDecoration(
                  labelText: l10n.trackFiberG,
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.trackSalt,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _saltController,
              decoration: InputDecoration(
                labelText: l10n.trackSaltG,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: l10n.trackWeightGOptional,
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _mealType,
              decoration: InputDecoration(
                labelText: l10n.trackMealTypeOptional,
              ),
              items: [
                DropdownMenuItem(value: AppConstants.mealBreakfast, child: Text(l10n.trackBreakfast)),
                DropdownMenuItem(value: AppConstants.mealLunch, child: Text(l10n.trackLunch)),
                DropdownMenuItem(value: AppConstants.mealDinner, child: Text(l10n.trackDinner)),
                DropdownMenuItem(value: AppConstants.mealSnack, child: Text(l10n.trackSnack)),
              ],
              onChanged: (value) {
                setState(() => _mealType = value);
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _addToFavorites,
              onChanged: (value) {
                setState(() => _addToFavorites = value ?? false);
              },
              title: Text(l10n.trackAddToFavorites),
              subtitle: Text(l10n.trackAddToFavoritesMealSubtitle),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.meal != null ? l10n.trackUpdateMeal : l10n.trackSaveMeal,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ];
  }
}
