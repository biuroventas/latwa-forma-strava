import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../guest/guest_trial.dart';

/// Centralizowana obsługa błędów.
class ErrorHandler {
  static String getMessage(dynamic error, AppLocalizations l10n, {String? fallback}) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection') || msg.contains('socket')) {
      return l10n.profErrNetwork;
    }
    if (msg.contains('cors') || msg.contains('xmlhttprequest') || msg.contains('failed to fetch')) {
      return l10n.profErrCors;
    }
    if (msg.contains('timeout')) {
      return l10n.profErrTimeout;
    }
    if (msg.contains('auth') || msg.contains('permission') || msg.contains('unauthorized')) {
      return l10n.profErrAuth;
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return l10n.profErrNotFound;
    }
    if (msg.contains('server') || msg.contains('500') || msg.contains('502')) {
      return fallback ?? l10n.profErrServer;
    }
    return fallback ?? l10n.profErrGeneric;
  }

  static void showSnackBar(
    BuildContext context, {
    required dynamic error,
    required AppLocalizations l10n,
    String? fallback,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;
    if (error is GuestTrialEndedException) return;
    final message = getMessage(error, l10n, fallback: fallback);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade700,
        action: onRetry != null
            ? SnackBarAction(
                label: l10n.commonRetry,
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
