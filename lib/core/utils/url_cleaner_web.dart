// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, dead_code, dead_null_aware_expression
import 'dart:html' as html;

/// Usuwa z paska adresu parametry auth (?code= lub #...?code= lub #access_token=), żeby odświeżenie nie powtarzało wymiany.
/// Zachowuje ścieżkę w hash (np. #/profile) po usunięciu tylko code/state/access_token.
void clearAuthParamsFromUrl() {
  final loc = html.window.location;
  final search = loc.search ?? '';
  final hash = loc.hash ?? '';
  final hasAuth = search.contains('code=') || hash.contains('access_token') || hash.contains('code=');
  if (!hasAuth) return;
  final path = (loc.pathname?.isEmpty ?? true) ? '/' : (loc.pathname ?? '/');
  var clean = '${loc.origin}$path';
  if (hash.isNotEmpty) {
    final qIdx = hash.indexOf('?');
    if (qIdx >= 0) {
      final hashPath = hash.substring(0, qIdx);
      if (hashPath.isNotEmpty) clean = '$clean#$hashPath';
    } else {
      // Hash bez query (np. #/profile) – zachowaj
      clean = '$clean$hash';
    }
  }
  html.window.history.replaceState(null, '', clean);
}
