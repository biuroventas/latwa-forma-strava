import 'package:flutter/material.dart';

/// Stałe tła (jak na onboardingu): gradient + 2 zielone bloby.
abstract final class AppBackgroundTokens {
  static const Color green = Color(0xFF4CAF50);
  static const Color gradientStart = Color(0xFFF3FFF4);
  static const Color gradientEnd = Color(0xFFFFFFFF);
  static const double blobSize = 270.0;
  static const double blobOpacity = 0.15;
  static const double blobBlurRadius = 150.0;
}

/// Tło aplikacji: jasny gradient + 2 rozmyte zielone bloby tylko w skrajnych częściach ekranu (rogi).
/// Używane globalnie w ShellRoute, żeby szata graficzna była spójna w całej aplikacji.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppBackgroundTokens.gradientStart,
                AppBackgroundTokens.gradientEnd,
              ],
            ),
          ),
        ),
        // Bąbelek tylko w lewym górnym rogu (skraj ekranu).
        Positioned(
          top: -140,
          left: -120,
          child: Container(
            width: AppBackgroundTokens.blobSize,
            height: AppBackgroundTokens.blobSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppBackgroundTokens.green
                  .withValues(alpha: AppBackgroundTokens.blobOpacity),
              boxShadow: [
                BoxShadow(
                  color: AppBackgroundTokens.green
                      .withValues(alpha: AppBackgroundTokens.blobOpacity),
                  blurRadius: AppBackgroundTokens.blobBlurRadius,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Bąbelek tylko w prawym dolnym rogu (skraj ekranu).
        Positioned(
          bottom: -140,
          right: -120,
          child: Container(
            width: AppBackgroundTokens.blobSize,
            height: AppBackgroundTokens.blobSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppBackgroundTokens.green
                  .withValues(alpha: AppBackgroundTokens.blobOpacity * 0.9),
              boxShadow: [
                BoxShadow(
                  color: AppBackgroundTokens.green
                      .withValues(alpha: AppBackgroundTokens.blobOpacity),
                  blurRadius: AppBackgroundTokens.blobBlurRadius + 30,
                  spreadRadius: 25,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
