import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';

class PlanLoadingScreen extends StatefulWidget {
  const PlanLoadingScreen({
    super.key,
    this.targetCalories,
    this.targetDate,
  });

  final double? targetCalories;
  final DateTime? targetDate;

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
  static const List<_MilestoneStep> _steps = [
    _MilestoneStep(
      icon: Icons.person_outline,
      label: 'Dane',
      statusText: 'Analizujemy Twoje dane…',
    ),
    _MilestoneStep(
      icon: Icons.calculate_outlined,
      label: 'Kalkulacja',
      statusText: 'Obliczanie kalorii…',
    ),
    _MilestoneStep(
      icon: Icons.pie_chart_outline,
      label: 'Makro',
      statusText: 'Makroskładniki…',
    ),
    _MilestoneStep(
      icon: Icons.check_circle_outline,
      label: 'Gotowe',
      statusText: 'Prawie gotowe…',
    ),
  ];

  String _currentText = 'Dziękujemy!';
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

    _startAnimation();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    // 1. "Dziękujemy!"
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _currentText = 'Dziękujemy!');
      _bounceController.forward(from: 0);
    }

    // 2. Kroczące kroki – Tworzymy plan + milestone stepper
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _currentText = _steps[0].statusText;
      _activeStepIndex = 0;
      _completedStepIndex = -1;
    });

    // Krok 1: Dane (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 0;
        _activeStepIndex = 1;
        _currentText = _steps[1].statusText;
      });
    }

    // Krok 2: Kalkulacja (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 1;
        _activeStepIndex = 2;
        _currentText = _steps[2].statusText;
      });
    }

    // Krok 3: Makro (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _completedStepIndex = 2;
        _activeStepIndex = 3;
        _currentText = _steps[3].statusText;
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
      setState(() => _currentText = 'Mamy to!');
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
        ? DateFormat('d MMMM yyyy', 'pl_PL').format(date)
        : null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Twój plan jest gotowy!')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Co zostało zrobione:',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Na podstawie wzrostu, wagi, wieku i poziomu aktywności obliczyliśmy Twoje dzienne zapotrzebowanie kaloryczne${calories != null ? ': ${calories.toStringAsFixed(0)} kcal.' : '.'}',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              if (dateStr != null) ...[
                const SizedBox(height: 4),
                Text(
                  '• Szacowany termin osiągnięcia celu: $dateStr',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Możesz w każdej chwili zmienić te dane w zakładce Profil (ikona osoby u góry).',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Jak korzystać z aplikacji:',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('• Dodawaj posiłki – śledź, co jesz i ile kalorii spożywasz',
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('• Pij wodę – ustaw przypomnienia w ustawieniach',
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('• Wpisuj wagę regularnie – widzisz postępy na wykresie',
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('• Sprawdzaj dashboard – tam widzisz swój dzienny cel i postępy',
                  style: Theme.of(ctx).textTheme.bodyMedium),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => ctx.pop(),
            child: const Text('Rozumiem, zaczynam!'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainText() {
    final isBouncePhase = _currentText == 'Dziękujemy!' || _currentText == 'Mamy to!';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _buildStepIcon(
              index: i,
              step: _steps[i],
              stepColor: stepColor,
              iconOnStepColor: iconOnStepColor,
            ),
            if (i < _steps.length - 1) _buildConnectingLine(i, stepColor),
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
                  if (_currentText != 'Dziękujemy!')
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
