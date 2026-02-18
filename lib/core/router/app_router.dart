import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/supabase_config.dart';
import '../../core/providers/auth_state_provider.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/favorite_meal.dart';
import '../../shared/models/meal.dart';
import '../../shared/models/activity.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/onboarding_flow.dart';
import '../../features/onboarding/screens/plan_loading_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/meals/screens/meals_list_screen.dart';
import '../../features/meals/screens/add_meal_screen.dart';
import '../../features/meals/screens/ingredients_meal_screen.dart';
import '../../features/meals/screens/barcode_scanner_screen.dart';
import '../../features/meals/screens/barcode_product_screen.dart';
import '../../features/meals/screens/ai_photo_screen.dart';
import '../../features/favorites/screens/edit_favorite_meal_screen.dart';
import '../../features/favorites/screens/favorite_meals_screen.dart';
import '../../features/activities/screens/activities_list_screen.dart';
import '../../features/activities/screens/add_activity_screen.dart';
import '../../features/water/screens/water_tracking_screen.dart';
import '../../features/weight/screens/weight_tracking_screen.dart';
import '../../features/body_measurements/screens/body_measurements_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/export/screens/export_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/statistics/screens/bmi_calculator_screen.dart';
import '../../features/challenges/screens/challenges_screen.dart';
import '../../features/streaks/screens/streaks_screen.dart';
import '../../features/notifications/screens/notifications_settings_screen.dart';
import '../../features/integrations/screens/integrations_screen.dart';
import '../../features/ai_advice/screens/ai_advice_screen.dart';
import '../../features/subscription/screens/premium_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const planLoading = '/plan-loading';
  static const dashboard = '/dashboard';
  static const meals = '/meals';
  static const mealsAdd = '/meals/add';
  static const activities = '/activities';
  static const activitiesAdd = '/activities/add';
  static const water = '/water';
  static const weight = '/weight';
  static const bodyMeasurements = '/body-measurements';
  static const profile = '/profile';
  static const export = '/export';
  static const statistics = '/statistics';
  static const bmiCalculator = '/statistics/bmi';
  static const challenges = '/challenges';
  static const streaks = '/streaks';
  static const favorites = '/favorites';
  static const notifications = '/notifications';
  static const integrations = '/integrations';
  static const ingredientsMeal = '/meals/ingredients';
  static const barcodeScanner = '/meals/barcode';
  static const barcodeProduct = '/meals/barcode/product';
  static const aiPhoto = '/meals/ai-photo';
  static const editFavorite = '/favorites/edit';
  static const aiAdvice = '/ai-advice';
  static const premium = '/premium';
}

/// Strona bez animacji – natychmiastowa zamiana (eliminuje „scinanie” przy wszystkich przejściach).
CustomTransitionPage _noTransitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

GoRouter createAppRouter([AuthStateNotifier? authNotifier]) {
  final notifier = authNotifier ?? AuthStateNotifier();

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      try {
        final loc = state.uri.toString();
        if (loc.contains('auth/callback') || loc.contains('auth%2Fcallback')) {
          return AppRoutes.splash;
        }
        if (!SupabaseConfig.isInitialized) {
          return null;
        }
        final user = SupabaseConfig.currentUserOrNull;
        final isWelcome = state.matchedLocation == AppRoutes.welcome;
        final isLoggedIn = user != null && !(user.isAnonymous);

        if (isLoggedIn && isWelcome) {
          return AppRoutes.splash;
        }
        return null;
      } catch (_) {
        return null;
      }
    },
    routes: [
      ShellRoute(
        builder: (_, state, child) => AppBackground(
          child: OfflineBanner(
            child: RepaintBoundary(
              key: ValueKey<String>(state.matchedLocation),
              child: child,
            ),
          ),
        ),
        routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, state) => _noTransitionPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (_, state) => _noTransitionPage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => _noTransitionPage(state, const OnboardingFlow()),
      ),
      GoRoute(
        path: AppRoutes.planLoading,
        pageBuilder: (c, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _noTransitionPage(
            state,
            PlanLoadingScreen(
              targetCalories: extra?['targetCalories'] as double?,
              targetDate: extra?['targetDate'] as DateTime?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (_, s) => _noTransitionPage(s, const DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.meals,
        pageBuilder: (c, state) {
          final date = state.extra as DateTime? ?? DateTime.now();
          return _noTransitionPage(state, MealsListScreen(date: date));
        },
      ),
      GoRoute(
        path: AppRoutes.mealsAdd,
        pageBuilder: (c, state) {
          final extra = state.extra;
          final meal = extra is Meal ? extra : null;
          final date = extra is DateTime ? extra : null;
          return _noTransitionPage(state, AddMealScreen(meal: meal, date: date));
        },
      ),
      GoRoute(
        path: AppRoutes.activities,
        pageBuilder: (c, state) {
          final date = state.extra as DateTime? ?? DateTime.now();
          return _noTransitionPage(state, ActivitiesListScreen(date: date));
        },
      ),
      GoRoute(
        path: AppRoutes.activitiesAdd,
        pageBuilder: (c, state) {
          final extra = state.extra;
          final activity = extra is Activity ? extra : null;
          final date = extra is DateTime ? extra : null;
          return _noTransitionPage(state, AddActivityScreen(activity: activity, date: date));
        },
      ),
      GoRoute(
        path: AppRoutes.water,
        pageBuilder: (c, state) {
          final date = state.extra as DateTime? ?? DateTime.now();
          return _noTransitionPage(state, WaterTrackingScreen(initialDate: date));
        },
      ),
      GoRoute(
        path: AppRoutes.weight,
        pageBuilder: (_, state) => _noTransitionPage(state, const WeightTrackingScreen()),
      ),
      GoRoute(
        path: AppRoutes.bodyMeasurements,
        pageBuilder: (_, state) => _noTransitionPage(state, const BodyMeasurementsScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (_, state) => _noTransitionPage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.premium,
        pageBuilder: (_, state) => _noTransitionPage(state, const PremiumScreen()),
      ),
      GoRoute(
        path: AppRoutes.export,
        pageBuilder: (_, state) => _noTransitionPage(state, const ExportScreen()),
      ),
      GoRoute(
        path: AppRoutes.aiAdvice,
        pageBuilder: (_, state) => _noTransitionPage(state, const AiAdviceScreen()),
      ),
      GoRoute(
        path: AppRoutes.statistics,
        pageBuilder: (_, state) => _noTransitionPage(state, const StatisticsScreen()),
      ),
      GoRoute(
        path: AppRoutes.bmiCalculator,
        pageBuilder: (c, state) {
          final profile = state.extra;
          return _noTransitionPage(state, BMICalculatorScreen(profile: profile as UserProfile?));
        },
      ),
      GoRoute(
        path: AppRoutes.challenges,
        pageBuilder: (_, state) => _noTransitionPage(state, const ChallengesScreen()),
      ),
      GoRoute(
        path: AppRoutes.streaks,
        pageBuilder: (_, state) => _noTransitionPage(state, const StreaksScreen()),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (c, state) {
          final date = state.extra as DateTime?;
          return _noTransitionPage(state, FavoriteMealsScreen(initialDate: date));
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (_, state) => _noTransitionPage(state, const NotificationsSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.integrations,
        pageBuilder: (_, state) => _noTransitionPage(state, const IntegrationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.ingredientsMeal,
        pageBuilder: (_, state) => _noTransitionPage(state, const IngredientsMealScreen()),
      ),
      GoRoute(
        path: AppRoutes.barcodeScanner,
        pageBuilder: (_, state) => _noTransitionPage(state, const BarcodeScannerScreen()),
      ),
      GoRoute(
        path: AppRoutes.barcodeProduct,
        pageBuilder: (c, state) {
          final product = state.extra as Map<String, dynamic>;
          return _noTransitionPage(state, BarcodeProductScreen(product: product));
        },
      ),
      GoRoute(
        path: AppRoutes.aiPhoto,
        pageBuilder: (_, state) => _noTransitionPage(state, const AIPhotoScreen()),
      ),
      GoRoute(
        path: AppRoutes.editFavorite,
        pageBuilder: (c, state) {
          final favoriteMeal = state.extra as FavoriteMeal;
          return _noTransitionPage(state, EditFavoriteMealScreen(favoriteMeal: favoriteMeal));
        },
      ),
        ],
      ),
    ],
  );
}
