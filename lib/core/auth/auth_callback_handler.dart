import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'sign_out_guard.dart';

/// Czy URI to callback OAuth/magic link z Supabase (powrót z logowania Google itd.).
bool isAuthCallbackUri(Uri? uri) {
  if (uri == null) return false;
  final s = uri.toString();
  if (!s.contains('auth/callback') && !s.contains('auth%2Fcallback')) return false;
  // Nie traktuj jako sukcesu linku z błędem (odmowa, wygasły link).
  if (s.contains('error=') || s.contains('error_code=')) return false;
  return true;
}

/// Ustawia sesję z linku auth/callback. Nie rzuca – loguje błędy.
Future<void> handleAuthCallbackUri(Uri uri) async {
  if (!SupabaseConfig.isInitialized) return;
  final s = uri.toString();
  if (s.contains('error=') || s.contains('error_code=')) {
    debugPrint('⚠️ Auth callback z błędem w URI – pomijam');
    return;
  }
  try {
    await SupabaseConfig.auth.getSessionFromUrl(uri);
    debugPrint('✅ Sesja z linku auth/callback ustawiona');
  } catch (e) {
    debugPrint('⚠️ getSessionFromUrl: $e');
  }
}

/// Pobiera initial link, sprawdza guard i – jeśli to auth/callback – ustawia sesję.
/// Zwraca true, jeśli sesja została ustawiona. Gdy Supabase nie jest inited – zwraca false.
Future<bool> tryProcessInitialAuthLink() async {
  try {
    if (!SupabaseConfig.isInitialized) return false;
    final uri = await AppLinks().getInitialLink();
    if (!isAuthCallbackUri(uri) || !await shouldProcessInitialAuthLink()) {
      return false;
    }
    await handleAuthCallbackUri(uri!);
    await clearSignOutMark();
    return SupabaseConfig.currentUserOrNull != null;
  } catch (e) {
    debugPrint('⚠️ tryProcessInitialAuthLink: $e');
    return false;
  }
}
