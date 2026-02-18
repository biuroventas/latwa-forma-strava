import 'package:flutter/material.dart';

/// Centralizowana obsługa błędów.
class ErrorHandler {
  static String getMessage(dynamic error, {String? fallback}) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection') || msg.contains('socket')) {
      return 'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';
    }
    if (msg.contains('timeout')) {
      return 'Przekroczono limit czasu. Spróbuj ponownie.';
    }
    if (msg.contains('auth') || msg.contains('permission') || msg.contains('unauthorized')) {
      return 'Błąd autoryzacji. Zaloguj się ponownie.';
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return 'Nie znaleziono zasobu.';
    }
    if (msg.contains('server') || msg.contains('500')) {
      return 'Błąd serwera. Spróbuj później.';
    }
    return fallback ?? 'Wystąpił błąd. Spróbuj ponownie.';
  }

  static void showSnackBar(
    BuildContext context, {
    required dynamic error,
    String? fallback,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;
    final message = getMessage(error, fallback: fallback);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade700,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Spróbuj ponownie',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
