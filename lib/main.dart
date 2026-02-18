import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/auth_callback_handler.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // deploy z Gita – push uruchomi build na Netlify

  // Na webie krótki timeout, żeby ekran nie wisiał w szarości – runApp() jak najszybciej.
  final initTimeout = kIsWeb ? const Duration(seconds: 4) : const Duration(seconds: 10);

  if (!kIsWeb) {
    try {
      await NotificationService.initialize()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      debugPrint('✅ Powiadomienia zainicjalizowane pomyślnie');
    } catch (e) {
      debugPrint('⚠️ Błąd inicjalizacji powiadomień: $e');
    }
  }

  try {
    await SupabaseConfig.initialize().timeout(initTimeout, onTimeout: () {
      debugPrint('⚠️ Timeout inicjalizacji Supabase – uruchamiam aplikację');
    });
    debugPrint('✅ Supabase zainicjalizowane pomyślnie');
  } catch (e, stackTrace) {
    debugPrint('❌ Błąd inicjalizacji Supabase: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  if (!kIsWeb) {
    try {
      await tryProcessInitialAuthLink()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
    } catch (_) {}
  }

  runApp(
    const ProviderScope(
      child: LatwaFormaApp(),
    ),
  );
}

class LatwaFormaApp extends StatefulWidget {
  const LatwaFormaApp({super.key});

  @override
  State<LatwaFormaApp> createState() => _LatwaFormaAppState();
}

class _LatwaFormaAppState extends State<LatwaFormaApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    try {
      _linkSub = AppLinks().uriLinkStream.listen((Uri uri) {
        if (isAuthCallbackUri(uri)) handleAuthCallbackUri(uri);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        await tryProcessInitialAuthLink();
      });
    } catch (e) {
      debugPrint('⚠️ AppLinks init: $e');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Łatwa Forma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('pl', 'PL'),
      supportedLocales: const [
        Locale('pl', 'PL'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: createAppRouter(),
    );
  }
}
