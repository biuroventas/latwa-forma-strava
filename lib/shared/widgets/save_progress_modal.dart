import 'package:flutter/material.dart';
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
  });

  final int mealsCount;
  final VoidCallback onDismiss;
  final VoidCallback onLinkEmail;
  final VoidCallback? onLinkApple;
  final VoidCallback? onLinkGoogle;
  /// Gdy podane – pokazuje link „Mam już kod z maila”, żeby dokończyć weryfikację bez ponownego wysyłania.
  final VoidCallback? onEnterCode;

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
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.save_alt, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Zapisz postępy'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            mealsCount > 0
                ? 'Masz już $mealsCount posiłków! '
                  'Zaloguj się, aby nie stracić danych przy reinstalacji aplikacji.'
                : 'Załóż konto, żeby Twoje posiłki, aktywności i waga były zapisane w chmurze '
                  'i dostępne na każdym urządzeniu – nic nie zginie przy reinstalacji.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Wybierz sposób logowania:',
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
                label: const Text('Kontynuuj z Apple'),
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
                label: const Text('Kontynuuj z Google'),
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
              label: const Text('Kontynuuj z emailem'),
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
                  'Mam już kod z maila – wpisz go',
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
            child: const Text('Później'),
          ),
        ],
      ),
    );
  }
}

