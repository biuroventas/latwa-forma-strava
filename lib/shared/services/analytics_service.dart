import 'package:flutter/foundation.dart';

/// Serwis analityki – logowanie zdarzeń.
/// Można podpiąć Firebase Analytics lub inny backend.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  AnalyticsService._();

  bool _enabled = true;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  void logEvent(String name, [Map<String, dynamic>? params]) {
    if (!_enabled) return;
    if (kDebugMode) {
      debugPrint('📊 Analytics: $name ${params ?? {}}');
    }
    // Można podpiąć Firebase Analytics lub inny provider:
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', {'screen_name': screenName});
  }

  void logMealAdded({String? source}) {
    logEvent('meal_added', {'source': source ?? 'manual'});
  }

  void logWeightAdded() => logEvent('weight_added');
  void logActivityAdded() => logEvent('activity_added');
  void logWaterAdded() => logEvent('water_added');
  void logGoalVerificationApplied() => logEvent('goal_verification_applied');
}
