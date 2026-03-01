import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/activity.dart';
import '../../../shared/models/favorite_activity.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/streak_updater.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/services/analytics_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/premium_gate.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  final Activity? activity;
  final DateTime? date;

  const AddActivityScreen({super.key, this.activity, this.date});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _durationController;
  String? _activityType;
  bool _isLoading = false;
  bool _addToFavorites = false;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _nameController = TextEditingController(text: activity?.name ?? '');
    _caloriesController = TextEditingController(text: activity?.caloriesBurned.toStringAsFixed(0) ?? '');
    _durationController = TextEditingController(text: activity?.durationMinutes?.toString() ?? '');
    _activityType = activity?.activityType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Widget _buildQuickAddButton(BuildContext context, int kcal) {
    final surface = Theme.of(context).colorScheme.surface;
    return Material(
      color: surface,
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: _isLoading ? null : () => _quickAddActivity(kcal),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text('$kcal', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            )),
          ),
        ),
      ),
    );
  }

  Future<void> _quickAddActivity(int kcal) async {
    final canProceed = await checkPremiumOrNavigate(
      context,
      ref,
      featureName: 'Szybkie dodawanie w aktywnościach',
    );
    if (!canProceed || !mounted) return;
    setState(() => _isLoading = true);
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('Użytkownik nie jest zalogowany');

      final effectiveDate = widget.date ?? DateTime.now();
      final createdAt = DateTime(
        effectiveDate.year,
        effectiveDate.month,
        effectiveDate.day,
        12,
        0,
      );
      final activity = Activity(
        userId: userId,
        name: 'Spalone $kcal kcal',
        caloriesBurned: kcal.toDouble(),
        durationMinutes: null,
        activityType: null,
        createdAt: createdAt,
      );

      final service = SupabaseService();
      await service.createActivity(activity);
      AnalyticsService.instance.logActivityAdded();
      await StreakUpdater.updateStreak(userId, AppConstants.streakActivities, effectiveDate);

      if (mounted) {
        context.pop(true);
        SuccessMessage.show(context, 'Dodano: $kcal kcal');
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      final service = SupabaseService();
      
      if (widget.activity != null) {
        // Edycja istniejącej aktywności
        final updatedActivity = Activity(
          id: widget.activity!.id,
          userId: userId,
          name: _nameController.text.trim().isEmpty ? AppConstants.defaultActivityName : _nameController.text.trim(),
          caloriesBurned: double.parse(_caloriesController.text),
          durationMinutes: _durationController.text.isNotEmpty
              ? int.parse(_durationController.text)
              : null,
          activityType: _activityType,
          createdAt: widget.activity!.createdAt,
          excludedFromBalance: widget.activity!.excludedFromBalance,
        );
        await service.updateActivity(updatedActivity);
        if (mounted && _addToFavorites) {
          final fav = FavoriteActivity(
            userId: userId,
            name: _nameController.text.trim().isEmpty ? AppConstants.defaultActivityName : _nameController.text.trim(),
            caloriesBurned: double.parse(_caloriesController.text),
            durationMinutes: _durationController.text.isNotEmpty ? int.tryParse(_durationController.text) : null,
            activityType: _activityType,
          );
          await service.createFavoriteActivity(fav);
        }
      } else {
        // Tworzenie nowej aktywności
        final effectiveDate = widget.date ?? DateTime.now();
        final createdAt = DateTime(
          effectiveDate.year,
          effectiveDate.month,
          effectiveDate.day,
          12,
          0,
        );
        final activity = Activity(
          userId: userId,
          name: _nameController.text.trim().isEmpty ? AppConstants.defaultActivityName : _nameController.text.trim(),
          caloriesBurned: double.parse(_caloriesController.text),
          durationMinutes: _durationController.text.isNotEmpty
              ? int.parse(_durationController.text)
              : null,
          activityType: _activityType,
          createdAt: createdAt,
        );
        await service.createActivity(activity);
        AnalyticsService.instance.logActivityAdded();
        await StreakUpdater.updateStreak(userId, AppConstants.streakActivities, effectiveDate);
        if (mounted && _addToFavorites) {
          final fav = FavoriteActivity(
            userId: userId,
            name: _nameController.text.trim().isEmpty ? AppConstants.defaultActivityName : _nameController.text.trim(),
            caloriesBurned: double.parse(_caloriesController.text),
            durationMinutes: _durationController.text.isNotEmpty ? int.tryParse(_durationController.text) : null,
            activityType: _activityType,
          );
          await service.createFavoriteActivity(fav);
        }
      }

      if (mounted) {
        context.pop(true);
        SuccessMessage.show(
          context,
          _addToFavorites ? 'Aktywność zapisana i dodana do ulubionych!' : 'Aktywność dodana pomyślnie!',
        );
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Edytuj aktywność' : 'Dodaj aktywność'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.activity == null) ...[
              Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 1,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 18, color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Text('Szybkie dodawanie', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            children: [100, 200, 300, 400].asMap().entries.map((e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: e.key < 3 ? 6 : 0),
                                child: _buildQuickAddButton(context, e.value),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [500, 600, 700, 800].asMap().entries.map((e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: e.key < 3 ? 6 : 0),
                                child: _buildQuickAddButton(context, e.value),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa aktywności (opcjonalnie)',
                hintText: 'Puste = "Aktywność bez nazwy"',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Spalone kalorie (kcal)',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Podaj liczbę spalonych kalorii';
                }
                final calories = double.tryParse(value);
                if (calories == null || calories < 0) {
                  return 'Podaj poprawną liczbę kalorii';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Czas trwania (minuty) - opcjonalnie',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _activityType,
              decoration: const InputDecoration(
                labelText: 'Typ aktywności - opcjonalnie',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                const DropdownMenuItem(value: 'RUNNING', child: Text('Bieg')),
                const DropdownMenuItem(value: 'CYCLING', child: Text('Kolarstwo')),
                const DropdownMenuItem(value: 'WALKING', child: Text('Chodzenie')),
                const DropdownMenuItem(value: 'SWIMMING', child: Text('Pływanie')),
                const DropdownMenuItem(value: 'HIKING', child: Text('Wędrówka')),
                const DropdownMenuItem(value: 'OTHER', child: Text('Inna')),
                if (_activityType != null &&
                    _activityType!.isNotEmpty &&
                    !const ['RUNNING', 'CYCLING', 'WALKING', 'SWIMMING', 'HIKING', 'OTHER'].contains(_activityType))
                  DropdownMenuItem(value: _activityType, child: Text(_activityType!)),
              ],
              onChanged: (value) {
                setState(() => _activityType = value);
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _addToFavorites,
              onChanged: (value) {
                setState(() => _addToFavorites = value ?? false);
              },
              title: const Text('Dodaj do ulubionych'),
              subtitle: const Text('Będziesz mógł szybko dodać tę aktywność później'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveActivity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                        widget.activity != null ? 'Zaktualizuj aktywność' : 'Zapisz aktywność',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
