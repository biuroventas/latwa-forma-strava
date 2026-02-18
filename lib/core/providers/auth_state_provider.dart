import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Nasłuchuje zmian stanu auth (np. po powrocie z OAuth w Safari).
/// GoRouter używa refreshListenable, aby reagować na logowanie.
/// Gdy Supabase nie jest zainicjalizowany (np. brak .env na webie), nie subskrybuje – aplikacja się nie wysypuje.
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    if (SupabaseConfig.isInitialized) {
      _sub = SupabaseConfig.auth.onAuthStateChange.listen(_onAuthStateChange);
    }
  }

  StreamSubscription<AuthState>? _sub;
  AuthChangeEvent? _lastEvent;

  void _onAuthStateChange(AuthState data) {
    _lastEvent = data.event;
    notifyListeners();
  }

  /// Czy ostatnie zdarzenie to udane logowanie.
  bool get didJustSignIn =>
      _lastEvent == AuthChangeEvent.signedIn ||
      _lastEvent == AuthChangeEvent.tokenRefreshed;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
