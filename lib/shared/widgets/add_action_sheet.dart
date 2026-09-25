import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/meals/screens/eating_out_bottom_sheet.dart';
import 'premium_gate.dart';

/// Wspólny sheet „Dodaj” (środkowy + w tabach).
Future<void> showAddActionSheet(
  BuildContext context,
  WidgetRef ref, {
  DateTime? date,
  VoidCallback? onMealAdded,
}) {
  final selectedDate = date ?? DateTime.now();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final maxH = MediaQuery.sizeOf(sheetContext).height * 0.72;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  sheetContext.l10n.trackAdd,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _AddMenuItem(
                      icon: Icons.search,
                      label: sheetContext.l10n.trackSearchShort,
                      color: AppTheme.primaryColor,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await context.push<bool>(
                          AppRoutes.productSearch,
                          extra: mealFlowExtra(date: selectedDate),
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.qr_code_scanner,
                      label: sheetContext.l10n.trackScanBarcode,
                      color: Colors.teal,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await context.push<bool>(
                          AppRoutes.barcodeScanner,
                          extra: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.camera_alt,
                      label: sheetContext.l10n.trackAiPhotoAnalysisTooltip,
                      color: Colors.deepPurple,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final canProceed = await checkPremiumOrNavigate(
                          context,
                          ref,
                          featureName: context.l10n.trackFeatureAiMealAnalysis,
                        );
                        if (!canProceed || !context.mounted) return;
                        final result = await context.push<bool>(
                          AppRoutes.aiPhoto,
                          extra: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    const Divider(height: 16),
                    _AddMenuItem(
                      icon: Icons.restaurant,
                      label: sheetContext.l10n.trackMeal,
                      color: Colors.green,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await context.push<bool>(
                          AppRoutes.mealsAdd,
                          extra: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.storefront,
                      label: sheetContext.l10n.trackEatingOut,
                      color: Colors.amber.shade700,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final canProceed = await checkPremiumOrNavigate(
                          context,
                          ref,
                          featureName: context.l10n.trackFeatureEatingOut,
                        );
                        if (!canProceed || !context.mounted) return;
                        final result = await showEatingOutBottomSheet(
                          context,
                          date: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.fitness_center,
                      label: sheetContext.l10n.trackActivity,
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await context.push<bool>(
                          AppRoutes.activitiesAdd,
                          extra: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.monitor_weight,
                      label: sheetContext.l10n.trackWeight,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push(AppRoutes.weight);
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.straighten,
                      label: sheetContext.l10n.trackMeasurements,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push(AppRoutes.bodyMeasurements);
                      },
                    ),
                    _AddMenuItem(
                      icon: Icons.favorite,
                      label: sheetContext.l10n.trackFavorites,
                      color: Colors.pink,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await context.push<bool>(
                          AppRoutes.favorites,
                          extra: selectedDate,
                        );
                        if (result == true) onMealAdded?.call();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AddMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: color, size: 26),
      title: Text(label),
      onTap: onTap,
    );
  }
}
