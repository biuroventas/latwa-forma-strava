import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/router/app_router.dart';

/// Pokazuje [child] gdy użytkownik ma Premium.
/// Gdy nie ma – wyświetla [lockedChild] lub domyślny widget z CTA do Premium.
class PremiumGate extends ConsumerWidget {
  final Widget child;
  final Widget? lockedChild;
  final String? featureName;

  const PremiumGate({
    super.key,
    required this.child,
    this.lockedChild,
    this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(hasPremiumAccessProvider);

    if (hasAccess) return child;

    if (lockedChild != null) return lockedChild!;

    return _PremiumLockedPlaceholder(
      featureName: featureName ?? context.l10n.premFeatureThis,
      onUpgrade: () => context.push(AppRoutes.premium),
    );
  }
}

/// Wywołaj przed wykonaniem akcji premium – zwraca true jeśli można kontynuować.
Future<bool> checkPremiumOrNavigate(
  BuildContext context,
  WidgetRef ref, {
  String? featureName,
}) async {
  final hasAccess = ref.read(hasPremiumAccessProvider);
  if (hasAccess) return true;

  if (!context.mounted) return false;
  final l10n = context.l10n;
  final name = featureName ?? l10n.premFeatureThis;
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.premFeatureTitle),
      content: Text(l10n.premFeatureDialog(feature: name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.premSeePremium),
        ),
      ],
    ),
  );

  if (go == true && context.mounted) {
    context.push(AppRoutes.premium);
  }
  return false; // Nigdy nie zwracamy true dla użytkowników Free
}

class _PremiumLockedPlaceholder extends StatelessWidget {
  final String featureName;
  final VoidCallback onUpgrade;

  const _PremiumLockedPlaceholder({
    required this.featureName,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.premLockedTitle(feature: featureName),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.premLockedBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.star),
              label: Text(l10n.premCheckPremium),
            ),
          ],
        ),
      ),
    );
  }
}
