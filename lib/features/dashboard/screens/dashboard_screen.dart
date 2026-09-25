import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/meal.dart';
import '../../../shared/models/activity.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/providers/main_tab_provider.dart';
import '../../../core/utils/calculations.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/streak_updater.dart';
import '../../../core/utils/success_message.dart';
import '../../statistics/goal_verification.dart';
import '../../../shared/data/meal_ideas.dart';
import '../../../shared/models/water_log.dart';
import '../../../shared/services/meal_copy_helper.dart';
import '../../../shared/services/product_service.dart';
import '../../../shared/widgets/save_progress_checker.dart';
import '../../../shared/widgets/premium_gate.dart';

final dashboardDataProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, DateTime>((ref, selectedDate) async {
  // Na webie po odświeżeniu strony sesja bywa nieaktualna – odśwież przed pierwszym requestem (unikamy Failed to fetch).
  if (kIsWeb) {
    try {
      await SupabaseConfig.auth.refreshSession();
    } catch (_) {}
  }

  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  final date = dayKey(selectedDate);

  final profile = await service.getProfile(userId);
  final meals = await service.getMeals(userId, date: date);
  final activities = await service.getActivities(userId, date: date);
  final totalWater = await service.getTotalWaterForDate(userId, date);
  final totalMealsCount = await service.getMealsCount(userId);
  final recentMeals = await service.getRecentDistinctMeals(userId, limit: 6);
  final weightToday = await service.getWeightLogsInRange(
    userId,
    startDate: date,
    endDate: date,
  );

  double totalCalories = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double totalCarbs = 0;
  double totalSaturatedFat = 0;
  double totalSugar = 0;
  double totalFiber = 0;
  double totalSalt = 0;
  double totalBurned = 0;

  for (var meal in meals) {
    totalCalories += meal.calories;
    totalProtein += meal.proteinG;
    totalFat += meal.fatG;
    totalCarbs += meal.carbsG;
    totalSaturatedFat += meal.saturatedFatG;
    totalSugar += meal.sugarG;
    totalFiber += meal.fiberG;
    totalSalt += meal.saltG;
  }

  for (var activity in activities) {
    if (!activity.excludedFromBalance) totalBurned += activity.caloriesBurned;
  }

  return {
    'profile': profile,
    'meals': meals,
    'activities': activities,
    'totalWater': totalWater,
    'totalCalories': totalCalories,
    'totalProtein': totalProtein,
    'totalFat': totalFat,
    'totalCarbs': totalCarbs,
    'totalSaturatedFat': totalSaturatedFat,
    'totalSugar': totalSugar,
    'totalFiber': totalFiber,
    'totalSalt': totalSalt,
    'totalBurned': totalBurned,
    'totalMealsCount': totalMealsCount,
    'recentMeals': recentMeals,
    'hasWeightToday': weightToday.isNotEmpty,
    'selectedDate': date,
  };
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showMacros = false;
  bool _applyingGoal = false;
  DateTime _selectedDate = dayKey(DateTime.now());
  /// 0 = ostatni tydzień (do dziś), -1 = wstecz o tydzień, -2 = jeszcze wstecz itd.
  int _weekOffset = 0;
  final _caloriesCardKey = GlobalKey();
  final _quickSearchController = TextEditingController();
  final _productService = ProductService();
  List<Map<String, dynamic>> _quickSearchProducts = [];
  bool _quickSearchLoading = false;
  /// Lista wyników jest schowana, ale tekst w polu zostaje.
  bool _quickSearchOpen = false;
  Timer? _quickSearchDebounce;
  static const _prefShowMacros = 'show_macros';
  static const _prefD1ChecklistDone = 'd1_checklist_done';
  static const _prefCalorieSuccessPrefix = 'calorie_goal_success_';
  bool _d1ChecklistDone = false;
  bool _showCalorieSuccess = false;
  bool _isCopyingMeals = false;
  bool _addingMealFromRecent = false;

  @override
  void initState() {
    super.initState();
    _loadShowMacros();
    _loadDashboardPrefs();
    _quickSearchController.addListener(_onQuickSearchChanged);
    // Rozpocznij okres próbny przy pierwszym wejściu (zapis pierwszego użycia)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firstUseAtProvider.future);
    });
  }

  Future<void> _loadDashboardPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = dayKey(DateTime.now());
    final successKey = '$_prefCalorieSuccessPrefix${today.year}_${today.month}_${today.day}';
    if (mounted) {
      setState(() {
        _d1ChecklistDone = prefs.getBool(_prefD1ChecklistDone) ?? false;
        _showCalorieSuccess = prefs.getBool(successKey) ?? false;
      });
    }
  }

  Future<void> _markD1ChecklistDone() async {
    if (_d1ChecklistDone) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefD1ChecklistDone, true);
    if (mounted) setState(() => _d1ChecklistDone = true);
  }

  Future<void> _markCalorieSuccessShown() async {
    if (_showCalorieSuccess) return;
    final today = dayKey(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    final successKey = '$_prefCalorieSuccessPrefix${today.year}_${today.month}_${today.day}';
    await prefs.setBool(successKey, true);
    if (mounted) setState(() => _showCalorieSuccess = true);
  }

  bool _isTodaySelected() {
    final today = dayKey(DateTime.now());
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  Future<void> _loadShowMacros() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showMacros = prefs.getBool(_prefShowMacros) ?? true;
    });
  }

  Future<void> _saveShowMacros(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowMacros, value);
  }

  @override
  void dispose() {
    _quickSearchDebounce?.cancel();
    _quickSearchController.removeListener(_onQuickSearchChanged);
    _quickSearchController.dispose();
    super.dispose();
  }

  void _dismissQuickSearch() {
    _quickSearchDebounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _quickSearchOpen = false;
      _quickSearchProducts = [];
      _quickSearchLoading = false;
    });
  }

  void _reopenQuickSearch() {
    final query = _quickSearchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _quickSearchOpen = true);
    _runQuickSearch(query);
  }

  void _onQuickSearchChanged() {
    _quickSearchDebounce?.cancel();
    final query = _quickSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _quickSearchOpen = false;
        _quickSearchProducts = [];
        _quickSearchLoading = false;
      });
      return;
    }
    setState(() => _quickSearchOpen = true);
    _quickSearchDebounce = Timer(const Duration(milliseconds: 300), () => _runQuickSearch(query));
  }

  Future<void> _runQuickSearch(String query) async {
    setState(() => _quickSearchLoading = true);
    try {
      final results = await _productService.searchProducts(query, pageSize: 15);
      if (mounted && _quickSearchController.text.trim() == query) {
        setState(() {
          _quickSearchProducts = results;
          _quickSearchLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _quickSearchProducts = [];
          _quickSearchLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Przy powrocie na zakładkę Dziś — świeże dane (np. po kopiowaniu w Posiłkach).
    ref.listen<int>(mainTabVisitProvider(0), (prev, next) {
      if (prev != next) ref.invalidate(dashboardDataProvider(_selectedDate));
    });

    final dashboardData = ref.watch(dashboardDataProvider(_selectedDate));
    final isPremium = ref.watch(hasPremiumAccessProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 28,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.push(AppRoutes.premium),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.appTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          label: Text(
                            context.l10n.trackPremiumLabel,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          onPressed: () => context.push(AppRoutes.premium),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Semantics(
            label: context.l10n.trackStatistics,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: context.l10n.trackStatistics,
              onPressed: () => context.push(AppRoutes.statistics),
            ),
          ),
          Semantics(
            label: context.l10n.trackGoalsAndChallenges,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.emoji_events),
              tooltip: context.l10n.trackGoalsAndChallenges,
              onPressed: () => context.push(AppRoutes.challenges),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          dashboardData.when(
        data: (data) => SaveProgressChecker(
          totalMealsCount: data['totalMealsCount'] as int? ?? 0,
          onInvalidate: () => ref.invalidate(dashboardDataProvider(_selectedDate)),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardDataProvider(_selectedDate));
            },
            child: _buildDashboard(context, ref, data, isPremium),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          final errStr = error.toString();
          final isLoggedOut = errStr.contains('User not logged in');
          final isFailedFetch = errStr.contains('Failed to fetch') || errStr.contains('ClientException');
          final l10n = context.l10n;
          final message = isLoggedOut
              ? l10n.trackSessionExpired
              : isFailedFetch
                  ? l10n.trackLoadDataFailed
                  : l10n.trackErrorWithDetails(error: '$error');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (isLoggedOut) {
                        context.go(AppRoutes.welcome);
                      } else {
                        ref.invalidate(dashboardDataProvider(_selectedDate));
                      }
                    },
                    child: Text(isLoggedOut ? context.l10n.trackSignIn : context.l10n.commonRetry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
          if (_quickSearchOpen && _quickSearchController.text.trim().isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissQuickSearch,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildPinnedProductSearch(context, ref),
    );
  }

  Future<void> _shareCaloriesScreenshot() async {
    final boundary = _caloriesCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final shareText = context.l10n.trackShareCaloriesText(
      date: '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
    );
    final shareErrorL10n = context.l10n;

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        completer.complete();
        return;
      }
      try {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!mounted) {
          completer.complete();
          return;
        }
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          completer.complete();
          return;
        }

        final bytes = byteData.buffer.asUint8List();
        if (kIsWeb) {
          final xFile = XFile.fromData(bytes, name: 'kalorie_${_selectedDate.day}_${_selectedDate.month}.png');
          await Share.shareXFiles([xFile], text: shareText);
        } else {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/kalorie_${_selectedDate.day}_${_selectedDate.month}.png');
          await file.writeAsBytes(bytes);
          final box = boundary as RenderBox;
          final shareRect = box.localToGlobal(Offset.zero) & box.size;
          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            sharePositionOrigin: shareRect,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(shareErrorL10n.trackShareError(error: '$e'))),
          );
        }
      } finally {
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }

  Widget _buildGoalVerificationChip(BuildContext context, WidgetRef ref) {
    final verification = ref.watch(goalVerificationProvider);
    return verification.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) {
        final l10n = context.l10n;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: Icon(
                Icons.insights_outlined,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              label: Text(l10n.trackGoalVerificationDays(days: result.daysWithData)),
              onPressed: () => context.push(AppRoutes.statistics),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalCorrectionCard(BuildContext context, WidgetRef ref) {
    final verification = ref.watch(goalVerificationProvider);
    return verification.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) {
        final suggestion = result.suggestionText;
        final corrected = result.correctedTargetCalories;
        if (suggestion == null || corrected == null || result.profile == null) {
          return const SizedBox.shrink();
        }
        final l10n = context.l10n;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.moreBasedOnLast7Days,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(suggestion),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _applyingGoal ? null : () => _applyGoalCorrection(result),
                    child: Text(_applyingGoal ? l10n.moreSaving : l10n.moreApplyCorrectedGoal),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyGoalCorrection(GoalVerificationResult result) async {
    final profile = result.profile;
    final corrected = result.correctedTargetCalories;
    if (profile == null || corrected == null) return;
    final l10n = context.l10n;
    setState(() => _applyingGoal = true);
    try {
      final macros = Calculations.calculateMacrosFromCalories(
        targetCalories: corrected,
        targetWeightKg: profile.targetWeightKg,
      );
      final updated = profile.copyWith(
        targetCalories: corrected,
        targetProteinG: macros['protein'],
        targetFatG: macros['fat'],
        targetCarbsG: macros['carbs'],
      );
      final service = SupabaseService();
      await service.updateProfile(updated);
      try {
        await service.saveGoalHistory(
          userId: profile.userId,
          oldTargetCalories: result.currentTargetCalories,
          newTargetCalories: corrected,
          reason: l10n.moreGoalHistoryReason,
        );
      } catch (_) {}
      ref.invalidate(goalVerificationProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(dashboardDataProvider(_selectedDate));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.moreGoalUpdated(calories: corrected.toStringAsFixed(0)))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.trackShareError(error: '$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _applyingGoal = false);
    }
  }

  Widget _buildMealIdeasCard(BuildContext context, WidgetRef ref, double remaining) {
    final limit = remaining < 400 ? 2 : 3;
    final ideas = MealIdea.forRemaining(remaining, limit: limit);
    if (ideas.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trackMealIdeasTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.trackMealIdeasLeft(kcal: remaining.clamp(0, 9999).toStringAsFixed(0))),
              const SizedBox(height: 8),
              for (final idea in ideas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(idea.name(language)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${idea.kcal.toStringAsFixed(0)} kcal'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: l10n.trackAdd,
                        onPressed: () => _quickAddMealIdea(context, ref, idea, language),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final logged = await context.push<bool>(
                      AppRoutes.barcodeProduct,
                      extra: mealFlowExtra(
                        product: idea.toProduct(language),
                        date: _selectedDate,
                      ),
                    );
                    if (logged == true && mounted) {
                      ref.invalidate(dashboardDataProvider(_selectedDate));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickAddMealIdea(
    BuildContext context,
    WidgetRef ref,
    MealIdea idea,
    String language,
  ) async {
    final l10n = context.l10n;
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;
      final createdAt = MealCopyHelper.createdAtForSelectedDay(_selectedDate);
      final service = SupabaseService();
      await service.createMeal(Meal(
        userId: userId,
        name: idea.name(language),
        calories: idea.kcal,
        proteinG: idea.protein,
        fatG: idea.fat,
        carbsG: idea.carbs,
        weightG: idea.grams,
        mealType: MealCopyHelper.inferMealTypeFromHour(createdAt),
        source: 'idea',
        createdAt: createdAt,
      ));
      await StreakUpdater.updateStreak(userId, AppConstants.streakMeals, _selectedDate);
      ref.invalidate(dashboardDataProvider(_selectedDate));
      if (!context.mounted) return;
      SuccessMessage.show(context, l10n.trackMealAddedSuccess, l10n: l10n);
    } catch (e) {
      if (!context.mounted) return;
      ErrorHandler.showSnackBar(context, l10n: l10n, error: e);
    }
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, Map<String, dynamic> data, bool isPremium) {
    final profile = data['profile'] as UserProfile?;
    final meals = data['meals'] as List<Meal>;
    final activities = data['activities'] as List<Activity>;
    final totalWater = data['totalWater'] as double;
    final totalCalories = data['totalCalories'] as double;
    final totalProtein = data['totalProtein'] as double;
    final totalFat = data['totalFat'] as double;
    final totalCarbs = data['totalCarbs'] as double;
    final totalSaturatedFat = data['totalSaturatedFat'] as double;
    final totalSugar = data['totalSugar'] as double;
    final totalFiber = data['totalFiber'] as double;
    final totalSalt = data['totalSalt'] as double;
    final totalBurned = data['totalBurned'] as double;

    final targetCalories = profile?.targetCalories ?? 2000.0;
    final targetProtein = profile?.targetProteinG ?? 150.0;
    final targetFat = profile?.targetFatG ?? 65.0;
    final targetCarbs = (profile?.targetCarbsG ?? 200.0).clamp(0.0, double.infinity);
    final waterGoal = profile?.waterGoalMl ?? AppConstants.defaultWaterGoal;
    final recentMeals = data['recentMeals'] as List<Meal>? ?? [];
    final hasWeightToday = data['hasWeightToday'] as bool? ?? false;
    final remainingKcal = targetCalories - totalCalories + totalBurned;

    if (_isTodaySelected() && !_d1ChecklistDone) {
      if (meals.isNotEmpty && totalWater > 0 && hasWeightToday) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _markD1ChecklistDone());
      }
    }

    if (_isTodaySelected() && targetCalories > 0) {
      final pct = totalCalories / targetCalories * 100;
      if (pct >= 100 && pct <= 110 && !_showCalorieSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _markCalorieSuccessShown());
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Przegląd kalorii (kalendarz tygodniowy + podsumowanie kalorii w jednej sekcji)
          _buildCaloriesOverviewCard(
            context,
            ref,
            isPremium,
            totalCalories,
            targetCalories,
            totalBurned,
            totalProtein,
            targetProtein,
            totalFat,
            targetFat,
            totalCarbs,
            targetCarbs,
            totalSaturatedFat,
            totalSugar,
            totalFiber,
            totalSalt,
          ),
          const SizedBox(height: 16),
          _buildGoalVerificationChip(context, ref),
          _buildGoalCorrectionCard(context, ref),
          if (_isTodaySelected() && !_d1ChecklistDone)
            _buildDay1ChecklistCard(
              context,
              ref,
              meals.isNotEmpty,
              totalWater > 0,
              hasWeightToday,
            ),
          if (meals.isEmpty)
            _buildEmptyDayCard(context, ref),
          _buildMealIdeasCard(context, ref, remainingKcal),
          if (recentMeals.isNotEmpty)
            _buildRecentFoodsCard(context, ref, recentMeals),
          // Woda
          _buildWaterCard(context, ref, totalWater, waterGoal),
          const SizedBox(height: 16),
          // Aktywności
          if (activities.isNotEmpty) ...[
            _buildActivitiesCard(context, ref, activities),
            const SizedBox(height: 16),
          ],
          // Posiłki
          if (meals.isNotEmpty) ...[
            _buildMealsCard(context, ref, meals),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesOverviewCard(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    double consumed,
    double target,
    double burned,
    double protein,
    double targetProtein,
    double fat,
    double targetFat,
    double carbs,
    double targetCarbs,
    double saturatedFat,
    double sugar,
    double fiber,
    double salt,
  ) {
    final remaining = target - consumed + burned;
    final percentage = target > 0 ? (consumed / target * 100).clamp(0.0, 999.0) : 0.0;
    final progressValue = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final today = DateTime.now();
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final dayCount = isNarrow ? 5 : 10;
    final baseDate = today.subtract(Duration(days: (dayCount - 1) - _weekOffset * dayCount));
    final weekDays = List.generate(dayCount, (index) => baseDate.add(Duration(days: index)));
    final canGoRight = _weekOffset < 0;

    return RepaintBoundary(
      key: _caloriesCardKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.trackCaloriesOverview,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.calendar_month),
                        iconSize: 22,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        tooltip: context.l10n.trackSelectDate,
                        onPressed: () async {
                          final dayCountForPicker = MediaQuery.sizeOf(context).width < 600 ? 5 : 10;
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: today.add(const Duration(days: 365)),
                          );
                          if (picked == null || !mounted) return;
                          setState(() {
                            _selectedDate = dayKey(picked);
                            final daysDiff = picked.difference(today).inDays;
                            _weekOffset = daysDiff >= 0
                                ? (daysDiff + dayCountForPicker - 1) ~/ dayCountForPicker
                                : daysDiff ~/ dayCountForPicker;
                          });
                          ref.invalidate(dashboardDataProvider(_selectedDate));
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPremium) ...[
                        Text(
                          context.l10n.trackMacros,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Checkbox(
                          value: _showMacros,
                          onChanged: (value) {
                            final v = value ?? false;
                            setState(() => _showMacros = v);
                            _saveShowMacros(v);
                          },
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: context.l10n.trackShare,
                        onPressed: () async {
                          final canProceed = await checkPremiumOrNavigate(context, ref, featureName: context.l10n.trackFeatureShareSummary);
                          if (canProceed && context.mounted) _shareCaloriesScreenshot();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _weekOffset -= 1;
                      });
                    },
                    tooltip: context.l10n.trackEarlierWeek,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekDays.map((date) {
                        final isSelected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        final isToday = date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day;

                        return GestureDetector(
                          onTap: () async {
                            if (isToday) {
                              setState(() => _selectedDate = dayKey(date));
                              ref.invalidate(dashboardDataProvider(_selectedDate));
                              return;
                            }
                            if (!isPremium) {
                              final canProceed = await checkPremiumOrNavigate(
                                context,
                                ref,
                                featureName: context.l10n.trackFeatureBrowseHistory,
                              );
                              if (!canProceed || !mounted) return;
                            }
                            setState(() => _selectedDate = dayKey(date));
                            ref.invalidate(dashboardDataProvider(_selectedDate));
                          },
                          child: Container(
                            width: 40,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : isToday
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getDayName(date.weekday),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: canGoRight
                        ? () {
                            setState(() {
                              _weekOffset += 1;
                            });
                          }
                        : null,
                    tooltip: context.l10n.trackLaterWeek,
                  ),
                ],
              ),
              if (_selectedDate.year != today.year ||
                  _selectedDate.month != today.month ||
                  _selectedDate.day != today.day)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.trackShowingDataFrom(date: '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = dayKey(DateTime.now());
                            _weekOffset = 0;
                          });
                          ref.invalidate(dashboardDataProvider(_selectedDate));
                        },
                        child: Text(context.l10n.trackDashToday),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      remaining < 0
                          ? context.l10n.trackOverGoalLabel
                          : context.l10n.trackRemainingKcal,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining.abs().toStringAsFixed(0),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: remaining < 0
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                          ),
                    ),
                    Text(
                      'kcal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: remaining < 0
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining < 0 ? AppTheme.warningColor : AppTheme.primaryColor,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              if (target > 0 && consumed > target)
                Text(
                  context.l10n.trackSurplusKcal(kcal: (consumed - target).toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                )
              else
                Text(
                  context.l10n.trackPercentOfGoal(percent: percentage.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (_isTodaySelected() &&
                  _showCalorieSuccess &&
                  percentage >= 100 &&
                  percentage <= 110) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.trackCalorieGoalSuccess,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompactCalorieStat(context, context.l10n.trackConsumed, consumed.toStringAsFixed(0)),
                  _buildCompactCalorieStat(context, context.l10n.trackBurned, burned.toStringAsFixed(0)),
                ],
              ),
              if (isPremium && _showMacros) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  context.l10n.trackMacros,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildMacroRow(context, context.l10n.trackProtein, protein, targetProtein, Colors.blue),
                const SizedBox(height: 12),
                _buildMacroRowWithSub(context, context.l10n.trackFat, fat, targetFat, Colors.orange, context.l10n.trackIncludingSaturated, saturatedFat),
                const SizedBox(height: 12),
                _buildMacroRowWithSub(context, context.l10n.trackCarbs, carbs, targetCarbs, Colors.green, context.l10n.trackIncludingSugars, sugar, subLabel2: context.l10n.trackFiber, subValue2: fiber),
                const SizedBox(height: 12),
                _buildMacroRow(context, context.l10n.trackSalt, salt, 0, Colors.grey, showTarget: false),
              ],
              if (!isPremium) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.premium),
                  icon: const Icon(Icons.pie_chart_outline, size: 18),
                  label: Text(context.l10n.trackMacrosInPremium),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedProductSearch(BuildContext context, WidgetRef ref) {
    final hasQuery = _quickSearchOpen && _quickSearchController.text.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF1B2B1C) : const Color(0xFFE8F5E9);
    final fieldColor = isDark ? const Color(0xFF243628) : Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: barColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.45 : 0.22),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.0 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasQuery) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: _buildQuickSearchResults(context, ref),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.4 : 0.28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quickSearchController,
                                onTap: _reopenQuickSearch,
                                style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  hintText: context.l10n.trackSearchProductEllipsis,
                                  hintStyle: TextStyle(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  isDense: true,
                                ),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) async {
                                  final query = value.trim();
                                  if (query.isEmpty) return;
                                  final result = await context.push<bool>(
                                    AppRoutes.productSearch,
                                    extra: mealFlowExtra(query: query, date: _selectedDate),
                                  );
                                  if (!context.mounted) return;
                                  if (result == true) ref.invalidate(dashboardDataProvider(_selectedDate));
                                },
                              ),
                            ),
                            IconButton.filled(
                              onPressed: () async {
                                final result = await context.push<bool>(
                                  AppRoutes.barcodeScanner,
                                  extra: _selectedDate,
                                );
                                if (context.mounted && result == true) {
                                  ref.invalidate(dashboardDataProvider(_selectedDate));
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                overlayColor: Colors.black26,
                              ),
                              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                              tooltip: context.l10n.trackScanBarcode,
                            ),
                            const SizedBox(width: 4),
                            IconButton.filled(
                              onPressed: () async {
                                final canProceed = await checkPremiumOrNavigate(
                                  context,
                                  ref,
                                  featureName: context.l10n.trackFeatureAiMealAnalysis,
                                );
                                if (!canProceed || !context.mounted) return;
                                final result = await context.push<bool>(
                                  AppRoutes.aiPhoto,
                                  extra: _selectedDate,
                                );
                                if (context.mounted && result == true) {
                                  ref.invalidate(dashboardDataProvider(_selectedDate));
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                overlayColor: Colors.black26,
                              ),
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              tooltip: context.l10n.trackAiPhotoAnalysisTooltip,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSearchResults(BuildContext context, WidgetRef ref) {
    if (_quickSearchLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (_quickSearchProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          context.l10n.trackNoResults,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _quickSearchProducts.length,
        itemBuilder: (context, index) {
          final p = _quickSearchProducts[index];
          final name = p['name'] as String? ?? context.l10n.trackProduct;
          final brand = p['brand'] as String?;
          final cal = (p['calories'] as num?)?.toDouble();
          return ListTile(
            dense: true,
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: brand != null && brand.isNotEmpty
                ? Text('$brand${cal != null && cal > 0 ? ' · ${cal.toStringAsFixed(0)} kcal/100g' : ''}', maxLines: 1, overflow: TextOverflow.ellipsis)
                : (cal != null && cal > 0 ? Text('${cal.toStringAsFixed(0)} kcal/100g', maxLines: 1) : null),
            onTap: () async {
              _quickSearchController.clear();
              setState(() => _quickSearchProducts = []);
              final result = await context.push<bool>(
                AppRoutes.barcodeProduct,
                extra: mealFlowExtra(product: p, date: _selectedDate),
              );
              if (!context.mounted) return;
              if (result == true) ref.invalidate(dashboardDataProvider(_selectedDate));
            },
          );
        },
      ),
    );
  }

  Widget _buildCompactCalorieStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildEmptyDayCard(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.trackAddFirstMealTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                l10n.trackAddFirstMealSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final result = await context.push<bool>(AppRoutes.mealsAdd, extra: _selectedDate);
                  if (result == true && mounted) {
                    ref.invalidate(dashboardDataProvider(_selectedDate));
                  }
                },
                icon: const Icon(Icons.restaurant),
                label: Text(l10n.trackAddFirstMealCta),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await context.push<bool>(
                          AppRoutes.productSearch,
                          extra: mealFlowExtra(date: _selectedDate),
                        );
                        if (result == true && mounted) {
                          ref.invalidate(dashboardDataProvider(_selectedDate));
                        }
                      },
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(l10n.trackSearchShort),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await context.push<bool>(
                          AppRoutes.barcodeScanner,
                          extra: _selectedDate,
                        );
                        if (result == true && mounted) {
                          ref.invalidate(dashboardDataProvider(_selectedDate));
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: Text(l10n.trackScanBarcode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.meals),
                icon: const Icon(Icons.history, size: 18),
                label: Text(l10n.trackShortcutRecent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoodsCard(BuildContext context, WidgetRef ref, List<Meal> recentMeals) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.trackRecentFoods, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final meal in recentMeals.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(meal.name),
                  subtitle: Text('${meal.calories.toStringAsFixed(0)} kcal'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: l10n.trackAdd,
                    onPressed: _addingMealFromRecent
                        ? null
                        : () => _quickAddFromRecent(context, ref, meal),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isCopyingMeals
                    ? null
                    : () => _copyYesterdayFromDashboard(context, ref),
                icon: _isCopyingMeals
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.copy_rounded),
                label: Text(_isCopyingMeals ? l10n.trackCopying : l10n.trackCopyYesterday),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickAddFromRecent(BuildContext context, WidgetRef ref, Meal meal) async {
    final l10n = context.l10n;
    setState(() => _addingMealFromRecent = true);
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;
      await MealCopyHelper.quickCreateFromMeal(
        userId: userId,
        template: meal,
        selectedDay: _selectedDate,
      );
      ref.invalidate(dashboardDataProvider(_selectedDate));
      if (!context.mounted) return;
      SuccessMessage.show(context, l10n.trackMealAddedSuccess, l10n: l10n);
    } catch (e) {
      if (!context.mounted) return;
      ErrorHandler.showSnackBar(context, l10n: l10n, error: e);
    } finally {
      if (mounted) setState(() => _addingMealFromRecent = false);
    }
  }

  Future<void> _copyYesterdayFromDashboard(BuildContext context, WidgetRef ref) async {
    if (_isCopyingMeals) return;
    final l10n = context.l10n;
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _isCopyingMeals = true);
    try {
      final copied = await MealCopyHelper.copyMealsFromDay(
        context: context,
        l10n: l10n,
        userId: userId,
        sourceDay: _selectedDate.subtract(const Duration(days: 1)),
        targetDay: _selectedDate,
      );
      if (!context.mounted || copied == null) return;
      ref.invalidate(dashboardDataProvider(_selectedDate));
      SuccessMessage.show(context, l10n.trackCopiedMealsCount(count: copied), l10n: l10n);
    } catch (e) {
      if (!context.mounted) return;
      ErrorHandler.showSnackBar(context, l10n: l10n, error: e);
    } finally {
      if (mounted) setState(() => _isCopyingMeals = false);
    }
  }

  Widget _buildDay1ChecklistCard(
    BuildContext context,
    WidgetRef ref,
    bool mealDone,
    bool waterDone,
    bool weightDone,
  ) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.trackD1ChecklistTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _checklistRow(context, l10n.trackD1ChecklistMeal, mealDone),
              _checklistRow(context, l10n.trackD1ChecklistWater, waterDone),
              _checklistRow(context, l10n.trackD1ChecklistWeight, weightDone),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _markD1ChecklistDone,
                  child: Text(l10n.trackD1ChecklistDismiss),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checklistRow(BuildContext context, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppTheme.primaryColor : Theme.of(context).colorScheme.outline,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Future<void> _addWaterFromDashboard(WidgetRef ref, double amountMl) async {
    if (!_isTodaySelected()) return;
    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) return;
      final service = SupabaseService();
      await service.createWaterLog(WaterLog(
        userId: userId,
        amountMl: amountMl,
        createdAt: DateTime.now(),
      ));
      await StreakUpdater.updateStreak(userId, AppConstants.streakWater, DateTime.now());
      ref.invalidate(dashboardDataProvider(_selectedDate));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.trackAddedWaterMl(amount: amountMl.toStringAsFixed(0)))),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, l10n: context.l10n, error: e);
      }
    }
  }

  Widget _buildMacroRow(BuildContext context, String label, double current, double target, Color color, {bool showTarget = true}) {
    final percentage = target > 0 ? (current / target * 100).clamp(0.0, 100.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              showTarget && target > 0
                  ? '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g'
                  : '${current.toStringAsFixed(1)} g',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        if (showTarget && target > 0) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ],
    );
  }

  /// Makro z podziałem: główny wiersz (np. Tłuszcze X/Y g) + pod wiersz (w tym nasycone: Z g)
  Widget _buildMacroRowWithSub(
    BuildContext context,
    String label,
    double current,
    double target,
    Color color,
    String subLabel,
    double subValue, {
    String? subLabel2,
    double? subValue2,
  }) {
    final percentage = target > 0 ? (current / target * 100).clamp(0.0, 100.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            '$subLabel: ${subValue.toStringAsFixed(1)} g',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        if (subLabel2 != null && subValue2 != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              '$subLabel2: ${subValue2.toStringAsFixed(1)} g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildWaterCard(BuildContext context, WidgetRef ref, double current, double goal) {
    final percentage = goal > 0 ? (current / goal * 100).clamp(0, 100) : 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.go(AppRoutes.water),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.trackWater,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${current.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} ml',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 12,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.trackWaterTipSerious,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (_isTodaySelected()) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _addWaterFromDashboard(ref, 250),
                      child: const Text('+250 ml'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _addWaterFromDashboard(ref, 500),
                      child: const Text('+500 ml'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard(BuildContext context, WidgetRef ref, List<Activity> activities) {
    final today = DateTime.now();
    final isSelectedToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final activitiesTitle = isSelectedToday
        ? context.l10n.trackActivitiesToday
        : context.l10n.trackActivitiesOnDate(date: '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}');
    return Card(
      child: InkWell(
        onTap: () async {
          await context.push(AppRoutes.activities, extra: _selectedDate);
          if (context.mounted) ref.invalidate(dashboardDataProvider(_selectedDate));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activitiesTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                Text(
                  context.l10n.trackNoActivities,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                )
              else
                ...activities.take(3).map((activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (activity.isFromGarmin)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  'assets/images/garmin_connect_logo.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, Object error, StackTrace? stackTrace) => Icon(Icons.watch, size: 24, color: Colors.blue.shade700),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              activity.isFromGarmin
                                  ? activity.name.replaceFirst(' (Garmin)', '')
                                  : activity.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    )),
              if (activities.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.trackAndMoreCount(count: '${activities.length - 3}'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealsCard(BuildContext context, WidgetRef ref, List<Meal> meals) {
    final today = DateTime.now();
    final isSelectedToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final mealsTitle = isSelectedToday
        ? context.l10n.trackMealsToday
        : context.l10n.trackMealsOnDate(date: '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}');
    return Card(
      child: InkWell(
        onTap: () {
          context.go(AppRoutes.meals);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mealsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              if (meals.isEmpty)
                Text(
                  context.l10n.trackNoMeals,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                )
              else
                ...meals.take(3).map((meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              meal.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            '${meal.calories.toStringAsFixed(0)} kcal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    )),
              if (meals.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.trackAndMoreCount(count: '${meals.length - 3}'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    final days = [context.l10n.trackDayMon, context.l10n.trackDayTue, context.l10n.trackDayWed, context.l10n.trackDayThu, context.l10n.trackDayFri, context.l10n.trackDaySat, context.l10n.trackDaySun];
    return days[weekday - 1];
  }
}

