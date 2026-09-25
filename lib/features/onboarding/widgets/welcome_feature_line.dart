import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';

/// Skala welcome względem szerokości 390. Cały układ trzyma te same proporcje.
double welcomeUiScale(BuildContext context) {
  return (MediaQuery.sizeOf(context).width / 390).clamp(0.8, 1.4);
}

/// Napis nad przyciskami: funkcje po kolei, tytuł i opis tym samym stylem.
class WelcomeFeatureLine extends StatefulWidget {
  const WelcomeFeatureLine({super.key});

  @override
  State<WelcomeFeatureLine> createState() => _WelcomeFeatureLineState();
}

class _WelcomeFeatureLineState extends State<WelcomeFeatureLine> {
  static const _shadow = <Shadow>[
    Shadow(color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 1)),
  ];

  static List<({IconData icon, String title, String description})> _items(
    AppLocalizations l10n,
  ) =>
      [
        (
          icon: Icons.restaurant_outlined,
          title: l10n.onbFeatureCaloriesTitle,
          description: l10n.onbFeatureCaloriesDesc,
        ),
        (
          icon: Icons.trending_up,
          title: l10n.onbFeatureWeightTitle,
          description: l10n.onbFeatureWeightDesc,
        ),
        (
          icon: Icons.flag_outlined,
          title: l10n.onbFeaturePlanTitle,
          description: l10n.onbFeaturePlanDesc,
        ),
        (
          icon: Icons.auto_awesome_outlined,
          title: l10n.onbFeatureAiTitle,
          description: l10n.onbFeatureAiDesc,
        ),
        (
          icon: Icons.inventory_2_outlined,
          title: l10n.onbFeatureProductsTitle,
          description: l10n.onbFeatureProductsDesc,
        ),
      ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (!mounted) return;
      setState(() {
        final len = _items(context.l10n).length;
        _index = (_index + 1) % len;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context.l10n);
    final item = items[_index % items.length];
    final scale = welcomeUiScale(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 480),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.45),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: FittedBox(
            key: ValueKey<int>(_index),
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: Colors.white,
                      shadows: _shadow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.title,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        shadows: _shadow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    shadows: _shadow,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(horizontal: 3 * scale),
                width: (i == _index ? 16 : 5) * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: i == _index ? 0.95 : 0.45),
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
