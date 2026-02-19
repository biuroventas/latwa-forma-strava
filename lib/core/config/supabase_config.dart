import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  static Future<void> initialize() async {
    _initialized = false;
    // Na webie pliki z kropką (.env) często 404 – najpierw ładujemy env.production (tworzony na Netlify).
    try {
      if (kIsWeb) {
        try {
          await dotenv.load(fileName: 'env.production');
          debugPrint('✅ env.production załadowany (web)');
        } catch (_) {
          try {
            await dotenv.load(fileName: '.env');
            debugPrint('✅ .env załadowany (web)');
          } catch (__) {
            await dotenv.load(fileName: 'assets/.env');
            debugPrint('✅ .env z assets (web)');
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
          await dotenv.load(fileName: 'assets/env.production');
        } else {
          await dotenv.load(fileName: 'assets/.env');
        }
        debugPrint('✅ env załadowany z alternatywnej lokalizacji');
      } catch (e2) {
        debugPrint('❌ Błąd ładowania env z alternatywnej lokalizacji: $e2');
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
          detectSessionInUri: kIsWeb,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      _initialized = true;
      debugPrint('✅ Supabase zainicjalizowane pomyślnie');

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
}
