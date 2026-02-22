import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/auth/sign_out_guard.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/calculations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/widgets/save_progress_checker.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final _customCaloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  // Dane edycji
  String? _gender;
  int? _age;
  double? _heightCm;
  double? _currentWeightKg;
  double? _targetWeightKg;
  String? _activityLevel;
  String? _goal;

  // Ręczna edycja celu
  double? _manualTargetCalories;
  DateTime? _manualTargetDate;
  double? _manualProteinG;
  double? _manualFatG;
  double? _manualCarbsG;
  double? _manualWeeklyWeightChange; // kg/tydzień
  double? _waterGoalMl;
  double? _initialWaterGoalMl; // wartość przy wejściu w edycję (do wykrycia, czy user zmienił cel wody)

  // Oryginalne wartości (przed edycją) - do porównania
  double? _originalTargetCalories;
  DateTime? _originalTargetDate;
  
  // Walidacja - ostrzeżenia
  String? _calorieWarning;
  String? _macroWarning;

  double get _macroPreviewKcal {
    final p = double.tryParse(_proteinController.text) ?? 0;
    final f = double.tryParse(_fatController.text) ?? 0;
    final c = double.tryParse(_carbsController.text) ?? 0;
    return (p * 4) + (f * 9) + (c * 4);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(firstUseAtProvider);
    });
  }

  @override
  void dispose() {
    _customCaloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text('Profil'),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'Powiadomienia',
              onPressed: () => context.push(AppRoutes.notifications),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final data = profile.value;
                if (data != null) {
                  _startEditing(data);
                }
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
            ),
        ],
      ),
      body: profile.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Brak profilu'));
          }
          if (_isEditing) {
            return _buildEditForm(context, data);
          }
          return _buildProfileContent(context, data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Błąd: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEditing(UserProfile profile) {
    setState(() {
      _isEditing = true;
      _gender = profile.gender;
      _age = profile.age;
      _heightCm = profile.heightCm;
      _currentWeightKg = profile.currentWeightKg;
      _targetWeightKg = profile.targetWeightKg;
      _activityLevel = profile.activityLevel;
      _goal = Calculations.deriveGoalFromWeights(
        currentWeightKg: profile.currentWeightKg,
        targetWeightKg: profile.targetWeightKg,
      );
      
      // Inicjalizuj ręczne wartości z profilu
      _manualTargetCalories = profile.targetCalories;
      _manualTargetDate = profile.targetDate;
      _manualProteinG = profile.targetProteinG;
      _manualFatG = profile.targetFatG;
      _manualCarbsG = profile.targetCarbsG;
      final suggestedWater = Calculations.calculateDailyWaterGoalMl(profile.currentWeightKg);
      _waterGoalMl = profile.waterGoalMl ?? suggestedWater;
      _initialWaterGoalMl = _waterGoalMl;
      _manualWeeklyWeightChange = profile.weeklyWeightChange ??
          (_goal == AppConstants.goalWeightLoss
              ? AppConstants.defaultWeightLossRate
              : _goal == AppConstants.goalWeightGain
                  ? AppConstants.defaultWeightGainRate
                  : 0.0);
      _customCaloriesController.clear();
      _syncMacroControllers();
      
      // Zapamiętaj oryginalne wartości (przed edycją)
      _originalTargetCalories = profile.targetCalories;
      _originalTargetDate = profile.targetDate;
    });
    // Jeśli brak obliczonych wartości, przelicz z tempa
    if ((_manualTargetCalories == null || _manualProteinG == null) &&
        _manualWeeklyWeightChange != null &&
        _manualWeeklyWeightChange! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _recalculateFromRate();
      });
    }
  }

  /// Zwraca czytelny opis zalogowanego konta (email lub nazwa z providera).
  String _getAccountDisplayName(User? user) {
    if (user == null) return '';
    final meta = user.userMetadata;
    final name = meta?['full_name'] ?? meta?['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString().trim();
    }
    if (user.email != null && user.email!.trim().isNotEmpty) {
      return user.email!.trim();
    }
    final provider = user.appMetadata['provider'] as String?;
    if (provider != null) {
      if (provider == 'google') return 'Konto Google';
      if (provider == 'email') return 'Konto e-mail';
    }
    return 'Konto zalogowane';
  }

  void _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wyloguj się'),
        content: const Text(
          'Czy na pewno chcesz się wylogować? Możesz ponownie zalogować się później.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Wyloguj'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await SupabaseConfig.auth.signOut();
      await markSignOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
    if (!context.mounted) return;
    ref.invalidate(profileProvider);
    ref.invalidate(dashboardDataProvider);
    context.go(AppRoutes.welcome);
  }

  void _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń konto'),
        content: const Text(
          'Twoje dane zostaną całkowicie usunięte i nie będzie można ich przywrócić. '
          'Gdy wrócisz do aplikacji, trzeba będzie uzupełnić profil od nowa.\n\n'
          'Czy na pewno chcesz usunąć konto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Usuń konto'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      // Odśwież sesję, żeby uniknąć 401 przy wygasłym tokenie
      final refreshed = await SupabaseConfig.auth.refreshSession();
      final session = refreshed.session ?? SupabaseConfig.auth.currentSession;
      if (session == null || !context.mounted) return;
      final response = await SupabaseConfig.client.functions.invoke(
        'delete_user',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      if (!context.mounted) return;
      if (response.status != 200 || (response.data is Map && (response.data as Map)['error'] != null)) {
        final err = response.data is Map ? (response.data as Map)['error'] : response.status;
        final msg = _getDeleteAccountErrorMessage(err, response.status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
        return;
      }
      // Konto usunięte – wyloguj i przekieruj na ekran startowy
      await SupabaseConfig.auth.signOut();
      await markSignOut();
      if (!context.mounted) return;
      context.go(AppRoutes.welcome);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konto zostało usunięte'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete account error: $e');
      if (context.mounted) {
        final msg = _getDeleteAccountErrorMessage(e.toString(), null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getDeleteAccountErrorMessage(Object? err, int? status) {
    final s = err?.toString() ?? status?.toString() ?? '';
    if (s.contains('404') || s.contains('NOT_FOUND')) {
      return 'Usługa usuwania konta jest niedostępna. Skontaktuj się z nami: ${AppConstants.contactEmail}';
    }
    if (s.contains('401') || s.contains('Nieprawidłowa sesja')) {
      return 'Sesja wygasła. Zaloguj się ponownie i spróbuj jeszcze raz.';
    }
    if (s.contains('403') || s.contains('forbidden')) {
      return 'Brak uprawnień do wykonania tej operacji.';
    }
    return 'Nie udało się usunąć konta. Spróbuj ponownie później.';
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        bool loading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Zaproś znajomego'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Podaj adres e-mail osoby, której chcesz wysłać zaproszenie do Łatwa Forma.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Adres e-mail',
                    hintText: 'np. znajomy@example.com',
                  ),
                  enabled: !loading,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        final email = controller.text.trim();
                        if (email.isEmpty) return;
                        setState(() => loading = true);
                        try {
                          final session = SupabaseConfig.auth.currentSession;
                          if (session == null) {
                            setState(() => loading = false);
                            return;
                          }
                          final response = await SupabaseConfig.client.functions.invoke(
                            'invite_user',
                            body: {'email': email},
                            headers: {'Authorization': 'Bearer ${session.accessToken}'},
                          );
                          if (!ctx.mounted) return;
                          setState(() => loading = false);
                          final data = response.data as Map<String, dynamic>?;
                          final err = data?['error'] ?? response.status;
                          if (response.status == 200 && data?['success'] == true) {
                            Navigator.of(ctx).pop({'success': true, 'message': data?['message'] ?? 'Zaproszenie wysłane'});
                          } else {
                            Navigator.of(ctx).pop({'success': false, 'error': err.toString()});
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setState(() => loading = false);
                            Navigator.of(ctx).pop({'success': false, 'error': e.toString()});
                          }
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Wyślij zaproszenie'),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || result == null) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Zaproszenie wysłane!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'].toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    final user = SupabaseConfig.auth.currentUser;
    final isAnonymous = user?.isAnonymous ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAnonymous)
            Card(
              child: InkWell(
                onTap: () async {
                  final userId = SupabaseConfig.auth.currentUser?.id;
                  if (userId == null || !context.mounted) return;
                  final count = await SupabaseService().getMealsCount(userId);
                  if (!context.mounted) return;
                  await SaveProgressChecker.showSaveProgressModal(
                    context,
                    mealsCount: count,
                    onInvalidate: () {
                      ref.invalidate(profileProvider);
                      ref.invalidate(dashboardDataProvider);
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.save_alt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zapisz postępy',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Zaloguj się przez email lub Google, aby nie stracić danych',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isAnonymous) const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dane podstawowe',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildProfileRow(context, 'Płeć', _getGenderText(profile.gender)),
                  _buildProfileRow(context, 'Wiek', '${profile.age} lat'),
                  _buildProfileRow(context, 'Wzrost', '${profile.heightCm.toStringAsFixed(0)} cm'),
                  _buildProfileRow(context, 'Aktualna waga', '${profile.currentWeightKg.toStringAsFixed(1)} kg'),
                  _buildProfileRow(context, 'Waga docelowa', '${profile.targetWeightKg.toStringAsFixed(1)} kg'),
                  _buildProfileRow(context, 'Poziom aktywności', _getActivityLevelText(profile.activityLevel)),
                  _buildProfileRow(context, 'Cel', _getGoalText(profile.goal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (profile.bmr != null || profile.tdee != null || profile.targetCalories != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Obliczenia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (profile.bmr != null)
                      _buildProfileRow(context, 'BMR', '${profile.bmr!.toStringAsFixed(0)} kcal',
                        explanation: 'Zapotrzebowanie kaloryczne w spoczynku – ile kalorii spalasz bez aktywności.'),
                    if (profile.tdee != null)
                      _buildProfileRow(context, 'TDEE', '${profile.tdee!.toStringAsFixed(0)} kcal',
                        explanation: 'Całkowite dzienne zapotrzebowanie – ile kalorii spalasz w ciągu dnia z uwzględnieniem aktywności.'),
                    if (profile.targetCalories != null)
                      _buildProfileRow(context, 'Cel kaloryczny', '${profile.targetCalories!.toStringAsFixed(0)} kcal',
                        explanation: 'Zalecane dzienne spożycie kalorii do osiągnięcia celu wagowego.'),
                    _buildProfileRow(
                      context,
                      'Cel picia wody',
                      '${(profile.waterGoalMl ?? Calculations.calculateDailyWaterGoalMl(profile.currentWeightKg)).toStringAsFixed(0)} ml',
                      explanation: Calculations.waterGoalExplanation(profile.currentWeightKg),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (profile.targetProteinG != null ||
              profile.targetFatG != null ||
              profile.targetCarbsG != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Makroskładniki',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (profile.targetProteinG != null)
                      _buildProfileRow(context, 'Białko', '${profile.targetProteinG!.toStringAsFixed(0)} g'),
                    if (profile.targetFatG != null)
                      _buildProfileRow(context, 'Tłuszcze', '${profile.targetFatG!.toStringAsFixed(0)} g'),
                    if (profile.targetCarbsG != null)
                      _buildProfileRow(context, 'Węglowodany', '${profile.targetCarbsG!.toStringAsFixed(0)} g'),
                  ],
                ),
              ),
            ),
          if (profile.targetDate != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termin osiągnięcia celu:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.targetDate!.day}.${profile.targetDate!.month}.${profile.targetDate!.year}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Działaj zgodnie z planem, a ten dzień się nie opóźni.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chcesz przyspieszyć cel? Edytuj tempo zmiany wagi w trybie edycji profilu (ikona ołówka u góry).',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Porada AI
          Card(
            child: InkWell(
              onTap: () => context.push(AppRoutes.aiAdvice),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Porada AI',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Zapytaj o dietę, odżywianie i aktywność',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kalkulator BMI
          Card(
            child: InkWell(
              onTap: () => context.push(AppRoutes.bmiCalculator, extra: profile),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalkulator BMI',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sprawdź swój wskaźnik masy ciała',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Premium / Subskrypcja (opłacone lub trial 24h)
          Builder(
            builder: (context) {
              final hasPremiumAccess = ref.watch(hasPremiumAccessProvider);
              final isInTrial = ref.watch(isInTrialProvider);
              final trialRemaining = ref.watch(trialRemainingProvider);
              final showActive = profile.isPremium || isInTrial;
              final remainingText = trialRemaining != null
                  ? 'Pozostało: ${trialRemaining.inHours}h ${trialRemaining.inMinutes % 60}min'
                  : null;
              return Card(
                child: InkWell(
                  onTap: () => context.push(AppRoutes.premium),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          hasPremiumAccess ? Icons.workspace_premium : Icons.star_outline,
                          color: hasPremiumAccess ? Colors.amber.shade700 : Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    hasPremiumAccess ? 'Łatwa Forma Premium' : 'Subskrypcja Premium',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (showActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Aktywna',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.amber.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (remainingText != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  remainingText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                hasPremiumAccess
                                    ? 'Nieograniczona AI, eksport PDF, integracje'
                                    : 'Odblokuj pełny potencjał – AI, PDF, integracje',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Integracje
          Card(
            child: InkWell(
              onTap: () => context.push(AppRoutes.integrations),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Integracje',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Strava, Garmin – importuj aktywności i spalone kalorie',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Eksport danych
          Card(
            child: InkWell(
              onTap: () => context.push(AppRoutes.export),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.file_download,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eksport danych',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wyeksportuj swoje dane do CSV',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isAnonymous) ...[
            const SizedBox(height: 16),
            Card(
              child: InkWell(
                onTap: () => _showInviteDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zaproś znajomego',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Wyślij zaproszenie e-mailem do aplikacji Łatwa Forma',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildLegalLinks(context),
          if (!isAnonymous && user != null) ...[
            const SizedBox(height: 16),
            _buildAccountSection(context, user),
          ],
        ],
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => _openUrl(AppConstants.privacyPolicyUrl),
            child: Text(
              'Polityka prywatności',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Text(
            ' • ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          TextButton(
            onPressed: () => _openUrl(AppConstants.termsUrl),
            child: Text(
              'Regulamin',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAccountSection(BuildContext context, User user) {
    final displayName = _getAccountDisplayName(user);
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final primary = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onPrimaryContainer,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Twoje konto',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleSignOut(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Wyloguj się'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _handleDeleteAccount(context),
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                  label: Text(
                    'Usuń konto',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context, String label, String value, {String? explanation}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (explanation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        explanation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'male':
        return 'Mężczyzna';
      case 'female':
        return 'Kobieta';
      default:
        return 'Inna';
    }
  }

  String _getActivityLevelText(String level) {
    switch (level) {
      case 'sedentary':
        return 'Siedzący';
      case 'light':
        return 'Lekka';
      case 'moderate':
        return 'Umiarkowana';
      case 'intense':
        return 'Intensywna';
      case 'very_intense':
        return 'Bardzo intensywna';
      default:
        return level;
    }
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Utrata wagi';
      case 'weight_gain':
        return 'Przybranie wagi';
      case 'maintain':
        return 'Utrzymanie wagi';
      default:
        return goal;
    }
  }

  Widget _buildEditForm(BuildContext context, UserProfile profile) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Płeć
            Text('Płeć *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildGenderOption('Mężczyzna', AppConstants.genderMale)),
                const SizedBox(width: 8),
                Expanded(child: _buildGenderOption('Kobieta', AppConstants.genderFemale)),
              ],
            ),
            const SizedBox(height: 16),
            // Wiek
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wiek *', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${_age ?? profile.age} lat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _age?.toDouble() ?? profile.age.toDouble(),
              min: 13,
              max: 100,
              divisions: 87,
              label: _age?.toString() ?? profile.age.toString(),
              onChanged: (value) {
                setState(() {
                  _age = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            // Wzrost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wzrost (cm) *', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${(_heightCm ?? profile.heightCm).toStringAsFixed(0)} cm',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _heightCm ?? profile.heightCm,
              min: 100,
              max: 250,
              divisions: 150,
              label: (_heightCm ?? profile.heightCm).toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _heightCm = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Aktualna waga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktualna waga (kg) *', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${(_currentWeightKg ?? profile.currentWeightKg).toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _currentWeightKg ?? profile.currentWeightKg,
              min: 30,
              max: 300,
              divisions: 270,
              label: (_currentWeightKg ?? profile.currentWeightKg).toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _currentWeightKg = value;
                  _targetWeightKg ??= value;
                  _updateGoalFromWeights();
                });
              },
            ),
            const SizedBox(height: 16),
            // Waga docelowa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Waga docelowa (kg) *', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${(_targetWeightKg ?? profile.targetWeightKg).toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _targetWeightKg ?? profile.targetWeightKg,
              min: 30,
              max: 300,
              divisions: 270,
              label: (_targetWeightKg ?? profile.targetWeightKg).toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _targetWeightKg = value;
                  _updateGoalFromWeights();
                });
              },
            ),
            if (_currentWeightKg != null && _targetWeightKg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getGoalDescriptionText(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            if (_currentWeightKg != null &&
                _targetWeightKg != null &&
                _goal != null &&
                _goal != AppConstants.goalMaintain &&
                (_targetWeightKg! - _currentWeightKg!).abs() < 1.0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Różnica między wagami musi wynosić co najmniej 1 kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            // Poziom aktywności
            Text('Poziom aktywności *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            _buildActivityLevelOption('Siedzący', 'Brak aktywności lub minimalna', AppConstants.activitySedentary),
            const SizedBox(height: 4),
            _buildActivityLevelOption('Lekka', '1-3 treningi / tydzień', AppConstants.activityLight),
            const SizedBox(height: 4),
            _buildActivityLevelOption('Umiarkowana', '3-5 treningów / tydzień', AppConstants.activityModerate),
            const SizedBox(height: 4),
            _buildActivityLevelOption('Intensywna', '6-7 treningów / tydzień', AppConstants.activityIntense),
            const SizedBox(height: 4),
            _buildActivityLevelOption('Bardzo intensywna', '2x dziennie / ciężka praca', AppConstants.activityVeryIntense),
            const SizedBox(height: 16),
            // Cel wody
            Text('Cel wody (ml)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: (_waterGoalMl ?? profile.waterGoalMl ?? AppConstants.defaultWaterGoal).toStringAsFixed(0),
              decoration: const InputDecoration(
                hintText: '2000',
                suffixText: 'ml',
                helperText: 'Możesz zmienić ręcznie. Poniżej wyjaśnienie, skąd bierze się propozycja.',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                setState(() => _waterGoalMl = parsed);
              },
            ),
            const SizedBox(height: 8),
            Text(
              Calculations.waterGoalExplanation(_currentWeightKg ?? profile.currentWeightKg),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // Dostosowanie planu – tempo i podsumowanie (Premium lub trial)
            ref.watch(hasPremiumAccessProvider)
                ? _buildPlanAdjustmentCard(context, profile)
                : _buildPlanPremiumGateCard(context),
            const SizedBox(height: 20),
            
            // Przycisk zapisz
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_canProceed() && !_isSaving) ? () => _saveProfile(context, profile) : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Zapisz zmiany',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = _gender == value;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLevelOption(String title, String description, String value) {
    final isSelected = _activityLevel == value;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => setState(() => _activityLevel = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _updateGoalFromWeights() {
    if (_currentWeightKg != null && _targetWeightKg != null) {
      setState(() {
        _goal = Calculations.deriveGoalFromWeights(
          currentWeightKg: _currentWeightKg!,
          targetWeightKg: _targetWeightKg!,
        );
      });
      // Automatyczne przeliczenie kalorii i makroskładników przy zmianie wagi
      if (_gender != null && _age != null && _heightCm != null && _activityLevel != null) {
        if (_goal == AppConstants.goalMaintain) {
          _recalculateFromWeightsForMaintain();
        } else if (_goal == AppConstants.goalWeightLoss || _goal == AppConstants.goalWeightGain) {
          // Użyj aktualnego tempa lub domyślnego
          if (_manualWeeklyWeightChange == null || _manualWeeklyWeightChange! <= 0) {
            _manualWeeklyWeightChange = _goal == AppConstants.goalWeightLoss
                ? AppConstants.defaultWeightLossRate
                : AppConstants.defaultWeightGainRate;
          }
          _recalculateFromRate();
        }
      }
    }
  }

  void _recalculateFromWeightsForMaintain() {
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal != AppConstants.goalMaintain) return;

    final bmr = Calculations.calculateBMR(
      gender: _gender!,
      weightKg: _currentWeightKg!,
      heightCm: _heightCm!,
      age: _age!,
    );
    final tdee = Calculations.calculateTDEE(bmr: bmr, activityLevel: _activityLevel!);
    final macros = _calculateMacrosFromCalories(tdee, _targetWeightKg!);

    setState(() {
      _manualTargetCalories = tdee;
      _manualProteinG = macros['protein'];
      _manualFatG = macros['fat'];
      _manualCarbsG = macros['carbs'];
      _manualWeeklyWeightChange = 0.0;
      _manualTargetDate = DateTime.now().add(const Duration(days: 365));
      _customCaloriesController.clear();
      _syncMacroControllers();
    });
  }

  Widget _buildMacroChip(BuildContext context, String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(0)} g',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInputCard(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required Color color,
    required int kcalPerG,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                suffixText: 'g',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 1.5),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateCaloriesFromMacros(),
            ),
            const SizedBox(height: 4),
            Text(
              '1g = $kcalPerG kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalDescriptionText() {
    if (_currentWeightKg == null || _targetWeightKg == null) return '';
    final diff = _targetWeightKg! - _currentWeightKg!;
    if (diff < -0.5) return 'Chcę schudnąć.';
    if (diff > 0.5) return 'Chcę przybrać na wadze.';
    return 'Chcę utrzymać obecną wagę.';
  }

  Widget _buildPlanPremiumGateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Dostosuj plan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Własny cel kaloryczny i makroskładniki są dostępne w Premium.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.premium),
                icon: const Icon(Icons.workspace_premium, size: 20),
                label: const Text('Zobacz Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanAdjustmentCard(BuildContext context, UserProfile profile) {
    final isMaintain = _goal == AppConstants.goalMaintain;
    double minRate = 0.0;
    double maxRate = 0.0;
    double defaultValue = 0.0;
    if (_goal == AppConstants.goalWeightLoss) {
      minRate = 0.1;
      maxRate = AppConstants.maxWeightLossRate;
      defaultValue = 0.5;
    } else if (_goal == AppConstants.goalWeightGain) {
      minRate = 0.1;
      maxRate = 0.5;
      defaultValue = 0.25;
    }
    final currentRate = _manualWeeklyWeightChange ?? defaultValue;
    final clampedRate = isMaintain ? 0.0 : currentRate.clamp(minRate, maxRate);

    final cal = _manualTargetCalories ?? 0;
    final protein = _manualProteinG ?? 0;
    final fat = _manualFatG ?? 0;
    final carbs = _manualCarbsG ?? 0;
    final date = _manualTargetDate;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
        : '–';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dostosuj plan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tempo zmiany wagi',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${clampedRate.toStringAsFixed(1)} kg/tydz.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            if (!isMaintain)
              Slider(
                value: clampedRate,
                min: minRate,
                max: maxRate,
                divisions: ((maxRate - minRate) / 0.1).round().clamp(1, 100),
                label: '${clampedRate.toStringAsFixed(1)} kg/tydz.',
                onChanged: (value) {
                setState(() {
                  _manualWeeklyWeightChange = value;
                  _customCaloriesController.clear();
                  _recalculateFromRate();
                });
                },
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Dla utrzymania wagi tempo = 0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            if (_goal == AppConstants.goalWeightLoss) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Zalecane tempo: 0,5 kg/tydz. – bezpieczne i zdrowe. Szybsze chudnięcie może być niezdrowe (utrata mięśni, niedobory, zmęczenie).',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade900,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cal > 0) ...[
                    Text(
                      '${cal.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildMacroChip(context, 'Białko', protein, Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMacroChip(context, 'Tłuszcze', fat, Colors.orange)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMacroChip(context, 'Węgle', carbs, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Termin: $dateStr',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ] else
                    Text(
                      'Przesuń suwak, aby zobaczyć plan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Własny cel kaloryczny',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              childrenPadding: const EdgeInsets.only(top: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _customCaloriesController,
                        decoration: InputDecoration(
                          labelText: 'Cel (kcal)',
                          border: const OutlineInputBorder(),
                          errorText: _calorieWarning,
                          errorMaxLines: 5,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final calories = double.tryParse(value);
                          if (calories != null && calories > 0) {
                            setState(() {
                              _manualTargetCalories = calories;
                              _recalculateFromCalories();
                            });
                          } else if (value.isEmpty) {
                            setState(() {
                              _manualWeeklyWeightChange ??= defaultValue;
                              _recalculateFromRate();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Zostaw puste, aby obliczyć z tempa.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Własne makroskładniki',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              childrenPadding: const EdgeInsets.only(top: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildMacroInputCard(
                              context,
                              label: 'Białko',
                              controller: _proteinController,
                              color: Colors.blue,
                              kcalPerG: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMacroInputCard(
                              context,
                              label: 'Tłuszcze',
                              controller: _fatController,
                              color: Colors.orange,
                              kcalPerG: 9,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMacroInputCard(
                              context,
                              label: 'Węgle',
                              controller: _carbsController,
                              color: Colors.green,
                              kcalPerG: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kalorie i termin przeliczą się automatycznie.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (_macroPreviewKcal > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Suma: ${_macroPreviewKcal.toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                      if (_macroWarning != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _macroWarning!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                  maxLines: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_gender == null || _age == null || _heightCm == null ||
        _currentWeightKg == null || _targetWeightKg == null ||
        _activityLevel == null || _goal == null) {
      return false;
    }
    if (_age! < 13 || _age! > 100) return false;
    if (_heightCm! < 100 || _heightCm! > 250) return false;
    if (_currentWeightKg! < 30 || _currentWeightKg! > 300) return false;
    if (_targetWeightKg! < 30 || _targetWeightKg! > 300) return false;
    // Dla utrzymania wagi: różnica może być dowolna (nawet 0).
    // Dla schudnięcia/przytycia: wymagana różnica >= 1 kg.
    if (_goal != AppConstants.goalMaintain &&
        (_targetWeightKg! - _currentWeightKg!).abs() < 1.0) {
      return false;
    }
    if (_macroWarning != null || _calorieWarning != null) return false;
    return true;
  }

  void _recalculateFromRate() {
    // Zawsze przeliczaj, niezależnie od trybu ręcznej edycji
    // Zmiana tempa powinna zawsze aktualizować kalorie i makroskładniki
    if (_manualWeeklyWeightChange == null || _manualWeeklyWeightChange! <= 0) return;
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
    
    // Oblicz TDEE
    final bmr = Calculations.calculateBMR(
      gender: _gender!,
      weightKg: _currentWeightKg!,
      heightCm: _heightCm!,
      age: _age!,
    );
    
    final tdee = Calculations.calculateTDEE(
      bmr: bmr,
      activityLevel: _activityLevel!,
    );
    
    // Przelicz kalorie na podstawie tempa
    // 7700 kcal = 1 kg wagi
    // Dla utraty wagi: deficyt = tempo * 7700 / 7 (kcal/dzień)
    // Dla przybrania wagi: nadwyżka = tempo * 7700 / 7 (kcal/dzień)
    final weeklyCalorieChange = _manualWeeklyWeightChange! * 7700; // kcal/tydzień
    final dailyCalorieChange = weeklyCalorieChange / 7; // kcal/dzień
    
    double targetCalories;
    if (_goal! == AppConstants.goalWeightLoss) {
      targetCalories = tdee - dailyCalorieChange;
    } else if (_goal! == AppConstants.goalWeightGain) {
      targetCalories = tdee + dailyCalorieChange;
    } else {
      targetCalories = tdee;
    }
    
    // Przelicz makroskładniki na podstawie kalorii
    final macros = _calculateMacrosFromCalories(targetCalories, _targetWeightKg!);
    
    // Przelicz datę
    final weightDiff = (_targetWeightKg! - _currentWeightKg!).abs();
    final weeksNeeded = weightDiff > 0 ? (weightDiff / _manualWeeklyWeightChange!).ceil() : 0;
    final targetDate = weightDiff > 0 
        ? DateTime.now().add(Duration(days: weeksNeeded * 7))
        : DateTime.now().add(const Duration(days: 365));
    
    setState(() {
      _manualTargetCalories = targetCalories;
      _manualProteinG = macros['protein'];
      _manualFatG = macros['fat'];
      _manualCarbsG = macros['carbs'];
      _manualTargetDate = targetDate;
      _customCaloriesController.clear();
      _calorieWarning = null;
      _macroWarning = null;
      _syncMacroControllers();
    });
  }

  void _syncMacroControllers() {
    _proteinController.text = (_manualProteinG ?? 0).toStringAsFixed(0);
    _fatController.text = (_manualFatG ?? 0).toStringAsFixed(0);
    _carbsController.text = (_manualCarbsG ?? 0).toStringAsFixed(0);
  }

  void _updateCaloriesFromMacros() {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    if (protein < 0 || fat < 0 || carbs < 0) {
      setState(() => _macroWarning = 'Wartości nie mogą być ujemne.');
      return;
    }
    final calories = (protein * 4) + (fat * 9) + (carbs * 4);
    if (calories <= 0) {
      setState(() => _macroWarning = null);
      return;
    }
    // Walidacja realistycznych limitów
    String? macroWarning;
    if (protein > AppConstants.maxProteinG || fat > AppConstants.maxFatG || carbs > AppConstants.maxCarbsG) {
      final parts = <String>[];
      if (protein > AppConstants.maxProteinG) parts.add('białko max ${AppConstants.maxProteinG.toStringAsFixed(0)} g');
      if (fat > AppConstants.maxFatG) parts.add('tłuszcze max ${AppConstants.maxFatG.toStringAsFixed(0)} g');
      if (carbs > AppConstants.maxCarbsG) parts.add('węglowodany max ${AppConstants.maxCarbsG.toStringAsFixed(0)} g');
      macroWarning = '⚠️ Wartości przekraczają zalecane limity dzienne: ${parts.join(', ')}. '
          'Wprowadź realistyczne wartości dla zdrowej diety.';
    } else if (calories > AppConstants.maxCaloriesFromMacros) {
      macroWarning = '⚠️ Łączna liczba kalorii (${calories.toStringAsFixed(0)} kcal) jest nierealistyczna dla dziennego zapotrzebowania. '
          'Zalecane maksimum to ok. ${AppConstants.maxCaloriesFromMacros.toStringAsFixed(0)} kcal/dzień.';
    }
    if (macroWarning != null) {
      setState(() {
        _macroWarning = macroWarning;
        _calorieWarning = null;
      });
      return;
    }
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
    final bmr = Calculations.calculateBMR(
      gender: _gender!,
      weightKg: _currentWeightKg!,
      heightCm: _heightCm!,
      age: _age!,
    );
    final tdee = Calculations.calculateTDEE(bmr: bmr, activityLevel: _activityLevel!);
    // Walidacja: kalorie muszą być zgodne z celem (waga docelowa)
    if (_goal! == AppConstants.goalWeightLoss) {
      if (calories >= tdee) {
        setState(() {
          _macroWarning = 'Twój cel to chudnięcie (waga docelowa niższa niż obecna), '
              'ale wprowadzone makroskładniki dają ${(calories - tdee).toStringAsFixed(0)} kcal powyżej zapotrzebowania (TDEE: ${tdee.toStringAsFixed(0)} kcal). '
              'Zmniejsz kalorie/makroskładniki, aby osiągnąć deficyt.';
          _calorieWarning = null;
        });
        return;
      }
    } else if (_goal! == AppConstants.goalWeightGain) {
      if (calories <= tdee) {
        setState(() {
          _macroWarning = 'Twój cel to przybieranie na wadze (waga docelowa wyższa niż obecna), '
              'ale wprowadzone makroskładniki dają deficyt (TDEE: ${tdee.toStringAsFixed(0)} kcal). '
              'Zwiększ kalorie/makroskładniki, aby osiągnąć nadwyżkę.';
          _calorieWarning = null;
        });
        return;
      }
    }
    final dailyChange = calories - tdee;
    final weeklyCalChange = dailyChange.abs() * 7;
    final weightDiff = (_targetWeightKg! - _currentWeightKg!).abs();
    double? newRate;
    DateTime? newDate;
    if (weightDiff > 0 && weeklyCalChange > 0) {
      newRate = (weeklyCalChange / 7700).clamp(0.1, _goal! == AppConstants.goalWeightLoss ? AppConstants.maxWeightLossRate : 0.5);
      final weeks = (weightDiff / newRate).ceil();
      newDate = DateTime.now().add(Duration(days: weeks * 7));
    } else {
      newDate = DateTime.now().add(const Duration(days: 365));
    }
    setState(() {
      _manualTargetCalories = calories;
      _manualProteinG = protein;
      _manualFatG = fat;
      _manualCarbsG = carbs;
      if (newRate != null) _manualWeeklyWeightChange = newRate;
      _manualTargetDate = newDate;
      _customCaloriesController.text = calories.toStringAsFixed(0);
      _calorieWarning = null;
      _macroWarning = null;
    });
  }

  void _recalculateFromCalories() {
    // Ta funkcja działa zawsze, nie tylko w trybie ręcznym
    if (_manualTargetCalories == null) return;
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
    
    // Oblicz TDEE
    final bmr = Calculations.calculateBMR(
      gender: _gender!,
      weightKg: _currentWeightKg!,
      heightCm: _heightCm!,
      age: _age!,
    );
    
    final tdee = Calculations.calculateTDEE(
      bmr: bmr,
      activityLevel: _activityLevel!,
    );
    
    // Walidacja - sprawdź czy cel kaloryczny jest realistyczny
    String? warning;
    final calorieDifference = _manualTargetCalories! - tdee;
    
    if (_goal! == AppConstants.goalWeightLoss) {
      // Dla utraty wagi: cel powinien być poniżej TDEE
      if (calorieDifference > 0) {
        // Nadwyżka kaloryczna przy chudnięciu - niemożliwe
        warning = '⚠️ Cel kaloryczny jest wyższy niż TDEE (${tdee.toStringAsFixed(0)} kcal). '
            'Aby schudnąć, musisz mieć deficyt kaloryczny. '
            'Maksymalny bezpieczny deficyt to ~1100 kcal/dzień (ok. 1 kg/tydzień).';
      } else if (calorieDifference < -1500) {
        // Zbyt duży deficyt
        warning = '⚠️ Deficyt kaloryczny jest bardzo duży (${(-calorieDifference).toStringAsFixed(0)} kcal/dzień). '
            'Zalecany maksymalny deficyt to 1000-1500 kcal/dzień dla bezpiecznej utraty wagi.';
      } else if (calorieDifference < -100) {
        // OK - deficyt w rozsądnym zakresie
        warning = null;
      } else {
        // Za mały deficyt lub brak deficytu
        warning = '⚠️ Deficyt kaloryczny jest bardzo mały. '
            'Dla skutecznej utraty wagi zalecany jest deficyt 500-1000 kcal/dzień.';
      }
    } else if (_goal! == AppConstants.goalWeightGain) {
      // Dla przybrania wagi: cel powinien być powyżej TDEE
      if (calorieDifference < 0) {
        // Deficyt kaloryczny przy przybieraniu - niemożliwe
        warning = '⚠️ Cel kaloryczny jest niższy niż TDEE (${tdee.toStringAsFixed(0)} kcal). '
            'Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną. '
            'Zalecana nadwyżka to 250-500 kcal/dzień (ok. 0.25-0.5 kg/tydzień).';
      } else if (calorieDifference > 1000) {
        // Zbyt duża nadwyżka
        warning = '⚠️ Nadwyżka kaloryczna jest bardzo duża (${calorieDifference.toStringAsFixed(0)} kcal/dzień). '
            'Zalecana nadwyżka to 250-500 kcal/dzień dla zdrowego przybierania na wadze.';
      } else if (calorieDifference > 100) {
        // OK - nadwyżka w rozsądnym zakresie
        warning = null;
      } else {
        // Za mała nadwyżka
        warning = '⚠️ Nadwyżka kaloryczna jest bardzo mała. '
            'Dla skutecznego przybierania na wadze zalecana jest nadwyżka 250-500 kcal/dzień.';
      }
    } else {
      // Utrzymanie wagi: cel powinien być blisko TDEE
      if (calorieDifference.abs() > 200) {
        warning = '⚠️ Cel kaloryczny różni się znacznie od TDEE (${tdee.toStringAsFixed(0)} kcal). '
            'Dla utrzymania wagi cel powinien być zbliżony do TDEE (±100-200 kcal).';
      } else {
        warning = null;
      }
    }
    
    // Przelicz tempo na podstawie kalorii
    final dailyCalorieChange = calorieDifference.abs();
    final weeklyCalorieChange = dailyCalorieChange * 7;
    final weeklyWeightChange = weeklyCalorieChange / 7700; // 7700 kcal = 1 kg
    
    // Ogranicz tempo do zdrowych wartości
    double clampedRate;
    if (_goal! == AppConstants.goalWeightLoss) {
      clampedRate = weeklyWeightChange.clamp(0.1, AppConstants.maxWeightLossRate);
    } else if (_goal! == AppConstants.goalWeightGain) {
      clampedRate = weeklyWeightChange.clamp(0.1, 0.5);
    } else {
      clampedRate = 0.0;
    }
    
    // Przelicz makroskładniki na podstawie kalorii
    final macros = _calculateMacrosFromCalories(_manualTargetCalories!, _targetWeightKg!);
    
    // Przelicz datę
    final weightDiff = (_targetWeightKg! - _currentWeightKg!).abs();
    final weeksNeeded = weightDiff > 0 && clampedRate > 0 ? (weightDiff / clampedRate).ceil() : 0;
    final targetDate = weightDiff > 0 && clampedRate > 0
        ? DateTime.now().add(Duration(days: weeksNeeded * 7))
        : DateTime.now().add(const Duration(days: 365));
    
    setState(() {
      _calorieWarning = warning;
      _manualWeeklyWeightChange = clampedRate;
      _manualProteinG = macros['protein'];
      _manualFatG = macros['fat'];
      _manualCarbsG = macros['carbs'];
      _manualTargetDate = targetDate;
      _syncMacroControllers();
    });
  }

  Map<String, double> _calculateMacrosFromCalories(double calories, double targetWeight) {
    // Min. 50g węglowodanów – wytyczne zdrowego odżywiania (mózg, energia)
    const minCarbsG = 50.0;
    const minCarbsKcal = minCarbsG * 4;
    final availableForPf = (calories - minCarbsKcal).clamp(0.0, double.infinity);

    var proteinG = targetWeight * 2.0;
    var proteinCalories = proteinG * 4;
    var fatCalories = calories * 0.275;
    var fatG = fatCalories / 9;

    // Gdy białko+tłuszcze przekraczają dostępny budżet – skaluj je, zostawiając min. 50g węgli
    if (proteinCalories + fatCalories > availableForPf && availableForPf > 0) {
      final totalPf = proteinCalories + fatCalories;
      final scale = availableForPf / totalPf;
      proteinCalories *= scale;
      fatCalories *= scale;
      proteinG = proteinCalories / 4;
      fatG = fatCalories / 9;
    }

    final carbsCalories = calories - proteinCalories - fatCalories;
    final carbsG = (carbsCalories / 4).clamp(minCarbsG, double.infinity);

    return {
      'protein': proteinG,
      'fat': fatG,
      'carbs': carbsG,
    };
  }


  Future<void> _saveProfile(BuildContext context, UserProfile oldProfile) async {
    if (!_canProceed() || _isSaving) return;
    
    final messenger = ScaffoldMessenger.of(context);
    
    // Walidacja przed zapisaniem - sprawdź czy nie ma absurdalnych wartości
    if (_manualTargetCalories != null) {
      if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
      if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
      
      final bmr = Calculations.calculateBMR(
        gender: _gender!,
        weightKg: _currentWeightKg!,
        heightCm: _heightCm!,
        age: _age!,
      );
      
      final tdee = Calculations.calculateTDEE(
        bmr: bmr,
        activityLevel: _activityLevel!,
      );
      
      final calorieDifference = _manualTargetCalories! - tdee;
      
      // Blokuj zapis jeśli wartości są absurdalne
      if (_goal! == AppConstants.goalWeightLoss && calorieDifference > 500) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Nie można zapisać: Cel kaloryczny (${_manualTargetCalories!.toStringAsFixed(0)} kcal) jest wyższy niż TDEE (${tdee.toStringAsFixed(0)} kcal). '
              'Aby schudnąć, musisz mieć deficyt kaloryczny.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_goal! == AppConstants.goalWeightGain && calorieDifference < -200) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Nie można zapisać: Cel kaloryczny (${_manualTargetCalories!.toStringAsFixed(0)} kcal) jest niższy niż TDEE (${tdee.toStringAsFixed(0)} kcal). '
              'Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      // Przelicz wartości (zawsze obliczamy BMR i TDEE)
      final bmr = Calculations.calculateBMR(
        gender: _gender!,
        weightKg: _currentWeightKg!,
        heightCm: _heightCm!,
        age: _age!,
      );

      final tdee = Calculations.calculateTDEE(
        bmr: bmr,
        activityLevel: _activityLevel!,
      );

      // Jeśli ręczna edycja jest włączona, użyj ręcznych wartości
      double? targetCalories;
      double? targetProteinG;
      double? targetFatG;
      double? targetCarbsG;
      DateTime? targetDate;
      double? weeklyWeightChange = _manualWeeklyWeightChange; // Zawsze używaj ręcznego tempa jeśli jest ustawione

      // Jeśli tempo zostało zmienione (nawet bez checkboxa), użyj przeliczonych wartości
      // Sprawdź czy tempo różni się od oryginalnego lub czy są przeliczone wartości
      final originalRate = oldProfile.weeklyWeightChange;
      final rateChanged = weeklyWeightChange != null && 
                         originalRate != null && 
                         (weeklyWeightChange - originalRate).abs() > 0.01;
      
      final hasAccess = ref.read(hasPremiumAccessProvider);
      final useManualPlan = hasAccess &&
          (rateChanged || (_manualTargetCalories != null && weeklyWeightChange != null && weeklyWeightChange > 0));
      if (useManualPlan) {
        // Jeśli tempo się zmieniło, ale wartości nie są przeliczone, przelicz teraz
        if (rateChanged && (_manualTargetCalories == null || _manualProteinG == null)) {
          _recalculateFromRate();
        }
        targetCalories = _manualTargetCalories;
        targetProteinG = _manualProteinG;
        targetFatG = _manualFatG;
        targetCarbsG = _manualCarbsG;
        targetDate = _manualTargetDate;
      } else {
        // Użyj automatycznego przeliczenia
        final macros = Calculations.calculateMacros(
          tdee: tdee,
          goal: _goal!,
          targetWeightKg: _targetWeightKg!,
        );

        targetCalories = (macros['calories'] as num?)?.toDouble();
        targetProteinG = (macros['protein'] as num?)?.toDouble();
        targetFatG = (macros['fat'] as num?)?.toDouble();
        targetCarbsG = (macros['carbs'] as num?)?.toDouble();
        
        // Przelicz datę używając ręcznego tempa lub domyślnego
        if (weeklyWeightChange != null && weeklyWeightChange > 0) {
          final weightDiff = (_targetWeightKg! - _currentWeightKg!).abs();
          if (weightDiff > 0) {
            final weeksNeeded = (weightDiff / weeklyWeightChange).ceil();
            targetDate = DateTime.now().add(Duration(days: weeksNeeded * 7));
          } else {
            targetDate = DateTime.now().add(const Duration(days: 365));
          }
        } else {
          targetDate = Calculations.calculateTargetDate(
            currentWeight: _currentWeightKg!,
            targetWeight: _targetWeightKg!,
            goal: _goal!,
          );
          // Użyj domyślnego tempa jeśli nie jest ustawione ręcznie
          if (_goal! == AppConstants.goalWeightLoss) {
            weeklyWeightChange = AppConstants.defaultWeightLossRate;
          } else if (_goal! == AppConstants.goalWeightGain) {
            weeklyWeightChange = AppConstants.defaultWeightGainRate;
          }
        }
      }

      final suggestedWater = Calculations.calculateDailyWaterGoalMl(_currentWeightKg!);
      final waterGoal = (_waterGoalMl != null && _waterGoalMl != _initialWaterGoalMl)
          ? _waterGoalMl!
          : suggestedWater;
      final updatedProfile = UserProfile(
        userId: userId,
        gender: _gender!,
        age: _age!,
        heightCm: _heightCm!,
        currentWeightKg: _currentWeightKg!,
        targetWeightKg: _targetWeightKg!,
        activityLevel: _activityLevel!,
        goal: _goal!,
        bmr: bmr,
        tdee: tdee,
        targetCalories: targetCalories,
        targetProteinG: targetProteinG,
        targetFatG: targetFatG,
        targetCarbsG: targetCarbsG,
        targetDate: targetDate,
        weeklyWeightChange: weeklyWeightChange,
        waterGoalMl: waterGoal,
      );

      final service = SupabaseService();
      await service.updateProfile(updatedProfile);
      
      // Zapisz historię zmian celu (jeśli były zmiany)
      if (_originalTargetCalories != null || _originalTargetDate != null) {
        final hasCalorieChange = _originalTargetCalories != null && 
                                 targetCalories != null && 
                                 _originalTargetCalories != targetCalories;
        final originalDate = _originalTargetDate;
        final hasDateChange = originalDate != null && 
                              targetDate != null && 
                              originalDate.day != targetDate.day;
        final oldRate = oldProfile.weeklyWeightChange;
        final hasRateChange = oldRate != null && 
                             weeklyWeightChange != null && 
                             oldRate != weeklyWeightChange;
        
        if (hasCalorieChange || hasDateChange || hasRateChange) {
          await service.saveGoalHistory(
            userId: userId,
            oldTargetCalories: _originalTargetCalories,
            newTargetCalories: targetCalories,
            oldTargetDate: _originalTargetDate,
            newTargetDate: targetDate,
            oldWeeklyWeightChange: oldProfile.weeklyWeightChange,
            newWeeklyWeightChange: weeklyWeightChange,
            reason: 'Edycja profilu',
          );
        }
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        
        ref.invalidate(profileProvider);
        // Odśwież również dashboard, aby pokazał zaktualizowany cel
        ref.invalidate(dashboardDataProvider);
        
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profil zaktualizowany pomyślnie! Cel został przeliczony.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      
      messenger.showSnackBar(
        SnackBar(
          content: Text('Błąd podczas zapisywania: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
