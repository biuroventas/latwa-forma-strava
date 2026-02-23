import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'package:latwa_forma/core/utils/url_cleaner_stub.dart' if (dart.library.html) 'package:latwa_forma/core/utils/url_cleaner_web.dart' as url_cleaner;
import 'sign_out_guard.dart';

/// Czy URI to callback OAuth/magic link z Supabase (powrót z logowania Google itd.).
/// Na webie Supabase często przekierowuje na Site URL z tokenami w hash (np. #access_token=...)
/// albo z parametrem ?code= (PKCE) – rozpoznajemy też te przypadki.
bool isAuthCallbackUri(Uri? uri) {
  if (uri == null) return false;
  final s = uri.toString();
  if (s.contains('error=') || s.contains('error_code=')) return false;
  if (s.contains('auth/callback') || s.contains('auth%2Fcallback')) return true;
  if (uri.queryParameters.containsKey('code')) return true;
  final frag = uri.fragment;
  if (frag.isNotEmpty && frag.contains('access_token')) return true;
  return false;
}

/// Maks. czas na wymianę kodu / odczyt sesji z URL.
const _authCallbackTimeout = Duration(seconds: 10);

/// Ustawione, gdy wymiana kodu Google się nie udała – welcome może pokazać komunikat.
bool _lastGoogleCallbackFailed = false;
bool get lastGoogleCallbackFailed => _lastGoogleCallbackFailed;
void clearLastGoogleCallbackFailed() {
  _lastGoogleCallbackFailed = false;
}

/// Ustawia sesję z linku auth/callback. Nie rzuca – loguje błędy.
/// Gdy w URI jest ?code= (PKCE), najpierw wywołuje exchangeCodeForSession(code) – na webie działa pewniej niż getSessionFromUrl.
Future<void> handleAuthCallbackUri(Uri uri) async {
  if (!SupabaseConfig.isInitialized) return;
  _lastGoogleCallbackFailed = false;
  final s = uri.toString();
  if (s.contains('error=') || s.contains('error_code=')) {
    debugPrint('⚠️ Auth callback z błędem w URI – pomijam');
    return;
  }
  final code = uri.queryParameters['code'];

  // PKCE: najpierw wymiana kodu – na webie często pewniejsza niż getSessionFromUrl(uri).
  if (code != null && code.isNotEmpty) {
    debugPrint('🔐 Wymiana kodu PKCE (długość kodu: ${code.length})...');
    try {
      await SupabaseConfig.auth.exchangeCodeForSession(code).timeout(
        _authCallbackTimeout,
        onTimeout: () => throw TimeoutException('exchangeCodeForSession'),
      );
      debugPrint('✅ Sesja ustawiona przez exchangeCodeForSession');
      if (kIsWeb) url_cleaner.clearAuthParamsFromUrl();
      return;
    } on TimeoutException {
      debugPrint('⚠️ exchangeCodeForSession: timeout');
      _lastGoogleCallbackFailed = true;
      rethrow;
    } catch (e, st) {
      debugPrint('⚠️ exchangeCodeForSession: $e');
      if (kDebugMode) debugPrint('$st');
      _lastGoogleCallbackFailed = true;
    }
  }

  // Fallback: getSessionFromUrl (np. hash #access_token=).
  try {
    await SupabaseConfig.auth.getSessionFromUrl(uri).timeout(
      _authCallbackTimeout,
      onTimeout: () {
        debugPrint('⚠️ getSessionFromUrl timeout po ${_authCallbackTimeout.inSeconds}s');
        throw TimeoutException('getSessionFromUrl');
      },
    );
    debugPrint('✅ Sesja z linku auth/callback ustawiona');
    if (kIsWeb) url_cleaner.clearAuthParamsFromUrl();
  } on TimeoutException {
    if (code != null) _lastGoogleCallbackFailed = true;
    rethrow;
  } catch (e) {
    debugPrint('⚠️ getSessionFromUrl: $e');
    if (code != null) _lastGoogleCallbackFailed = true;
  }
}

/// Pobiera initial link, sprawdza guard i – jeśli to auth/callback – ustawia sesję.
/// Zwraca true, jeśli sesja została ustawiona. Gdy Supabase nie jest inited – zwraca false.
/// Z timeoutem, żeby przy wolnej sieci ekran ładowania nie wisiał w nieskończoność.
/// Na webie przy ?code= nie wywołujemy getInitialLink() – od razu używamy Uri.base, żeby uniknąć zawieszania.
Future<bool> tryProcessInitialAuthLink() async {
  try {
    if (!SupabaseConfig.isInitialized) {
      if (kIsWeb && Uri.base.queryParameters.containsKey('code')) {
        debugPrint('⚠️ Auth: Supabase nie zainicjalizowany – nie można wymienić kodu z URL. Sprawdź env (SUPABASE_URL, SUPABASE_ANON_KEY).');
      }
      return false;
    }
    Uri? uri;
    if (kIsWeb && Uri.base.queryParameters.containsKey('code')) {
      uri = Uri.base;
      debugPrint('🔐 Auth: wykryto ?code= w URL (origin: ${Uri.base.origin}), rozpoczynam wymianę...');
    } else if (kIsWeb && isAuthCallbackUri(Uri.base)) {
      uri = Uri.base;
    } else {
      uri = await AppLinks().getInitialLink();
      if (kIsWeb && !isAuthCallbackUri(uri) && isAuthCallbackUri(Uri.base)) {
        uri = Uri.base;
      }
    }
    if (!isAuthCallbackUri(uri)) return false;
    // Świeży powrót z Google (?code=) – zawsze przetwarzaj. Guard tylko dla starych linków (magic link itd.).
    final hasFreshCode = uri!.queryParameters.containsKey('code');
    if (!hasFreshCode && !await shouldProcessInitialAuthLink()) return false;
    await handleAuthCallbackUri(uri).timeout(
      _authCallbackTimeout,
      onTimeout: () {
        debugPrint('⚠️ tryProcessInitialAuthLink timeout');
        throw TimeoutException('tryProcessInitialAuthLink');
      },
    );
    await clearSignOutMark();
    return SupabaseConfig.currentUserOrNull != null;
  } on TimeoutException {
    return false;
  } catch (e) {
    debugPrint('⚠️ tryProcessInitialAuthLink: $e');
    return false;
  }
}
