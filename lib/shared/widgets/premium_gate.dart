import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      featureName: featureName ?? 'Ta funkcja',
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
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Funkcja Premium'),
      content: Text(
        '${featureName ?? "Ta funkcja"} jest dostępna w planie Premium. '
        'Czy chcesz dowiedzieć się więcej?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Zobacz Premium'),
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
              '$featureName jest w Premium',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Odblokuj nieograniczoną poradę AI, eksport PDF i więcej.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.star),
              label: const Text('Sprawdź Premium'),
            ),
          ],
        ),
      ),
    );
  }
}
