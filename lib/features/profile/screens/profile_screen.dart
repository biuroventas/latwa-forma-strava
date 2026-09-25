import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../../shared/services/revenuecat_service.dart';
import '../../../shared/services/supabase_service.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../shared/widgets/health_disclaimer.dart';
import '../../../shared/widgets/language_switch.dart';
import '../../../shared/widgets/save_progress_checker.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../legal/legal_document_screen.dart';

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
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _weeklyRateController = TextEditingController();
  final _waterGoalController = TextEditingController();

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
    final p = _parseMacro(_proteinController.text) ?? 0;
    final f = _parseMacro(_fatController.text) ?? 0;
    final c = _parseMacro(_carbsController.text) ?? 0;
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
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _weeklyRateController.dispose();
    _waterGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(context.l10n.profTitle),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: context.l10n.profNotifications,
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
      bottomNavigationBar: _buildLegalLinks(context),
      body: profile.when(
        data: (data) {
          if (data == null) {
            return Center(child: Text(context.l10n.profNoProfile));
          }
          if (_isEditing) {
            return _buildEditForm(context, data);
          }
          final isAnonymous = SupabaseConfig.auth.currentUser?.isAnonymous ?? false;
          if (!isAnonymous) {
            return _buildProfileContent(context, data);
          }
          return Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.profSaveProgress,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.profSaveProgressHint,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () async {
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
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          overlayColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.save_alt, size: 18, color: Colors.white),
                        label: Text(context.l10n.profSaveProgress),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildProfileContent(context, data)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.profErrorWithDetail(error: '$error')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: Text(context.l10n.commonRetry),
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
      _waterGoalController.text = (_waterGoalMl ?? suggestedWater).toStringAsFixed(0);
      _manualWeeklyWeightChange = profile.weeklyWeightChange ??
          (_goal == AppConstants.goalWeightLoss
              ? AppConstants.defaultWeightLossRate
              : _goal == AppConstants.goalWeightGain
                  ? AppConstants.defaultWeightGainRate
                  : 0.0);
      _customCaloriesController.clear();
      _syncMacroControllers();
      _ageController.text = profile.age.toString();
      _heightController.text = profile.heightCm.toStringAsFixed(0);
      _currentWeightController.text = profile.currentWeightKg.toStringAsFixed(1);
      _targetWeightController.text = profile.targetWeightKg.toStringAsFixed(1);
      _weeklyRateController.text = (_manualWeeklyWeightChange ?? 0).toStringAsFixed(1);
      
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
      if (provider == 'google') return context.l10n.profAccountGoogle;
      if (provider == 'email') return context.l10n.profAccountEmail;
    }
    return context.l10n.profAccountSignedIn;
  }

  void _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.profSignOutTitle),
        content: Text(context.l10n.profSignOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.profSignOutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await RevenueCatService.instance.logOut();
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
    final isAnonymous = SupabaseConfig.auth.currentUser?.isAnonymous ?? false;
    final l10n = context.l10n;
    final title = isAnonymous ? l10n.profDeleteData : l10n.profDeleteAccountTitle;
    final body = isAnonymous ? l10n.profDeleteDataBody : l10n.profDeleteAccountBody;
    final confirmLabel = isAnonymous ? l10n.profDeleteData : l10n.profDeleteAccountTitle;
    final successMsg = isAnonymous ? l10n.profDataDeleted : l10n.profAccountDeleted;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmLabel),
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
        final msg = _getDeleteAccountErrorMessage(err, response.status, l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
        return;
      }
      await RevenueCatService.instance.logOut();
      await SupabaseConfig.auth.signOut();
      await markSignOut();
      if (!context.mounted) return;
      context.go(AppRoutes.welcome);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete account/data error: $e');
      if (context.mounted) {
        final msg = _getDeleteAccountErrorMessage(e.toString(), null, l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getDeleteAccountErrorMessage(Object? err, int? status, AppLocalizations l10n) {
    final s = err?.toString() ?? status?.toString() ?? '';
    if (s.contains('404') || s.contains('NOT_FOUND')) {
      return l10n.profDeleteUnavailable(email: AppConstants.contactEmail);
    }
    if (s.contains('401') || s.contains('Nieprawidłowa sesja')) {
      return l10n.profSessionExpiredRetry;
    }
    if (s.contains('403') || s.contains('forbidden')) {
      return l10n.profNoPermission;
    }
    return l10n.profDeleteFailed;
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        bool loading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(context.l10n.profInviteTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.profInviteBody,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: context.l10n.profEmailLabel,
                    hintText: context.l10n.profEmailHintFriend,
                  ),
                  enabled: !loading,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.commonCancel),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        final email = controller.text.trim();
                        if (email.isEmpty) return;
                        setState(() => loading = true);
                        try {
                          // Jak przy „Usuń konto”: odśwież sesję, potem wywołaj Edge Function przez klienta (apikey + token).
                          final refreshed = await SupabaseConfig.auth.refreshSession();
                          final session = refreshed.session ?? SupabaseConfig.auth.currentSession;
                          if (session == null) {
                            if (!ctx.mounted) return;
                            setState(() => loading = false);
                            Navigator.of(ctx).pop({
                              'success': false,
                              'error': kIsWeb
                                  ? context.l10n.profSessionExpiredWebInvite
                                  : context.l10n.profLoginAgainRetry,
                            });
                            return;
                          }
                          final response = await SupabaseConfig.client.functions.invoke(
                            'invite_user',
                            body: {'email': email},
                            headers: {'Authorization': 'Bearer ${session.accessToken}'},
                          );
                          if (!ctx.mounted) return;
                          setState(() => loading = false);
                          final data = response.data is Map ? response.data as Map<String, dynamic>? : null;
                          final err = data?['error'] ?? response.status;
                          if (response.status == 200 && data?['success'] == true) {
                            Navigator.of(ctx).pop({'success': true, 'message': data?['message'] ?? context.l10n.profInviteSent});
                          } else if (response.status == 401) {
                            Navigator.of(ctx).pop({
                              'success': false,
                              'error': kIsWeb
                                  ? context.l10n.profSessionExpiredWebRetry
                                  : context.l10n.profSessionExpiredInviteMobile,
                            });
                          } else {
                            Navigator.of(ctx).pop({'success': false, 'error': err.toString()});
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setState(() => loading = false);
                            String userMessage;
                            if (e is FunctionException) {
                              final details = e.details;
                              final serverError = details is Map && details['error'] is String
                                  ? details['error'] as String
                                  : null;
                              if (serverError != null) {
                                final lower = serverError.toLowerCase();
                                // Kolejność ważna: najpierw "zaproszenie już wysłane", potem "już zarejestrowany", na końcu "prawidłowy email"
                                if (lower.contains('wysłano już zaproszenie') ||
                                    lower.contains('already invited') ||
                                    lower.contains('invitation has already been sent')) {
                                  userMessage = context.l10n.profInviteAlreadySent;
                                } else if (lower.contains('już ma') ||
                                    lower.contains('already been registered') ||
                                    lower.contains('already exists') ||
                                    lower.contains('zarejestrowan')) {
                                  userMessage = context.l10n.profEmailAlreadyRegistered;
                                } else if (lower.contains('zbyt wiele') ||
                                    lower.contains('rate limit')) {
                                  userMessage = context.l10n.profInviteRateLimit;
                                } else if (lower.contains('prawidłowy') ||
                                    (lower.contains('e-mail') && !lower.contains('invit') && !lower.contains('wysłano'))) {
                                  userMessage = context.l10n.profEnterValidEmail;
                                } else {
                                  userMessage = serverError;
                                }
                              } else {
                                userMessage = context.l10n.profInviteSendFailed;
                              }
                            } else {
                              final msg = e.toString();
                              final is401 = msg.contains('401') || msg.contains('Invalid JWT');
                              userMessage = is401 && kIsWeb
                                  ? context.l10n.profSessionExpiredWebShort
                                  : is401
                                      ? context.l10n.profSessionExpiredSignOutIn
                                      : context.l10n.profInviteSendFailed;
                            }
                            Navigator.of(ctx).pop({'success': false, 'error': userMessage});
                          }
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.profSendInvite),
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
          content: Text(result['message']?.toString() ?? context.l10n.profInviteSentExclaim),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.l10n.language,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const LanguageSwitch(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.profBasicData,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildProfileRow(context, context.l10n.profGender, _getGenderText(profile.gender)),
                  _buildProfileRow(context, context.l10n.profAge, context.l10n.profAgeYears(age: profile.age)),
                  _buildProfileRow(context, context.l10n.profHeight, '${profile.heightCm.toStringAsFixed(0)} cm'),
                  _buildProfileRow(context, context.l10n.profCurrentWeight, '${profile.currentWeightKg.toStringAsFixed(1)} kg'),
                  _buildProfileRow(context, context.l10n.profTargetWeight, '${profile.targetWeightKg.toStringAsFixed(1)} kg'),
                  _buildProfileRow(context, context.l10n.profActivityLevel, _getActivityLevelText(profile.activityLevel)),
                  _buildProfileRow(context, context.l10n.profGoal, _getGoalText(profile.goal)),
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
                      context.l10n.profCalculations,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (profile.bmr != null)
                      _buildProfileRow(context, 'BMR', '${profile.bmr!.toStringAsFixed(0)} kcal',
                        explanation: context.l10n.profBmrExplain),
                    if (profile.tdee != null)
                      _buildProfileRow(context, 'TDEE', '${profile.tdee!.toStringAsFixed(0)} kcal',
                        explanation: context.l10n.profTdeeExplain),
                    if (profile.targetCalories != null)
                      _buildProfileRow(context, context.l10n.profCalorieGoal, '${profile.targetCalories!.toStringAsFixed(0)} kcal',
                        explanation: context.l10n.profCalorieGoalExplain),
                    _buildProfileRow(
                      context,
                      context.l10n.profWaterGoal,
                      '${(profile.waterGoalMl ?? Calculations.calculateDailyWaterGoalMl(profile.currentWeightKg)).toStringAsFixed(0)} ml',
                      explanation: _waterGoalExplanationL10n(context, profile.currentWeightKg),
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
                      context.l10n.profMacros,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (profile.targetProteinG != null)
                      _buildProfileRow(context, context.l10n.profProtein, '${profile.targetProteinG!.toStringAsFixed(0)} g'),
                    if (profile.targetFatG != null)
                      _buildProfileRow(context, context.l10n.profFat, '${profile.targetFatG!.toStringAsFixed(0)} g'),
                    if (profile.targetCarbsG != null)
                      _buildProfileRow(context, context.l10n.profCarbs, '${profile.targetCarbsG!.toStringAsFixed(0)} g'),
                  ],
                ),
              ),
            ),
          if (profile.goal == AppConstants.goalMaintain ||
              (profile.currentWeightKg - profile.targetWeightKg).abs() < 0.5) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profMaintainNoDateTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.profMaintainNoDateBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => _startEditing(profile),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          overlayColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                        label: Text(context.l10n.profMaintainNoDateCta),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (profile.targetDate != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profTargetDateTitle,
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
                      context.l10n.profTargetDateHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.profSpeedUpHint,
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
                            context.l10n.profAiAdvice,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.profAiAdviceHint,
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
                            context.l10n.profBmiTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.profBmiHint,
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
                  ? context.l10n.profTrialLeft(
                      hours: trialRemaining.inHours,
                      minutes: trialRemaining.inMinutes % 60,
                    )
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
                                  Expanded(
                                    child: Text(
                                      hasPremiumAccess ? context.l10n.profPremiumTitleActive : context.l10n.profPremiumTitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
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
                                        context.l10n.profActive,
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
                                    ? context.l10n.profPremiumHintActive
                                    : context.l10n.profPremiumHint,
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
                            context.l10n.profIntegrations,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.profIntegrationsHint,
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
                            context.l10n.profExport,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.profExportHint,
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
                              context.l10n.profInviteTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.profInviteHint,
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
          const HealthDisclaimer(),
          if (user != null) ...[
            const SizedBox(height: 16),
            if (!isAnonymous)
              _buildAccountSection(context, user)
            else
              _buildAnonymousDataSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAnonymous = SupabaseConfig.auth.currentUser?.isAnonymous ?? false;
    final linkStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.primary,
      height: 1.2,
    );
    final sepStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
      height: 1.2,
    );
    final deleteStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.error.withValues(alpha: 0.85),
      height: 1.2,
    );

    ButtonStyle compactLinkStyle() => TextButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          visualDensity: VisualDensity.compact,
        );

    Widget sep() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('·', style: sepStyle),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2B1C) : const Color(0xFFE8F5E9),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.18),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                runSpacing: 2,
                children: [
                  TextButton(
                    style: compactLinkStyle(),
                    onPressed: () => openLegalOrExternal(context, AppConstants.privacyPolicyUrl),
                    child: Text(context.l10n.profPrivacy, style: linkStyle),
                  ),
                  sep(),
                  TextButton(
                    style: compactLinkStyle(),
                    onPressed: () => openLegalOrExternal(context, AppConstants.termsUrl),
                    child: Text(context.l10n.profTerms, style: linkStyle),
                  ),
                  sep(),
                  TextButton(
                    style: compactLinkStyle(),
                    onPressed: () => _openUrl(AppConstants.appleEulaUrl),
                    child: Text(context.l10n.profEula, style: linkStyle),
                  ),
                ],
              ),
              // Gość: tylko „Usuń dane” w sekcji urządzenia. Konto: „Usuń konto” w stopce.
              if (!isAnonymous) ...[
                const SizedBox(height: 2),
                TextButton(
                  style: compactLinkStyle(),
                  onPressed: () => _handleDeleteAccount(context),
                  child: Text(context.l10n.profDeleteAccountTitle, style: deleteStyle),
                ),
              ],
            ],
          ),
        ),
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
                        context.l10n.profYourAccount,
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
                      if (user.email != null && user.email!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.email!.trim(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                    label: Text(context.l10n.profSignOutTitle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _handleDeleteAccount(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white),
                  label: Text(
                    context.l10n.profDeleteAccountTitle,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    overlayColor: Colors.black26,
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

  Widget _buildAnonymousDataSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profDeviceData,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.profDeviceDataHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _handleDeleteAccount(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                overlayColor: Colors.black26,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white),
              label: Text(context.l10n.profDeleteData),
            ),
          ),
        ],
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

  String _waterGoalExplanationL10n(BuildContext context, double weightKg) {
    final goal = Calculations.calculateDailyWaterGoalMl(weightKg);
    final mlPerKg = AppConstants.waterMlPerKg.toInt();
    final rawMl = (weightKg * AppConstants.waterMlPerKg).round();
    final weightStr = weightKg == weightKg.roundToDouble()
        ? weightKg.toStringAsFixed(0)
        : weightKg.toStringAsFixed(1);
    return context.l10n.profWaterGoalExplanation(
      mlPerKg: mlPerKg,
      weightKg: weightStr,
      rawMl: rawMl,
      goalMl: goal.round(),
    );
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'male':
        return context.l10n.profGenderMale;
      case 'female':
        return context.l10n.profGenderFemale;
      default:
        return context.l10n.profGenderOther;
    }
  }

  String _getActivityLevelText(String level) {
    switch (level) {
      case 'sedentary':
        return context.l10n.profActSedentary;
      case 'light':
        return context.l10n.profActLight;
      case 'moderate':
        return context.l10n.profActModerate;
      case 'intense':
        return context.l10n.profActIntense;
      case 'very_intense':
        return context.l10n.profActVeryIntense;
      default:
        return level;
    }
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'weight_loss':
        return context.l10n.profGoalLoss;
      case 'weight_gain':
        return context.l10n.profGoalGain;
      case 'maintain':
        return context.l10n.profGoalMaintain;
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
            Text(context.l10n.profGenderRequired, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildGenderOption(context.l10n.profGenderMale, AppConstants.genderMale)),
                const SizedBox(width: 8),
                Expanded(child: _buildGenderOption(context.l10n.profGenderFemale, AppConstants.genderFemale)),
              ],
            ),
            const SizedBox(height: 16),
            // Wiek
            Text(context.l10n.profAgeRequired, style: Theme.of(context).textTheme.titleMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: (_age ?? profile.age).toDouble().clamp(13.0, 100.0),
                    min: 13,
                    max: 100,
                    divisions: 87,
                    label: (_age ?? profile.age).toString(),
                    onChanged: (value) {
                      setState(() {
                        _age = value.round();
                        _ageController.text = value.round().toString();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: context.l10n.profYearsSuffix,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    ),
                    onChanged: (s) {
                      final v = int.tryParse(s.trim());
                      if (v != null && v >= 13 && v <= 100) {
                        setState(() {
                          _age = v;
                        });
                        _triggerRecalcFromProfileFields();
                      }
                    },
                    onSubmitted: (s) {
                      final v = int.tryParse(s.trim());
                      if (v != null && v >= 13 && v <= 100) {
                        setState(() {
                          _age = v;
                          _ageController.text = v.toString();
                        });
                        _triggerRecalcFromProfileFields();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Wzrost
            Text(context.l10n.profHeightRequired, style: Theme.of(context).textTheme.titleMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: (_heightCm ?? profile.heightCm).clamp(100.0, 250.0),
                    min: 100,
                    max: 250,
                    divisions: 150,
                    label: (_heightCm ?? profile.heightCm).round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _heightCm = value.round().toDouble();
                        _heightController.text = value.round().toString();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    ),
                    onChanged: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 100 && v <= 250) {
                        setState(() {
                          _heightCm = v.round().toDouble();
                        });
                        _triggerRecalcFromProfileFields();
                      }
                    },
                    onSubmitted: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 100 && v <= 250) {
                        setState(() {
                          _heightCm = v.round().toDouble();
                          _heightController.text = v.round().toString();
                        });
                        _triggerRecalcFromProfileFields();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Aktualna waga
            Text(context.l10n.profCurrentWeightRequired, style: Theme.of(context).textTheme.titleMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: (_currentWeightKg ?? profile.currentWeightKg).clamp(30.0, 300.0),
                    min: 30,
                    max: 300,
                    divisions: 270,
                    label: (_currentWeightKg ?? profile.currentWeightKg).toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _currentWeightKg = value;
                        _targetWeightKg ??= value;
                        _currentWeightController.text = value.toStringAsFixed(1);
                        _updateGoalFromWeights();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _currentWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    ),
                    onChanged: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 30 && v <= 300) {
                        setState(() {
                          _currentWeightKg = v;
                          _targetWeightKg ??= v;
                        });
                        _updateGoalFromWeights();
                      }
                    },
                    onSubmitted: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 30 && v <= 300) {
                        setState(() {
                          _currentWeightKg = v;
                          _targetWeightKg ??= v;
                          _currentWeightController.text = v.toStringAsFixed(1);
                        });
                        _updateGoalFromWeights();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Waga docelowa
            Text(context.l10n.profTargetWeightRequired, style: Theme.of(context).textTheme.titleMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: (_targetWeightKg ?? profile.targetWeightKg).clamp(30.0, 300.0),
                    min: 30,
                    max: 300,
                    divisions: 270,
                    label: (_targetWeightKg ?? profile.targetWeightKg).toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _targetWeightKg = value;
                        _targetWeightController.text = value.toStringAsFixed(1);
                        _updateGoalFromWeights();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _targetWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    ),
                    onChanged: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 30 && v <= 300) {
                        setState(() {
                          _targetWeightKg = v;
                        });
                        _updateGoalFromWeights();
                      }
                    },
                    onSubmitted: (s) {
                      final v = double.tryParse(s.trim().replaceAll(',', '.'));
                      if (v != null && v >= 30 && v <= 300) {
                        setState(() {
                          _targetWeightKg = v;
                          _targetWeightController.text = v.toStringAsFixed(1);
                        });
                        _updateGoalFromWeights();
                      }
                    },
                  ),
                ),
              ],
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
                  context.l10n.profWeightDiffError,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            // Poziom aktywności
            Text(context.l10n.profActivityRequired, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            _buildActivityLevelOption(context.l10n.profActSedentary, context.l10n.profActSedentaryDesc, AppConstants.activitySedentary),
            const SizedBox(height: 4),
            _buildActivityLevelOption(context.l10n.profActLight, context.l10n.profActLightDesc, AppConstants.activityLight),
            const SizedBox(height: 4),
            _buildActivityLevelOption(context.l10n.profActModerate, context.l10n.profActModerateDesc, AppConstants.activityModerate),
            const SizedBox(height: 4),
            _buildActivityLevelOption(context.l10n.profActIntense, context.l10n.profActIntenseDesc, AppConstants.activityIntense),
            const SizedBox(height: 4),
            _buildActivityLevelOption(context.l10n.profActVeryIntense, context.l10n.profActVeryIntenseDesc, AppConstants.activityVeryIntense),
            const SizedBox(height: 16),
            // Cel wody
            Text(context.l10n.profWaterGoalMl, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _waterGoalController,
              decoration: InputDecoration(
                hintText: '2000',
                suffixText: 'ml',
                helperText: context.l10n.profWaterGoalHelper,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                setState(() => _waterGoalMl = parsed);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _waterGoalExplanationL10n(context, _currentWeightKg ?? profile.currentWeightKg),
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
                    : Text(
                        context.l10n.profSaveChanges,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  /// Po zmianie poziomu aktywności przelicz na bieżąco zapotrzebowanie, termin celu, kalorie i makra.
  void _onActivityLevelChanged() {
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
    if (_goal == AppConstants.goalMaintain) {
      _recalculateFromWeightsForMaintain();
    } else {
      if (_manualWeeklyWeightChange == null || _manualWeeklyWeightChange! <= 0) {
        _manualWeeklyWeightChange = _goal == AppConstants.goalWeightLoss
            ? AppConstants.defaultWeightLossRate
            : AppConstants.defaultWeightGainRate;
        _weeklyRateController.text = _manualWeeklyWeightChange!.toStringAsFixed(1);
      }
      _recalculateFromRate();
    }
  }

  /// Po zmianie wieku lub wzrostu (ręczne pole) przelicz BMR/TDEE i makra.
  void _triggerRecalcFromProfileFields() {
    if (_gender == null || _age == null || _heightCm == null || _activityLevel == null) return;
    if (_currentWeightKg == null || _targetWeightKg == null || _goal == null) return;
    if (_goal == AppConstants.goalMaintain) {
      _recalculateFromWeightsForMaintain();
    } else {
      if (_manualWeeklyWeightChange == null || _manualWeeklyWeightChange! <= 0) {
        _manualWeeklyWeightChange = _goal == AppConstants.goalWeightLoss
            ? AppConstants.defaultWeightLossRate
            : AppConstants.defaultWeightGainRate;
        _weeklyRateController.text = _manualWeeklyWeightChange!.toStringAsFixed(1);
      }
      _recalculateFromRate();
    }
  }

  Widget _buildActivityLevelOption(String title, String description, String value) {
    final isSelected = _activityLevel == value;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          setState(() => _activityLevel = value);
          _onActivityLevelChanged();
        },
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
        // Przy zmianie aktualnej wagi zaktualizuj sugerowany cel wody (jeśli użytkownik go nie edytował)
        if (_waterGoalMl == null || _waterGoalMl == _initialWaterGoalMl) {
          final suggested = Calculations.calculateDailyWaterGoalMl(_currentWeightKg!);
          _waterGoalMl = suggested;
          _waterGoalController.text = suggested.toStringAsFixed(0);
        }
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
            '${value.toStringAsFixed(1)} g',
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
              context.l10n.profMacroPerGram(kcal: kcalPerG),
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
    if (diff < -0.5) return context.l10n.profWantLose;
    if (diff > 0.5) return context.l10n.profWantGain;
    return context.l10n.onbGoalUnchangedSameWeight;
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
                  context.l10n.profAdjustPlan,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.profPlanPremiumOnly,
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
                label: Text(context.l10n.profSeePremium),
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
              context.l10n.profAdjustPlan,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  context.l10n.profWeightRate,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                if (!isMaintain)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.l10n.profRateKgWeek(rate: clampedRate.toStringAsFixed(1)),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  )
                else
                  Text(
                    context.l10n.profRateZero,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            if (!isMaintain) ...[
              const SizedBox(height: 4),
              Slider(
                value: clampedRate,
                min: minRate,
                max: maxRate,
                divisions: ((maxRate - minRate) / 0.1).round().clamp(1, 100),
                label: context.l10n.profRateKgWeek(rate: clampedRate.toStringAsFixed(1)),
                onChanged: (value) {
                  setState(() {
                    _manualWeeklyWeightChange = value;
                    _weeklyRateController.text = value.toStringAsFixed(1);
                    _customCaloriesController.clear();
                    _recalculateFromRate();
                  });
                },
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.profMaintainRateZero,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
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
                        context.l10n.profRecommendedRate,
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
                        Expanded(child: _buildMacroChip(context, context.l10n.profProtein, protein, Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMacroChip(context, context.l10n.profFat, fat, Colors.orange)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMacroChip(context, context.l10n.profCarbsShort, carbs, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isMaintain)
                      Text(
                        context.l10n.profEstTargetDate(date: dateStr),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      )
                    else
                      Text(
                        context.l10n.onbGoalUnchangedSameWeight,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                  ] else
                    Text(
                      context.l10n.profMoveSlider,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                context.l10n.profCustomCalorieGoal,
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
                          labelText: context.l10n.profGoalKcal,
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
                        context.l10n.profLeaveEmptyFromRate,
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
                context.l10n.profCustomMacros,
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
                              label: context.l10n.profProtein,
                              controller: _proteinController,
                              color: Colors.blue,
                              kcalPerG: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMacroInputCard(
                              context,
                              label: context.l10n.profFat,
                              controller: _fatController,
                              color: Colors.orange,
                              kcalPerG: 9,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMacroInputCard(
                              context,
                              label: context.l10n.profCarbsShort,
                              controller: _carbsController,
                              color: Colors.green,
                              kcalPerG: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.profMacrosAutoRecalc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (_macroPreviewKcal > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.profMacroSum(kcal: _macroPreviewKcal.toStringAsFixed(0)),
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
    _proteinController.text = (_manualProteinG ?? 0).toStringAsFixed(1);
    _fatController.text = (_manualFatG ?? 0).toStringAsFixed(1);
    _carbsController.text = (_manualCarbsG ?? 0).toStringAsFixed(1);
  }

  double? _parseMacro(String s) {
    if (s.trim().isEmpty) return 0.0;
    return double.tryParse(s.trim().replaceAll(',', '.'));
  }

  void _updateCaloriesFromMacros() {
    final protein = _parseMacro(_proteinController.text) ?? 0;
    final fat = _parseMacro(_fatController.text) ?? 0;
    final carbs = _parseMacro(_carbsController.text) ?? 0;
    if (protein < 0 || fat < 0 || carbs < 0) {
      setState(() => _macroWarning = context.l10n.profValuesNotNegative);
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
      if (protein > AppConstants.maxProteinG) parts.add(context.l10n.profMacroMaxProtein(g: AppConstants.maxProteinG.toStringAsFixed(0)));
      if (fat > AppConstants.maxFatG) parts.add(context.l10n.profMacroMaxFat(g: AppConstants.maxFatG.toStringAsFixed(0)));
      if (carbs > AppConstants.maxCarbsG) parts.add(context.l10n.profMacroMaxCarbs(g: AppConstants.maxCarbsG.toStringAsFixed(0)));
      macroWarning = context.l10n.profMacroOverLimit(parts: parts.join(', '));
    } else if (calories > AppConstants.maxCaloriesFromMacros) {
      macroWarning = context.l10n.profMacroCaloriesUnreal(
        calories: calories.toStringAsFixed(0),
        max: AppConstants.maxCaloriesFromMacros.toStringAsFixed(0),
      );
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
          _macroWarning = context.l10n.profMacroLossSurplus(
            surplus: (calories - tdee).toStringAsFixed(0),
            tdee: tdee.toStringAsFixed(0),
          );
          _calorieWarning = null;
        });
        return;
      }
    } else if (_goal! == AppConstants.goalWeightGain) {
      if (calories <= tdee) {
        setState(() {
          _macroWarning = context.l10n.profMacroGainDeficit(tdee: tdee.toStringAsFixed(0));
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
        warning = context.l10n.profWarnCalAboveTdeeLoss(tdee: tdee.toStringAsFixed(0));
      } else if (calorieDifference < -1500) {
        // Zbyt duży deficyt
        warning = context.l10n.profWarnDeficitHuge(deficit: (-calorieDifference).toStringAsFixed(0));
      } else if (calorieDifference < -100) {
        // OK - deficyt w rozsądnym zakresie
        warning = null;
      } else {
        // Za mały deficyt lub brak deficytu
        warning = context.l10n.profWarnDeficitTiny;
      }
    } else if (_goal! == AppConstants.goalWeightGain) {
      // Dla przybrania wagi: cel powinien być powyżej TDEE
      if (calorieDifference < 0) {
        // Deficyt kaloryczny przy przybieraniu - niemożliwe
        warning = context.l10n.profWarnCalBelowTdeeGain(tdee: tdee.toStringAsFixed(0));
      } else if (calorieDifference > 1000) {
        // Zbyt duża nadwyżka
        warning = context.l10n.profWarnSurplusHuge(surplus: calorieDifference.toStringAsFixed(0));
      } else if (calorieDifference > 100) {
        // OK - nadwyżka w rozsądnym zakresie
        warning = null;
      } else {
        // Za mała nadwyżka
        warning = context.l10n.profWarnSurplusTiny;
      }
    } else {
      // Utrzymanie wagi: cel powinien być blisko TDEE
      if (calorieDifference.abs() > 200) {
        warning = context.l10n.profWarnMaintainFar(tdee: tdee.toStringAsFixed(0));
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

    var proteinG = targetWeight * AppConstants.proteinPerKg;
    var proteinCalories = proteinG * 4;
    var fatCalories = calories * AppConstants.fatPercentage;
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
    final l10n = context.l10n;
    
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
              context.l10n.profCannotSaveLoss(
                calories: _manualTargetCalories!.toStringAsFixed(0),
                tdee: tdee.toStringAsFixed(0),
              ),
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
              context.l10n.profCannotSaveGain(
                calories: _manualTargetCalories!.toStringAsFixed(0),
                tdee: tdee.toStringAsFixed(0),
              ),
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
        throw Exception(context.l10n.profUserNotLoggedIn);
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
        
        // Przelicz datę — przy utrzymaniu wagi brak terminu
        if (_goal == AppConstants.goalMaintain) {
          targetDate = null;
          weeklyWeightChange = null;
        } else if (weeklyWeightChange != null && weeklyWeightChange > 0) {
          final weightDiff = (_targetWeightKg! - _currentWeightKg!).abs();
          if (weightDiff >= 0.5) {
            final weeksNeeded = (weightDiff / weeklyWeightChange).ceil();
            targetDate = DateTime.now().add(Duration(days: weeksNeeded * 7));
          } else {
            targetDate = null;
          }
        } else {
          targetDate = Calculations.calculateTargetDate(
            currentWeight: _currentWeightKg!,
            targetWeight: _targetWeightKg!,
            goal: _goal!,
          );
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
            reason: l10n.profGoalHistoryEdit,
          );
        }
      }

      if (!context.mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      
      ref.invalidate(profileProvider);
      // Odśwież również dashboard, aby pokazał zaktualizowany cel
      ref.invalidate(dashboardDataProvider);
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profUpdatedSuccess),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _isSaving = false;
      });
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profSaveError(error: '$e')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
