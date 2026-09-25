import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/eating_out_options.dart';
import '../../../shared/models/meal.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/utils/streak_updater.dart';

/// Bottom sheet z opcjami „Jem na mieście”.
///
/// Zwraca `true` jeśli dodano posiłek.
Future<bool?> showEatingOutBottomSheet(BuildContext context, {DateTime? date}) async {
  final selectedDate = date ?? DateTime.now();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EatingOutContent(selectedDate: selectedDate),
  );
}

class _EatingOutContent extends StatefulWidget {
  final DateTime selectedDate;

  const _EatingOutContent({required this.selectedDate});

  @override
  State<_EatingOutContent> createState() => _EatingOutContentState();
}

class _EatingOutContentState extends State<_EatingOutContent> {
  EatingOutOption? _selectedOption;
  int _selectedKcal = 0;
  int _pizzaSlices = 2;
  int _quickAddCount = 1;
  bool _isSaving = false;

  int get _totalKcal =>
      _selectedOption?.supportsSlices == true ? _selectedKcal * _pizzaSlices : _selectedKcal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    l10n.trackEatingOutTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.trackEatingOutSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 20),
              ...eatingOutOptions.map((opt) => _buildOptionTile(context, opt)),
              const SizedBox(height: 24),
              if (_selectedOption != null) ...[
                Text(
                  l10n.trackPortionLabel(label: _selectedOption!.localizedLabel(l10n)),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_selectedOption!.supportsSlices) ...[
                  Text(
                    l10n.trackSlicesCount(count: '$_pizzaSlices'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _pizzaSlices.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: l10n.trackSlicesUnit(count: '$_pizzaSlices'),
                    onChanged: (v) => setState(() => _pizzaSlices = v.round()),
                  ),
                  Text(
                    l10n.trackKcalPerSlice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                Slider(
                  value: _selectedKcal.toDouble(),
                  min: _selectedOption!.minKcal.toDouble(),
                  max: _selectedOption!.maxKcal.toDouble(),
                  divisions: ((_selectedOption!.maxKcal - _selectedOption!.minKcal) ~/ 50).clamp(1, 20),
                  label: _selectedOption!.supportsSlices
                      ? l10n.trackKcalPerPieceLabel(kcal: '$_selectedKcal')
                      : l10n.trackKcalLabel(kcal: '$_selectedKcal'),
                  onChanged: (v) => setState(() => _selectedKcal = v.round()),
                ),
                Text(
                  _selectedOption!.supportsSlices
                      ? l10n.trackKcalTimesSlices(
                          kcal: '$_selectedKcal',
                          slices: '$_pizzaSlices',
                          total: '$_totalKcal',
                        )
                      : l10n.trackKcalLabel(kcal: '$_selectedKcal'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_isSaving || _selectedOption == null) ? null : () => _saveMeal(context),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_selectedOption != null ? Icons.add_circle : Icons.touch_app),
                  label: Text(
                    _isSaving
                        ? l10n.trackSaving
                        : _selectedOption != null
                            ? l10n.trackAddToDiary
                            : l10n.trackSelectMealAbove,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.trackEatingOutTip,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(BuildContext context, EatingOutOption opt) {
    final l10n = context.l10n;
    final isSelected = _selectedOption?.id == opt.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOption = opt;
            _selectedKcal = opt.defaultKcal;
            _pizzaSlices = 2;
            _quickAddCount = 1;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(opt.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      opt.localizedName(l10n),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      opt.localizedLabel(l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              // Szybkie dodawanie
              if (opt.supportsSlices)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickAddStepper(
                      count: _quickAddCount,
                      onIncrement: () => setState(() => _quickAddCount = (_quickAddCount + 1).clamp(1, 20)),
                      onAdd: () => _quickAdd(context, opt, slices: _quickAddCount),
                      isSaving: _isSaving,
                    ),
                  ],
                )
              else
                _QuickAddChip(
                  label: '+',
                  onTap: () => _quickAdd(context, opt),
                  isSaving: _isSaving,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickAdd(BuildContext context, EatingOutOption opt, {int slices = 1}) async {
    if (_isSaving) return;
    final totalKcal = opt.supportsSlices ? opt.defaultKcal * slices : opt.defaultKcal;
    await _saveMealWithParams(context, opt, slices, totalKcal);
  }

  Future<void> _saveMealWithParams(
    BuildContext context,
    EatingOutOption option,
    int slices,
    int totalKcal,
  ) async {
    setState(() => _isSaving = true);
    final l10n = context.l10n;
    final displayName = option.localizedName(l10n);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.trackUserNotLoggedIn);

      final macros = option.getEstimatedMacros(slices: slices);
      final createdAt = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        12,
        0,
      );

      final mealName = option.supportsSlices
          ? l10n.trackMealNameEatingOutSlices(name: displayName, slices: '$slices')
          : l10n.trackMealNameEatingOut(name: displayName);

      final meal = Meal(
        userId: userId,
        name: mealName,
        calories: totalKcal.toDouble(),
        proteinG: macros['protein'] ?? 25,
        fatG: macros['fat'] ?? 35,
        carbsG: macros['carbs'] ?? 60,
        saturatedFatG: 0,
        sugarG: 0,
        fiberG: 0,
        saltG: 0,
        mealType: null,
        source: AppConstants.mealSourceManual,
        createdAt: createdAt,
      );

      final service = SupabaseService();
      await service.createMeal(meal);

      await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, widget.selectedDate);

      if (context.mounted) {
        context.pop(true);
        SuccessMessage.show(context, l10n.trackAddedEatingOut(
            name: displayName,
            slicesPart: option.supportsSlices ? l10n.trackSlicesPart(slices: '$slices') : '',
            kcal: '$totalKcal',
          ), l10n: context.l10n, duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showSnackBar(context, l10n: context.l10n, error: e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveMeal(BuildContext context) async {
    if (_selectedOption == null) return;
    final slices = _selectedOption!.supportsSlices ? _pizzaSlices : 1;
    await _saveMealWithParams(context, _selectedOption!, slices, _totalKcal);
  }
}

class _QuickAddStepper extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onAdd;
  final bool isSaving;

  const _QuickAddStepper({
    required this.count,
    required this.onIncrement,
    required this.onAdd,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isSaving ? null : onIncrement,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Material(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isSaving ? null : onAdd,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                context.l10n.trackAdd,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSaving;

  const _QuickAddChip({
    required this.label,
    required this.onTap,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isSaving ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
