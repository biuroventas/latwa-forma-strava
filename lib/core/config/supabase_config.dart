import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static bool _initialized = false;

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
        // Na webie najpierw pobierz env.production z serwera (plik w build/web) – niezawodne.
        try {
          final url = Uri.base.resolve('/env.production');
          final response = await http.get(url).timeout(
                const Duration(seconds: 5),
                onTimeout: () => http.Response('', 408),
              );
          if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
            final map = _parseEnv(response.body);
            if (map.isNotEmpty) {
              await dotenv.load(
                fileName: '.env',
                mergeWith: map,
                isOptional: true,
              );
              debugPrint('✅ env.production załadowany z serwera (web)');
            }
          }
        } catch (_) {}
        // Jeśli fetch nie dał danych, fallback na asset
        if (dotenv.env['SUPABASE_URL']?.trim().isEmpty ?? true) {
          try {
            await dotenv.load(fileName: 'assets/env.production');
            debugPrint('✅ env.production z assets (web)');
          } catch (__) {
            try {
              await dotenv.load(fileName: 'env.production');
              debugPrint('✅ env.production z root (web)');
            } catch (___) {
              try {
                await dotenv.load(fileName: '.env', isOptional: true);
              } catch (____) {}
            }
          }
        }
      } else {
        await dotenv.load(fileName: '.env');
        debugPrint('✅ .env załadowany z głównego folderu');
      }
    } catch (e) {
      debugPrint('⚠️ Błąd ładowania env: $e');
      try {
        if (kIsWeb) {
          await dotenv.load(fileName: 'assets/env.production', isOptional: true);
        } else {
          await dotenv.load(fileName: 'assets/.env', isOptional: true);
        }
        debugPrint('✅ env załadowany z alternatywnej lokalizacji');
      } catch (e2) {
        debugPrint('❌ Błąd ładowania env: $e2');
        if (kDebugMode) {
          debugPrint('⚠️ Używanie wartości domyślnych (tylko dla testów)');
        }
      }
    }

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

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
          // Na webie false – wymianę ?code= robimy sami w main()/splashu (tryProcessInitialAuthLink),
          // żeby wyjątki były łapane i nie było „Uncaught Error” w konsoli.
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
          debugPrint('📍 Lokalne (Chrome): dla logowania Google dodaj w Supabase → Auth → URL Configuration → Redirect URLs:');
          debugPrint('   $origin');
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
    final u = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    final base = u.endsWith('/') ? u.substring(0, u.length - 1) : u;
    return '$base/functions/v1';
  }
}
