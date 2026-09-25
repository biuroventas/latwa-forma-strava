import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class PlanLoadingScreen extends StatefulWidget {
  const PlanLoadingScreen({
    super.key,
    this.targetCalories,
    this.targetDate,
    this.goal,
  });

  final double? targetCalories;
  final DateTime? targetDate;
  final String? goal;

  @override
  State<PlanLoadingScreen> createState() => _PlanLoadingScreenState();
}

class _MilestoneStep {
  final IconData icon;
  final String label;
  final String statusText;

  const _MilestoneStep({
    required this.icon,
    required this.label,
    required this.statusText,
  });
}

class _PlanLoadingScreenState extends State<PlanLoadingScreen>
    with TickerProviderStateMixin {
  List<_MilestoneStep> _steps(AppLocalizations l10n) => [
        _MilestoneStep(
          icon: Icons.person_outline,
          label: l10n.onbPlanStepData,
          statusText: l10n.onbPlanStatusAnalyzing,
        ),
        _MilestoneStep(
          icon: Icons.calculate_outlined,
          label: l10n.onbPlanStepCalc,
          statusText: l10n.onbPlanStatusCalories,
        ),
        _MilestoneStep(
          icon: Icons.pie_chart_outline,
          label: l10n.onbPlanStepMacro,
          statusText: l10n.onbPlanStatusMacro,
        ),
        _MilestoneStep(
          icon: Icons.check_circle_outline,
          label: l10n.onbPlanStepDone,
          statusText: l10n.onbPlanStatusAlmost,
        ),
      ];

  String _currentText = '';
  bool _thanksPhase = true;
  bool _gotItPhase = false;
  int _completedStepIndex = -1; // -1 = przed krokiem 0, 0-3 = ukończone kroki
  int _activeStepIndex = 0; // aktualnie wyświetlany (0-3)

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentText = context.l10n.onbPlanThanks);
      _startAnimation();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    final l10n = context.l10n;
    final steps = _steps(l10n);

    // 1. "Dziękujemy!"
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentText = l10n.onbPlanThanks;
        _thanksPhase = true;
        _gotItPhase = false;
      });
      _bounceController.forward(from: 0);
    }

    // 2. Kroczące kroki – Tworzymy plan + milestone stepper
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _thanksPhase = false;
      _currentText = steps[0].statusText;
      _activeStepIndex = 0;
      _completedStepIndex = -1;
    });

    // Krok 1: Dane (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 0;
        _activeStepIndex = 1;
        _currentText = steps[1].statusText;
      });
    }

    // Krok 2: Kalkulacja (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 1;
        _activeStepIndex = 2;
        _currentText = steps[2].statusText;
      });
    }

    // Krok 3: Makro (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 2;
        _activeStepIndex = 3;
        _currentText = steps[3].statusText;
      });
    }

    // Krok 4: Gotowe (~1s)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _completedStepIndex = 3;
        _activeStepIndex = 3;
      });
    }

    // 3. "Mamy to!" + confetti
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _currentText = l10n.onbPlanGotIt;
        _gotItPhase = true;
      });
      _confettiController.play();
      _bounceController.reset();
      _bounceController.forward(from: 0);
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      await _showCompletionDialog(context);
      if (mounted) context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _showCompletionDialog(BuildContext context) async {
    final calories = widget.targetCalories;
    final date = widget.targetDate;
    final dateStr = date != null
        ? DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(date)
        : null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final dialogL10n = ctx.l10n;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(dialogL10n.onbPlanReadyTitle)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogL10n.onbPlanWhatDone,
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  calories != null
                      ? dialogL10n.onbPlanCaloriesComputedWithValue(
                          calories: calories.toStringAsFixed(0),
                        )
                      : dialogL10n.onbPlanCaloriesComputed,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                if (widget.goal == AppConstants.goalMaintain) ...[
                  const SizedBox(height: 8),
                  Text(
                    dialogL10n.onbGoalUnchangedSameWeight,
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ] else if (dateStr != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dialogL10n.onbPlanTargetDate(date: dateStr),
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  dialogL10n.onbPlanChangeInProfile,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  dialogL10n.onbPlanHowToUse,
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(dialogL10n.onbPlanTipMeals,
                    style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(dialogL10n.onbPlanTipWater,
                    style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(dialogL10n.onbPlanTipWeight,
                    style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(dialogL10n.onbPlanTipDashboard,
                    style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(
                  dialogL10n.onbPlanMedicalNote,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => ctx.pop(),
              child: Text(dialogL10n.onbPlanStartButton),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainText() {
    final isBouncePhase = _thanksPhase || _gotItPhase;
    final color = Theme.of(context).colorScheme;

    final textWidget = Text(
      _currentText,
      key: ValueKey(_currentText),
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: color.onSurface,
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );

    if (isBouncePhase) {
      return ScaleTransition(
        scale: _bounceAnimation,
        child: textWidget,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: textWidget,
    );
  }

  /// [stepColor] – kolor kółka i linii (np. primary), [iconOnStepColor] – kolor ikony check na kółku (np. onPrimary).
  Widget _buildMilestoneStepper(Color stepColor, Color iconOnStepColor) {
    final steps = _steps(context.l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepIcon(
              index: i,
              step: steps[i],
              stepColor: stepColor,
              iconOnStepColor: iconOnStepColor,
            ),
            if (i < steps.length - 1) _buildConnectingLine(i, stepColor),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIcon({
    required int index,
    required _MilestoneStep step,
    required Color stepColor,
    required Color iconOnStepColor,
  }) {
    final isCompleted = index <= _completedStepIndex;
    final isActive = index == _activeStepIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? stepColor
            : isActive
                ? stepColor.withValues(alpha: 0.5)
                : stepColor.withValues(alpha: 0.2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: stepColor.withValues(alpha: 0.5),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check : step.icon,
        size: isCompleted ? 24 : 20,
        color: isCompleted
            ? iconOnStepColor
            : isActive
                ? iconOnStepColor
                : iconOnStepColor.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildConnectingLine(int index, Color stepColor) {
    final isFilled = index < _completedStepIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isFilled ? stepColor : stepColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final onPrimary = color.onPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Ikona główna
                  Icon(
                    Icons.fitness_center,
                    size: 72,
                    color: color.primary,
                  ),
                  const SizedBox(height: 40),
                  // Główny tekst
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildMainText(),
                  ),
                  const SizedBox(height: 48),
                  // Kroczące kroki (milestone stepper) – kółka w kolorze primary, check w onPrimary
                  if (!_thanksPhase)
                    _buildMilestoneStepper(color.primary, color.onPrimary),
                ],
              ),
            ),
          // Confetti overlay (pełny ekran)
          IgnorePointer(
            child: SizedBox.expand(
              child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.03,
              numberOfParticles: 25,
              gravity: 0.08,
              colors: [
                onPrimary,
                Colors.white,
                color.primaryContainer,
              ],
              shouldLoop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
