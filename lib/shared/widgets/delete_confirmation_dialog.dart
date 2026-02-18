import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Spójny dialog potwierdzenia usunięcia.
class DeleteConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Usuń',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }
}
