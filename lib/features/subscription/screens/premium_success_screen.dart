import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// Ekran po udanej płatności Stripe – przekierowanie z STRIPE_SUCCESS_URL (/#/premium-success).
/// Dziękuje użytkownikowi i informuje, że Premium jest aktywowane; oferuje powrót do aplikacji lub zamknięcie karty.
class PremiumSuccessScreen extends ConsumerWidget {
  const PremiumSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Dziękujemy!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Premium zostało aktywowane.\nCiesz się pełnym dostępem do Łatwa Forma – eksport PDF, porady AI, integracje i więcej.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(profileProvider);
                  context.go(AppRoutes.dashboard);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Wróć do aplikacji'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 16),
                Text(
                  'Możesz też zamknąć tę kartę, jeśli płatność była w osobnym oknie.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
