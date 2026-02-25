import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:latwa_forma/core/utils/pkce_storage_stub.dart'
    if (dart.library.html) 'package:latwa_forma/core/utils/pkce_storage_web.dart' as pkce_storage;

class SupabaseConfig {
  static bool _initialized = false;

  /// Env załadowany z assetu/serwera (na webie dotenv bywa puste – tu mamy pewność).
  static final Map<String, String> _loadedEnv = {};

  /// Wartość zmiennej env (np. GARMIN_CLIENT_ID). Najpierw z _loadedEnv, potem z dotenv.
  static String? getEnv(String key) {
    final v = _loadedEnv[key]?.trim();
    if (v != null && v.isNotEmpty) return v;
    return dotenv.env[key]?.trim();
  }

  /// Czy Supabase został poprawnie zainicjalizowany (URL + klucz z .env).
  /// Gdy false, [auth] i [client] nie są dostępne – aplikacja pokazuje Welcome bez logowania.
  static bool get isInitialized => _initialized;

  /// Aktualny użytkownik bez rzucania wyjątku gdy Supabase nie jest zainicjalizowany (np. brak .env na webie).
  static User? get currentUserOrNull {
    if (!_initialized) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  /// Parsuje treść pliku .env (KEY=VALUE po linii) do mapy.
  static Map<String, String> _parseEnv(String content) {
    final map = <String, String>{};
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx <= 0) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      if (key.isEmpty) continue;
      // Usuń cudzysłowy z wartości
      final v = value.startsWith('"') && value.endsWith('"')
          ? value.substring(1, value.length - 1)
          : value;
      map[key] = v;
    }
    return map;
  }

  static Future<void> initialize() async {
    _initialized = false;
    try {
      if (kIsWeb) {
        // 1) Fetch z serwera (po deployu: build/web/env.production na latwaforma.pl)
        try {
          final url = Uri.base.resolve('env.production?v=${DateTime.now().millisecondsSinceEpoch}');
          final response = await http.get(url).timeout(
                const Duration(seconds: 5),
                onTimeout: () => http.Response('', 408),
              );
          if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
            final map = _parseEnv(response.body);
            if (map.isNotEmpty) {
              _loadedEnv.addAll(map);
              await dotenv.load(
                fileName: '.env',
                mergeWith: map,
                isOptional: true,
              );
              debugPrint('✅ env.production z serwera (web)');
            }
          }
        } catch (_) {}
        // 2) Asset przez rootBundle – niezawodne przy „flutter run -d chrome”
        for (final path in ['assets/env.production', 'env.production']) {
          try {
            final String raw = await rootBundle.loadString(path);
            final map = _parseEnv(raw);
            if (map.isNotEmpty) {
              _loadedEnv.addAll(map);
              await dotenv.load(
                fileName: '.env',
                mergeWith: map,
                isOptional: true,
              );
              debugPrint('✅ env z $path (web)');
              break;
            }
          } catch (e) {
            if (path == 'env.production') debugPrint('⚠️ rootBundle env: $e');
          }
        }
        // 3) Klasyczny dotenv.load na asset (fallback)
        if ((dotenv.env['GARMIN_CLIENT_ID']?.trim().isEmpty ?? true) &&
            (dotenv.env['SUPABASE_URL']?.trim().isEmpty ?? true)) {
          try {
            await dotenv.load(fileName: 'assets/env.production', isOptional: true);
          } catch (__) {}
        }
        if (_loadedEnv.isEmpty && dotenv.env.isNotEmpty) {
          _loadedEnv.addAll(Map<String, String>.from(dotenv.env));
        }
      } else {
        // Najpierw opcjonalnie .env (może nie istnieć po sklonowaniu z gita)
        await dotenv.load(fileName: '.env', isOptional: true);
        // Fallback: env.production (root lub assets) – żeby działało bez .env po clone
        if (dotenv.env['SUPABASE_URL']?.trim().isEmpty ?? true) {
          try {
            await dotenv.load(fileName: 'env.production', isOptional: true);
            if (dotenv.env['SUPABASE_URL']?.trim().isNotEmpty ?? false) {
              _loadedEnv.addAll(Map<String, String>.from(dotenv.env));
              debugPrint('✅ env.production załadowany z głównego folderu');
            }
          } catch (_) {}
        }
        if (dotenv.env['SUPABASE_URL']?.trim().isEmpty ?? true) {
          await dotenv.load(fileName: 'assets/env.production', isOptional: true);
          if (dotenv.env['SUPABASE_URL']?.trim().isNotEmpty ?? false) {
            _loadedEnv.addAll(Map<String, String>.from(dotenv.env));
            debugPrint('✅ env.production z assets');
          }
        }
        if (_loadedEnv.isEmpty && dotenv.env.isNotEmpty) {
          _loadedEnv.addAll(Map<String, String>.from(dotenv.env));
        }
        debugPrint('✅ env załadowany (desktop/mobile)');
      }
    } catch (e) {
      debugPrint('⚠️ Błąd ładowania env: $e');
      try {
        if (kIsWeb) {
          await dotenv.load(fileName: 'assets/env.production', isOptional: true);
        } else {
          await dotenv.load(fileName: 'env.production', isOptional: true);
          if (dotenv.env['SUPABASE_URL']?.trim().isEmpty ?? true) {
            await dotenv.load(fileName: 'assets/env.production', isOptional: true);
          }
        }
        debugPrint('✅ env załadowany z alternatywnej lokalizacji');
      } catch (e2) {
        debugPrint('❌ Błąd ładowania env: $e2');
        if (kDebugMode) {
          debugPrint('⚠️ Używanie wartości domyślnych (tylko dla testów)');
        }
      }
    }

    final supabaseUrl = getEnv('SUPABASE_URL') ?? '';
    final supabaseAnonKey = getEnv('SUPABASE_ANON_KEY') ?? '';

    debugPrint('🔍 Sprawdzanie konfiguracji:');
    debugPrint('   URL: ${supabaseUrl.isEmpty ? "❌ BRAK" : "✅ $supabaseUrl"}');
    debugPrint('   Key: ${supabaseAnonKey.isEmpty ? "❌ BRAK" : "✅ ${supabaseAnonKey.length > 20 ? "${supabaseAnonKey.substring(0, 20)}..." : "***"}"}');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint('❌ Supabase nie zostanie zainicjalizowany – aplikacja uruchomi się bez logowania (Welcome).');
      if (!kDebugMode) {
        debugPrint('   Dodaj SUPABASE_URL i SUPABASE_ANON_KEY do .env (lub assets/.env na webie).');
      }
      return;
    }

    debugPrint('🔄 Inicjalizacja Supabase...');

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          // Na webie natywny localStorage przeglądarki – code_verifier przetrwa przeładowanie po powrocie z Google.
          pkceAsyncStorage: pkce_storage.getPkceStorageForWeb(),
          // Na webie false – wymianę ?code= robi tylko tryProcessInitialAuthLink (jak na localhost, gdzie działa).
          detectSessionInUri: false,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      _initialized = true;
      debugPrint('✅ Supabase zainicjalizowane pomyślnie');

      if (kIsWeb) {
        final origin = (Uri.base.origin).trim();
        if (origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) {
          final redirectUrl = origin.endsWith('/') ? origin : '$origin/';
          debugPrint('📍 LOCALHOST – logowanie Google:');
          debugPrint('   1) Uruchom z ustalonym portem: flutter run -d chrome --web-port=8080');
          debugPrint('   2) W Supabase → Auth → URL Configuration → Redirect URLs dodaj: $redirectUrl');
          debugPrint('   3) Otwórz w przeglądarce dokładnie ten adres (ze slashem) i loguj w TEJ SAMEJ karcie.');
        }
      }

      try {
        final currentSession = Supabase.instance.client.auth.currentSession;
        debugPrint('✅ Test połączenia: ${currentSession != null ? "OK - sesja aktywna" : "Brak sesji (to normalne)"}');
      } catch (testError) {
        debugPrint('⚠️ Test połączenia nie powiódł się: $testError');
      }
    } catch (e) {
      debugPrint('❌ Błąd inicjalizacji Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => Supabase.instance.client.auth;

  /// Bazowy URL Edge Functions (np. https://xxx.supabase.co/functions/v1).
  /// Używane do wywołań HTTP z tokenem, żeby płatność działała bez 401 od bramki.
  static String get functionsBaseUrl {
    final u = (getEnv('SUPABASE_URL') ?? '').trim();
    final base = u.endsWith('/') ? u.substring(0, u.length - 1) : u;
    return '$base/functions/v1';
  }
}
