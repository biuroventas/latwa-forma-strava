import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/main_tab_provider.dart';
import 'add_action_sheet.dart';

/// Dolne zakładki: Dziś · Posiłki · + · Woda · Ja
class MainTabShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainTabShell({super.key, required this.navigationShell});

  /// Indeks UI (z + w środku) → indeks gałęzi shella (bez +).
  static int _branchForTab(int tabIndex) {
    if (tabIndex < 2) return tabIndex;
    return tabIndex - 1;
  }

  static int _tabForBranch(int branchIndex) {
    if (branchIndex < 2) return branchIndex;
    return branchIndex + 1;
  }

  void _onTabTap(BuildContext context, WidgetRef ref, int index) {
    if (index == 2) {
      showAddActionSheet(context, ref);
      return;
    }
    final branch = _branchForTab(index);
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
    ref.read(mainTabVisitProvider(branch).notifier).state++;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = _tabForBranch(navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => _onTabTap(context, ref, i),
        height: 64,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today, color: AppTheme.primaryColor),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant, color: AppTheme.primaryColor),
            label: l10n.navMeals,
          ),
          NavigationDestination(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            selectedIcon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: l10n.trackAdd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppTheme.primaryColor),
            label: l10n.navWater,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
