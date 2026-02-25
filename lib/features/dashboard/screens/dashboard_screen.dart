import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
import '../../../core/providers/subscription_provider.dart';
import '../../meals/screens/eating_out_bottom_sheet.dart';
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
  final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  final profile = await service.getProfile(userId);
  final meals = await service.getMeals(userId, date: date);
  final activities = await service.getActivities(userId, date: date);
  final totalWater = await service.getTotalWaterForDate(userId, date);
  final totalMealsCount = await service.getMealsCount(userId);

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
    totalBurned += activity.caloriesBurned;
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
  DateTime _selectedDate = DateTime.now();
  /// 0 = ostatni tydzień (do dziś), -1 = wstecz o tydzień, -2 = jeszcze wstecz itd.
  int _weekOffset = 0;
  final _caloriesCardKey = GlobalKey();
  static const _prefShowMacros = 'show_macros';

  @override
  void initState() {
    super.initState();
    _loadShowMacros();
    // Rozpocznij okres próbny przy pierwszym wejściu (zapis pierwszego użycia)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firstUseAtProvider.future);
    });
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
  Widget build(BuildContext context) {
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
                        'Łatwa Forma',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Premium',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.amber.shade300
                                : Colors.amber.shade700,
                          ),
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
            label: 'Statystyki',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statystyki',
              onPressed: () => context.push(AppRoutes.statistics),
            ),
          ),
          Semantics(
            label: 'Cele i wyzwania',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.emoji_events),
              tooltip: 'Cele i wyzwania',
              onPressed: () => context.push(AppRoutes.challenges),
            ),
          ),
          Semantics(
            label: 'Profil',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profil',
              onPressed: () => context.push(AppRoutes.profile),
            ),
          ),
        ],
      ),
      body: dashboardData.when(
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
          final message = isLoggedOut
              ? 'Sesja wygasła. Zaloguj się ponownie.'
              : isFailedFetch
                  ? 'Nie udało się załadować danych. Sprawdź połączenie internetowe i naciśnij „Spróbuj ponownie”.'
                  : 'Błąd: $error';
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
                    child: Text(isLoggedOut ? 'Zaloguj się' : 'Spróbuj ponownie'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _AddFab(
        onAddMeal: () async {
          final result = await context.push<bool>(AppRoutes.mealsAdd, extra: _selectedDate);
          if (result == true && context.mounted) ref.invalidate(dashboardDataProvider(_selectedDate));
        },
        onEatingOut: () async {
          final canProceed = await checkPremiumOrNavigate(context, ref, featureName: 'Posiłek „na mieście”');
          if (!canProceed || !context.mounted) return;
          final result = await showEatingOutBottomSheet(context, date: _selectedDate);
          if (result == true && context.mounted) ref.invalidate(dashboardDataProvider(_selectedDate));
        },
        onAddActivity: () async {
          final result = await context.push<bool>(AppRoutes.activitiesAdd, extra: _selectedDate);
          if (result == true && context.mounted) ref.invalidate(dashboardDataProvider(_selectedDate));
        },
        onWeight: () => context.push(AppRoutes.weight),
        onMeasurements: () => context.push(AppRoutes.bodyMeasurements),
        onFavorites: () async {
          final result = await context.push<bool>(AppRoutes.favorites, extra: _selectedDate);
          if (result == true && context.mounted) ref.invalidate(dashboardDataProvider(_selectedDate));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _shareCaloriesScreenshot() async {
    final boundary = _caloriesCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

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

        final dateStr = '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}';
        final bytes = byteData.buffer.asUint8List();
        if (kIsWeb) {
          final xFile = XFile.fromData(bytes, name: 'kalorie_${_selectedDate.day}_${_selectedDate.month}.png');
          await Share.shareXFiles([xFile], text: '📊 Łatwa Forma – Kalorie $dateStr');
        } else {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/kalorie_${_selectedDate.day}_${_selectedDate.month}.png');
          await file.writeAsBytes(bytes);
          final box = boundary as RenderBox;
          final shareRect = box.localToGlobal(Offset.zero) & box.size;
          await Share.shareXFiles(
            [XFile(file.path)],
            text: '📊 Łatwa Forma – Kalorie $dateStr',
            sharePositionOrigin: shareRect,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd udostępniania: $e')),
          );
        }
      } finally {
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kalendarz tygodniowy (na samej górze)
          _buildWeekCard(context, ref, isPremium),
          const SizedBox(height: 16),
          // Podsumowanie kalorii
          _buildCaloriesCard(
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

  Widget _buildCaloriesCard(
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
    final net = consumed - burned;
    final percentage = target > 0 ? (consumed / target * 100).clamp(0, 100) : 0;

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
                Text(
                  'Kalorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPremium) ...[
                      Text(
                        'Makroskładniki',
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
                      tooltip: 'Udostępnij',
                      onPressed: () async {
                        final canProceed = await checkPremiumOrNavigate(context, ref, featureName: 'Udostępnianie podsumowania');
                        if (canProceed && context.mounted) _shareCaloriesScreenshot();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, 'Spożyte', consumed.toStringAsFixed(0), Colors.green),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: _buildStatColumn(context, 'Cel na dziś', target.toStringAsFixed(0), Colors.blue),
                ),
                _buildStatColumn(context, 'Spalone', burned.toStringAsFixed(0), Colors.orange),
                _buildStatColumn(context, 'Bilans', net.toStringAsFixed(0), net < 0 ? Colors.red : Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            if (target > 0 && consumed > target)
              Text(
                'Nadwyżka: ${(consumed - target).toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              )
            else
              Text(
                '${percentage.toStringAsFixed(0)}% celu',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            // Makroskładniki (Premium + checkbox)
            if (isPremium && _showMacros) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Makroskładniki',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildMacroRow(context, 'Białko', protein, targetProtein, Colors.blue),
              const SizedBox(height: 12),
              _buildMacroRowWithSub(context, 'Tłuszcze', fat, targetFat, Colors.orange, 'w tym nasycone', saturatedFat),
              const SizedBox(height: 12),
              _buildMacroRowWithSub(context, 'Węglowodany', carbs, targetCarbs, Colors.green, 'w tym cukry', sugar, subLabel2: 'błonnik', subValue2: fiber),
              const SizedBox(height: 12),
              _buildMacroRow(context, 'Sól', salt, 0, Colors.grey, showTarget: false),
            ],
            if (!isPremium) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.premium),
                icon: const Icon(Icons.pie_chart_outline, size: 18),
                label: const Text('Makroskładniki – w Premium'),
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

  Widget _buildStatColumn(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
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
      child: InkWell(
        onTap: () async {
          await context.push(AppRoutes.water, extra: _selectedDate);
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
                    'Woda',
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
                'Człowiek nie wielbłąd, pić musi! 💧',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
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
        ? 'Aktywności dzisiaj'
        : 'Aktywności – ${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
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
                  'Brak aktywności',
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
                          Expanded(
                            child: Text(
                              activity.name,
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
                    '... i ${activities.length - 3} więcej',
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
        ? 'Posiłki dzisiaj'
        : 'Posiłki – ${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
    return Card(
      child: InkWell(
        onTap: () async {
          await context.push(AppRoutes.meals, extra: _selectedDate);
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
                    mealsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              if (meals.isEmpty)
                Text(
                  'Brak posiłków',
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
                    '... i ${meals.length - 3} więcej',
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

  Widget _buildWeekCard(BuildContext context, WidgetRef ref, bool isPremium) {
    final today = DateTime.now();
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final dayCount = isNarrow ? 5 : 10; // telefon: 5 dni, tablet/desktop: 10 dni
    final baseDate = today.subtract(Duration(days: (dayCount - 1) - _weekOffset * dayCount));
    final weekDays = List.generate(dayCount, (index) => baseDate.add(Duration(days: index)));
    final canGoRight = _weekOffset < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Przegląd',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Wybierz datę',
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
                      _selectedDate = picked;
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
                  tooltip: 'Wcześniejszy tydzień',
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
                      setState(() => _selectedDate = date);
                      ref.invalidate(dashboardDataProvider(_selectedDate));
                      return;
                    }
                    if (!isPremium) {
                      final canProceed = await checkPremiumOrNavigate(
                        context,
                        ref,
                        featureName: 'Przeglądanie historii innych dni',
                      );
                      if (!canProceed || !mounted) return;
                    }
                    setState(() => _selectedDate = date);
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
                  tooltip: 'Późniejszy tydzień',
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
                      'Wyświetlane dane z ${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                          _weekOffset = 0;
                        });
                        ref.invalidate(dashboardDataProvider(_selectedDate));
                      },
                      child: const Text('Dzisiaj'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Nie'];
    return days[weekday - 1];
  }
}

/// Pływający przycisk „+” – Speed Dial: rozwija małe przyciski nad FAB-em.
class _AddFab extends StatefulWidget {
  final VoidCallback onAddMeal;
  final VoidCallback onEatingOut;
  final VoidCallback onAddActivity;
  final VoidCallback onWeight;
  final VoidCallback onMeasurements;
  final VoidCallback onFavorites;

  const _AddFab({
    required this.onAddMeal,
    required this.onEatingOut,
    required this.onAddActivity,
    required this.onWeight,
    required this.onMeasurements,
    required this.onFavorites,
  });

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> {
  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dodaj',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _menuItem(Icons.restaurant, 'Posiłek', Colors.green, widget.onAddMeal),
              _menuItem(Icons.storefront, 'Jedzenie na mieście', Colors.amber.shade700, widget.onEatingOut),
              _menuItem(Icons.fitness_center, 'Aktywność', Colors.orange, widget.onAddActivity),
              _menuItem(Icons.monitor_weight, 'Waga', Colors.blue, widget.onWeight),
              _menuItem(Icons.straighten, 'Pomiary', Colors.purple, widget.onMeasurements),
              _menuItem(Icons.favorite, 'Ulubione', Colors.pink, widget.onFavorites),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showAddMenu,
      heroTag: null,
      child: const Icon(Icons.add),
    );
  }
}

