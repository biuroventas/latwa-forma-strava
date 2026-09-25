import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_provider.dart';

const _languageOptions = <(String, String, String)>[
  ('pl', 'PL', 'Polski'),
  ('en', 'EN', 'English'),
  ('uk', 'UA', 'Українська'),
];

/// Jeden przycisk języka. Pokazuje bieżący skrót i otwiera wybór PL, EN albo UA.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key, this.onVideo = false});

  /// Jasna kapsułka na filmie ekranu powitalnego.
  final bool onVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(appLocaleProvider);
    final code = saved?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final current = _languageOptions.firstWhere(
      (option) => option.$1 == code,
      orElse: () => _languageOptions.first,
    );
    final fg = onVideo ? Colors.white : const Color(0xFF1A1A1A);
    final border = onVideo
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFFD5DDD4);
    final fill = onVideo
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.white;
    final menuColor = onVideo ? const Color(0xF21C1C1C) : Colors.white;
    final menuFg = onVideo ? Colors.white : const Color(0xFF1A1A1A);

    return Semantics(
      button: true,
      label: current.$3,
      child: PopupMenuButton<String>(
        tooltip: current.$3,
        color: menuColor,
        elevation: 8,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (languageCode) {
          ref.read(appLocaleProvider.notifier).choose(languageCode);
        },
        itemBuilder: (context) {
          return [
            for (final option in _languageOptions)
              PopupMenuItem<String>(
                value: option.$1,
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        option.$2,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: menuFg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.$3,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: option.$1 == code
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: menuFg,
                        ),
                      ),
                    ),
                    if (option.$1 == code)
                      Icon(Icons.check, size: 18, color: menuFg),
                  ],
                ),
              ),
          ];
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: onVideo ? 16 : 0,
              sigmaY: onVideo ? 16 : 0,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, size: 16, color: fg),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        current.$2,
                        key: ValueKey(current.$2),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
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
}
