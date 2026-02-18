import 'package:shared_preferences/shared_preferences.dart';

const _keySignOutAt = 'auth_sign_out_at_ms';
const _ignoreInitialLinkForSeconds = 120;

/// Wywołaj po wylogowaniu użytkownika (signOut). Przez kolejne
/// [_ignoreInitialLinkForSeconds] sekund getInitialLink() z auth/callback
/// nie będzie przetwarzany (ochrona przed starym linkiem przy starcie z ikony).
Future<void> markSignOut() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySignOutAt, DateTime.now().millisecondsSinceEpoch);
  } catch (_) {}
}

/// Zwraca true, jeśli można bezpiecznie przetworzyć initial link OAuth
/// (nie było niedawnego wylogowania).
Future<bool> shouldProcessInitialAuthLink() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final at = prefs.getInt(_keySignOutAt);
    if (at == null) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - at;
    return elapsed > (_ignoreInitialLinkForSeconds * 1000);
  } catch (_) {
    return true;
  }
}

/// Wywołaj po pomyślnym ustawieniu sesji z linku auth/callback.
Future<void> clearSignOutMark() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySignOutAt);
  } catch (_) {}
}
