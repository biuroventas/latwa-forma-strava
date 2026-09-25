import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/calculations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/trial_constants.dart';
import '../../../core/auth/sign_out_guard.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/guest/guest_trial.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/supabase_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  
  // Dane użytkownika
  String? _gender;
  int? _age;
  double? _heightCm;
  double? _currentWeightKg;
  double? _targetWeightKg;
  String? _activityLevel;
  String? _goal;
  
  // Obliczone wartości
  double? _bmr;
  double? _tdee;
  Map<String, double>? _macros;
  DateTime? _targetDate;

  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _currentWeightController;
  late final TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    _age = 25;
    _heightCm = 170;
    _currentWeightKg = 70;
    _targetWeightKg = 70;
    _goal = AppConstants.goalMaintain;
    _ageController = TextEditingController(text: '25');
    _heightController = TextEditingController(text: '170');
    _currentWeightController = TextEditingController(text: '70');
    _targetWeightController = TextEditingController(text: '70');
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleBack(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.onbGoBackTitle),
          content: Text(l10n.onbGoBackBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonNo),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.onbGoBackConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      await SupabaseConfig.auth.signOut();
      await markSignOut();
    } catch (_) {}
    if (!context.mounted) return;
    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context),
                tooltip: l10n.onbBackTooltip,
              ),
              title: Text(l10n.onbCompleteData),
            ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (kIsWeb)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          l10n.onbCompleteData,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    // Płeć
              Text(
                l10n.onbGenderLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(l10n.onbGenderFemale, AppConstants.genderFemale),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildGenderOption(l10n.onbGenderMale, AppConstants.genderMale),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Wiek
              Text(
                l10n.onbAgeLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: (_age ?? 25).toDouble().clamp(13.0, 100.0),
                      min: 13,
                      max: 100,
                      divisions: 87,
                      label: (_age ?? 25).toString(),
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
                        suffixText: l10n.onbYearsUnit,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      ),
                      onSubmitted: (s) {
                        final v = int.tryParse(s.trim());
                        if (v != null && v >= 13 && v <= 100) {
                          setState(() {
                            _age = v;
                            _ageController.text = v.toString();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Wzrost
              Text(
                l10n.onbHeightLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: (_heightCm ?? 170).clamp(100.0, 250.0),
                      min: 100,
                      max: 250,
                      divisions: 150,
                      label: (_heightCm ?? 170).round().toString(),
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
                      onSubmitted: (s) {
                        final v = double.tryParse(s.trim().replaceAll(',', '.'));
                        if (v != null && v >= 100 && v <= 250) {
                          setState(() {
                            _heightCm = v.round().toDouble();
                            _heightController.text = v.round().toString();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Aktualna waga
              Text(
                l10n.onbCurrentWeightLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: (_currentWeightKg ?? 70).clamp(30.0, 300.0),
                      min: 30,
                      max: 300,
                      divisions: 270,
                      label: (_currentWeightKg ?? 70).toStringAsFixed(1),
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
                      onSubmitted: (s) {
                        final v = double.tryParse(s.trim().replaceAll(',', '.'));
                        if (v != null && v >= 30 && v <= 300) {
                          setState(() {
                            _currentWeightKg = v;
                            _targetWeightKg ??= v;
                            _currentWeightController.text = v.toStringAsFixed(1);
                            _updateGoalFromWeights();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Waga docelowa
              Text(
                l10n.onbTargetWeightLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (_currentWeightKg != null && _targetWeightKg != null)
                Text(
                  l10n.onbWeightDiff(
                    diff: (_targetWeightKg! - _currentWeightKg!).abs().toStringAsFixed(1),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: (_targetWeightKg ?? _currentWeightKg ?? 70).clamp(30.0, 300.0),
                      min: 30,
                      max: 300,
                      divisions: 270,
                      label: (_targetWeightKg ?? _currentWeightKg ?? 70).toStringAsFixed(1),
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
                      onSubmitted: (s) {
                        final v = double.tryParse(s.trim().replaceAll(',', '.'));
                        if (v != null && v >= 30 && v <= 300) {
                          setState(() {
                            _targetWeightKg = v;
                            _targetWeightController.text = v.toStringAsFixed(1);
                            _updateGoalFromWeights();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_currentWeightKg != null && _targetWeightKg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    (_targetWeightKg! - _currentWeightKg!).abs() < 0.5
                        ? l10n.onbGoalUnchangedSameWeight
                        : _getGoalDescriptionText(l10n),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.onbWeightDiffMin,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              const SizedBox(height: 6),
              
              // Poziom aktywności
              Text(
                l10n.onbActivityLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              _buildActivityLevelOption(l10n.onbActivitySedentary, l10n.onbActivitySedentaryDesc, AppConstants.activitySedentary),
              const SizedBox(height: 3),
              _buildActivityLevelOption(l10n.onbActivityLight, l10n.onbActivityLightDesc, AppConstants.activityLight),
              const SizedBox(height: 3),
              _buildActivityLevelOption(l10n.onbActivityModerate, l10n.onbActivityModerateDesc, AppConstants.activityModerate),
              const SizedBox(height: 3),
              _buildActivityLevelOption(l10n.onbActivityIntense, l10n.onbActivityIntenseDesc, AppConstants.activityIntense),
              const SizedBox(height: 3),
              _buildActivityLevelOption(l10n.onbActivityVeryIntense, l10n.onbActivityVeryIntenseDesc, AppConstants.activityVeryIntense),
              const SizedBox(height: 10),
              
              // Przycisk zapisz
              ElevatedButton(
                  onPressed: (_canProceed() && !_isSaving) ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                          l10n.onbSaveAndStart,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = _gender == value;
    return Card(
      elevation: isSelected ? 2 : 1,
      margin: EdgeInsets.zero,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(width: 3),
                Icon(Icons.check_circle, color: Colors.green, size: 14),
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
      elevation: isSelected ? 3 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => setState(() => _activityLevel = value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
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
    }
  }

  String _getGoalDescriptionText(AppLocalizations l10n) {
    if (_currentWeightKg == null || _targetWeightKg == null) return '';
    final diff = _targetWeightKg! - _currentWeightKg!;
    if (diff < -0.5) return l10n.onbGoalLose;
    if (diff > 0.5) return l10n.onbGoalGain;
    return l10n.onbGoalMaintain;
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
    return true;
  }

  bool _canCalculate() {
    return _gender != null &&
        _age != null &&
        _heightCm != null &&
        _currentWeightKg != null &&
        _activityLevel != null &&
        _goal != null &&
        _targetWeightKg != null;
  }

  void _calculateValues() {
    if (_canCalculate()) {
      _bmr = Calculations.calculateBMR(
        gender: _gender!,
        weightKg: _currentWeightKg!,
        heightCm: _heightCm!,
        age: _age!,
      );

      _tdee = Calculations.calculateTDEE(
        bmr: _bmr!,
        activityLevel: _activityLevel!,
      );

      _macros = Calculations.calculateMacros(
        tdee: _tdee!,
        goal: _goal!,
        targetWeightKg: _targetWeightKg!,
      );

      _targetDate = Calculations.calculateTargetDate(
        currentWeight: _currentWeightKg!,
        targetWeight: _targetWeightKg!,
        goal: _goal!,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_canProceed() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      _calculateValues();

      debugPrint('🔄 Rozpoczynam zapisywanie profilu...');

      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('👤 Tworzenie anonimowego konta...');
        debugPrint('🔍 Sprawdzam konfigurację Supabase...');
        debugPrint('   Auth session: ${SupabaseConfig.auth.currentSession}');
        
        try {
          final response = await SupabaseConfig.auth.signInAnonymously();
          debugPrint('📥 Odpowiedź z Supabase: ${response.user?.id}');
          
          if (response.user == null) {
            debugPrint('❌ Brak użytkownika w odpowiedzi');
            debugPrint('   Session: ${response.session}');
            debugPrint('   Error: ${response.user}');
            throw Exception('Nie udało się utworzyć konta - brak użytkownika w odpowiedzi');
          }
          
          debugPrint('✅ Konto utworzone pomyślnie!');
          debugPrint('   User ID: ${response.user?.id}');
          debugPrint('   Email: ${response.user?.email}');
          debugPrint('   Created at: ${response.user?.createdAt}');
          // Rozpocznij 24h trial od razu, żeby dashboard odblokował funkcje premium
          try {
            final prefs = await SharedPreferences.getInstance();
            final key = '$trialStartPrefKeyPrefix${response.user!.id}';
            await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
          } catch (_) {}
        } catch (authError, stackTrace) {
          debugPrint('❌ Błąd autoryzacji: $authError');
          debugPrint('📚 Stack trace: $stackTrace');
          
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            
            final l10n = context.l10n;
            String errorMsg = l10n.onbErrorCreatingAccount;
            String errorDetails = authError.toString();
            
            if (errorDetails.contains('Operation not permitted') ||
                errorDetails.contains('errno = 1') ||
                errorDetails.contains('SocketException')) {
              errorMsg = l10n.onbErrorNetworkPermission;
            } else if (errorDetails.contains('anonymous') || 
                errorDetails.contains('disabled') ||
                errorDetails.contains('not enabled')) {
              errorMsg = l10n.onbErrorAnonymousDisabled;
            } else if (errorDetails.contains('network') || 
                       errorDetails.contains('connection') ||
                       errorDetails.contains('timeout')) {
              errorMsg = l10n.onbErrorInternet;
            } else if (errorDetails.contains('invalid') || 
                       errorDetails.contains('unauthorized')) {
              errorMsg = l10n.onbErrorSupabaseConfig;
            } else {
              errorMsg = l10n.onbErrorWithDetails(details: errorDetails);
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: l10n.commonRetry,
                  onPressed: () => _saveProfile(),
                ),
              ),
            );
          }
          return;
        }
      } else {
        debugPrint('✅ Użytkownik już zalogowany: $userId');
      }

      final finalUserId = SupabaseConfig.auth.currentUser!.id;
      debugPrint('👤 User ID: $finalUserId');

      final waterGoalMl = Calculations.calculateDailyWaterGoalMl(_currentWeightKg!);
      final profile = UserProfile(
        userId: finalUserId,
        gender: _gender!,
        age: _age!,
        heightCm: _heightCm!,
        currentWeightKg: _currentWeightKg!,
        targetWeightKg: _targetWeightKg!,
        activityLevel: _activityLevel!,
        goal: _goal!,
        bmr: _bmr,
        tdee: _tdee,
        targetCalories: _macros?['calories'],
        targetProteinG: _macros?['protein'],
        targetFatG: _macros?['fat'],
        targetCarbsG: _macros?['carbs'],
        targetDate: _targetDate,
        waterGoalMl: waterGoalMl,
      );

      debugPrint('💾 Zapisuję profil do bazy danych...');
      final service = SupabaseService();
      await service.createProfile(profile);
      debugPrint('✅ Profil zapisany pomyślnie!');
      final savedUser = SupabaseConfig.auth.currentUser;
      if (savedUser != null && savedUser.isAnonymous) {
        await GuestTrial.startIfNeeded();
      }

      if (mounted) {
        context.go(AppRoutes.planLoading, extra: {
          'targetCalories': _macros?['calories'],
          'targetDate': _targetDate,
          'goal': _goal,
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Błąd podczas zapisywania profilu: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        final l10n = context.l10n;
        String errorMessage = l10n.onbErrorSaving;
        if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = l10n.onbErrorInternetShort;
        } else if (e.toString().contains('auth') || e.toString().contains('permission')) {
          errorMessage = l10n.onbErrorAuth;
        } else {
          errorMessage = l10n.onbErrorWithDetails(details: '$e');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: l10n.commonRetry,
              onPressed: () => _saveProfile(),
            ),
          ),
        );
      }
    }
  }
}
