// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Na webie zapisuje code_verifier w natywnym localStorage przeglądarki,
/// żeby przetrwał pełne przeładowanie strony po powrocie z Google (PKCE).
class WebLocalStoragePkceStorage extends GotrueAsyncStorage {
  const WebLocalStoragePkceStorage();

  static html.Storage? get _storage => html.window.localStorage;

  @override
  Future<String?> getItem({required String key}) async {
    final s = _storage;
    return s == null ? null : s[key];
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _storage?[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _storage?.remove(key);
  }
}

GotrueAsyncStorage? getPkceStorageForWeb() => const WebLocalStoragePkceStorage();
