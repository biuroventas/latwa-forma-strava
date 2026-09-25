import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';

/// Spójne komunikaty sukcesu.
class SuccessMessage {
  static void show(
    BuildContext context,
    String message, {
    required AppLocalizations l10n,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: duration,
      ),
    );
  }
}
