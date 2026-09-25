import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modal wyświetlany użytkownikowi anonimowemu po dodaniu określonej liczby posiłków.
/// Zachęca do zapisania postępów przez zalogowanie (Apple, Google, Email).
class SaveProgressModal extends StatelessWidget {
  const SaveProgressModal({
    super.key,
    required this.mealsCount,
    required this.onDismiss,
    required this.onLinkEmail,
    this.onLinkApple,
    this.onLinkGoogle,
    this.onEnterCode,
    this.allowDismiss = true,
    this.titleText,
    this.bodyText,
  });

  final int mealsCount;
  final VoidCallback onDismiss;
  final VoidCallback onLinkEmail;
  final VoidCallback? onLinkApple;
  final VoidCallback? onLinkGoogle;
  /// Gdy podane – pokazuje link „Mam już kod z maila”, żeby dokończyć weryfikację bez ponownego wysyłania.
  final VoidCallback? onEnterCode;
  final bool allowDismiss;
  final String? titleText;
  final String? bodyText;

  static const String _prefKey = 'save_progress_modal_dismissed';

  /// Czy modal był już pokazany / odrzucony
  static Future<bool> wasDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.save_alt, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(titleText ?? l10n.onbSaveProgressTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            bodyText ??
                (mealsCount > 0
                    ? l10n.onbSaveProgressBodyWithMeals(count: mealsCount)
                    : l10n.onbSaveProgressBodyEmpty),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onbChooseLoginMethod,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          if (onLinkApple != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLinkApple!();
                },
                icon: const Icon(Icons.apple, size: 20),
                label: Text(l10n.onbContinueApple),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (onLinkGoogle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLinkGoogle!();
                },
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: Text(l10n.onbContinueGoogle),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onLinkEmail();
              },
              icon: const Icon(Icons.email, size: 20),
              label: Text(l10n.onbContinueWithEmail),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (onEnterCode != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEnterCode!();
                },
                child: Text(
                  l10n.onbEnterCodeLink,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss();
            },
            child: Text(allowDismiss ? l10n.onbLater : l10n.guestTrialViewOnly),
          ),
        ],
      ),
    );
  }
}
