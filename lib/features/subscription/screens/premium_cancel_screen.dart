import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// Powrót ze Stripe po anulowaniu / wstecz (STRIPE_CANCEL_URL: /#/premium-cancel).
class PremiumCancelScreen extends StatelessWidget {
  const PremiumCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
                  color: AppTheme.textSecondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 72,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.premPaymentCancelled,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.premCancelBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.premium),
                icon: const Icon(Icons.workspace_premium),
                label: Text(l10n.premBackToPlans),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: Text(l10n.premGoToApp),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
