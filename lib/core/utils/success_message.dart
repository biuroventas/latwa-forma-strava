import 'package:flutter/material.dart';

/// Spójne komunikaty sukcesu.
class SuccessMessage {
  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
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
