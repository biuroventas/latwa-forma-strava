import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';

/// Spójny dialog potwierdzenia usunięcia.
class DeleteConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmLabel,
  }) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmLabel ?? l10n.commonDelete),
          ),
        ],
      ),
    );
    return result == true;
  }
}
