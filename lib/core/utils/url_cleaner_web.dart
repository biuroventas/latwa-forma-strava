// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, dead_code, dead_null_aware_expression
import 'dart:html' as html;

/// Usuwa z paska adresu parametry auth (?code= lub #access_token=), żeby odświeżenie nie powtarzało wymiany.
void clearAuthParamsFromUrl() {
  final loc = html.window.location;
  final search = loc.search ?? '';
  final hash = loc.hash ?? '';
  final hasAuth = search.contains('code=') || hash.contains('access_token');
  if (hasAuth) {
    final path = (loc.pathname?.isEmpty ?? true) ? '/' : (loc.pathname ?? '/');
    final clean = '${loc.origin}$path';
    html.window.history.replaceState(null, '', clean);
  }
}
