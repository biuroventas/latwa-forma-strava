// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Na webie zapisuje code_verifier w localStorage i sessionStorage,
/// żeby przetrwał przeładowanie po powrocie z Google (PKCE). Zapis do obu
/// zmniejsza ryzyko „Code verifier could not be found” w części przeglądarek.
class WebLocalStoragePkceStorage extends GotrueAsyncStorage {
  const WebLocalStoragePkceStorage();

  static html.Storage? get _local => html.window.localStorage;
  static html.Storage? get _session => html.window.sessionStorage;

  @override
  Future<String?> getItem({required String key}) async {
    final v = _local?[key];
    if (v != null && v.isNotEmpty) return v;
    return _session?[key];
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _local?[key] = value;
    _session?[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _local?.remove(key);
    _session?.remove(key);
  }
}

GotrueAsyncStorage? getPkceStorageForWeb() => const WebLocalStoragePkceStorage();
