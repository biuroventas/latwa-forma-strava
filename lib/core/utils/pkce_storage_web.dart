// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Stały klucz zapasowy – gdy Supabase szuka verifiera pod innym kluczem (np. inny redirect_uri),
/// nadal możemy go odczytać i uniknąć "Code verifier could not be found".
const String _pkceBackupKey = 'lf_supabase_pkce_verifier_backup';

/// Na webie zapisuje code_verifier w localStorage i sessionStorage,
/// oraz pod zapasowym kluczem – zmniejsza ryzyko „Code verifier could not be found”
/// gdy klucz używany przy powrocie z OAuth różni się od klucza przy zapisie.
class WebLocalStoragePkceStorage extends GotrueAsyncStorage {
  const WebLocalStoragePkceStorage();

  static html.Storage? get _local => html.window.localStorage;
  static html.Storage? get _session => html.window.sessionStorage;

  @override
  Future<String?> getItem({required String key}) async {
    var v = _local?[key];
    if (v != null && v.isNotEmpty) return v;
    v = _session?[key];
    if (v != null && v.isNotEmpty) return v;
    v = _local?[_pkceBackupKey];
    if (v != null && v.isNotEmpty) return v;
    return _session?[_pkceBackupKey];
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _local?[key] = value;
    _session?[key] = value;
    _local?[_pkceBackupKey] = value;
    _session?[_pkceBackupKey] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _local?.remove(key);
    _session?.remove(key);
    // Usuń backup przy każdym usunięciu (Supabase czyści verifier po wymianie kodu).
    _local?.remove(_pkceBackupKey);
    _session?.remove(_pkceBackupKey);
  }
}

GotrueAsyncStorage? getPkceStorageForWeb() => const WebLocalStoragePkceStorage();
