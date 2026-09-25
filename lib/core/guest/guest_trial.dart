import 'package:shared_preferences/shared_preferences.dart';

import '../config/supabase_config.dart';
import '../constants/trial_constants.dart';

/// Rzucony, gdy anonimowy użytkownik chce dodać wpis po 7 dniach.
/// Dialog z połączeniem konta jest już pokazany — nie dokładać SnackBara.
class GuestTrialEndedException implements Exception {
  const GuestTrialEndedException();
}

/// 7 dni podstawowego użytku bez konta, liczone na urządzeniu.
/// Drugie „Zacznij bez konta” na tym telefonie nie zeruje licznika.
class GuestTrial {
  /// Pokazuje prośbę o konto. Zwraca true, gdy użytkownik nie jest już anonimowy.
  static Future<bool> Function()? requestContinue;

  static bool get _isAnonymous {
    final user = SupabaseConfig.currentUserOrNull;
    return user != null && user.isAnonymous;
  }

  /// Startuje licznik tylko raz. Wołać po pierwszym zapisie profilu
  /// i przy wejściu na dashboard (osoby, które już korzystały przed tą zmianą).
  static Future<void> startIfNeeded() async {
    if (!_isAnonymous) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(guestTrialStartPrefKey)) return;
    await prefs.setInt(guestTrialStartPrefKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<DateTime?> _startedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(guestTrialStartPrefKey);
    if (stored == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(stored);
  }

  /// Zostały czas dla anonima. Null, gdy konto jest zwykłe albo licznik jeszcze nie ruszył.
  static Future<Duration?> remaining() async {
    if (!_isAnonymous) return null;
    final start = await _startedAt();
    if (start == null) return null;
    final left = guestTrialDuration - DateTime.now().difference(start);
    if (left.isNegative) return Duration.zero;
    return left;
  }

  static Future<bool> isExpired() async {
    if (const bool.fromEnvironment('STORE_SCREENSHOTS')) return false;
    if (!_isAnonymous) return false;
    final start = await _startedAt();
    if (start == null) return false;
    return DateTime.now().difference(start) >= guestTrialDuration;
  }

  static Future<bool> isCardDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(guestTrialCardDismissedPrefKey) ?? false;
  }

  static Future<void> dismissCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(guestTrialCardDismissedPrefKey, true);
  }

  static Future<bool> wasLastDayReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(guestTrialLastDayShownPrefKey) ?? false;
  }

  static Future<void> markLastDayReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(guestTrialLastDayShownPrefKey, true);
  }

  /// Przed nowym wpisem (posiłek, woda, waga, aktywność, pomiar).
  static Future<void> ensureCanWrite() async {
    if (!await isExpired()) return;
    final continued = await requestContinue?.call() ?? false;
    if (!continued) throw const GuestTrialEndedException();
  }
}
