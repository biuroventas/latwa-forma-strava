import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'core/auth/auth_callback_handler.dart';
import 'core/config/supabase_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/guest/guest_trial.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'core/utils/store_screenshot_seed.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/revenuecat_service.dart';
import 'shared/widgets/save_progress_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // deploy z Gita – push uruchomi build na Netlify

  // Na webie krótki timeout, żeby ekran nie wisiał w szarości – runApp() jak najszybciej.
  final initTimeout = kIsWeb ? const Duration(seconds: 4) : const Duration(seconds: 10);

  if (!kIsWeb && !kStoreScreenshots) {
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

  if (!kIsWeb && SupabaseConfig.isInitialized) {
    try {
      await RevenueCatService.instance.initialize()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      SupabaseConfig.auth.onAuthStateChange.listen((data) async {
        final user = data.session?.user;
        if (user != null && !user.isAnonymous) {
          await RevenueCatService.instance.logIn(user.id);
        } else if (data.event == AuthChangeEvent.signedOut) {
          await RevenueCatService.instance.logOut();
        }
      });
    } catch (e) {
      debugPrint('⚠️ RevenueCat / auth sync: $e');
    }
  }

  // Na webie wymiana ?code= z Google przed runApp() (wbudowany handler + nasz tryProcessInitialAuthLink).
  try {
    final authTimeout = kIsWeb ? const Duration(seconds: 10) : const Duration(seconds: 6);
    await tryProcessInitialAuthLink().timeout(authTimeout, onTimeout: () => false);
  } catch (_) {}

  await seedStoreScreenshotsIfEnabled();
  await loadSavedAppLocale();

  runApp(
    const ProviderScope(
      child: LatwaFormaApp(),
    ),
  );
}

class LatwaFormaApp extends ConsumerStatefulWidget {
  const LatwaFormaApp({super.key});

  @override
  ConsumerState<LatwaFormaApp> createState() => _LatwaFormaAppState();
}

bool _onboardingSvgPrecached = false;

void _precacheOnboardingSvg(BuildContext context) {
  if (_onboardingSvgPrecached) return;
  _onboardingSvgPrecached = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final loader = SvgAssetLoader('assets/images/grafika2.svg');
      svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    } catch (_) {}
  });
}

class _LatwaFormaAppState extends ConsumerState<LatwaFormaApp> {
  StreamSubscription<Uri>? _linkSub;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter();
    GuestTrial.requestContinue = () async {
      final ctx = appNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return false;
      final l10n = AppLocalizations.of(ctx);
      await SaveProgressChecker.showSaveProgressModal(
        ctx,
        mealsCount: 0,
        allowDismiss: false,
        titleText: l10n.guestTrialEndedTitle,
        bodyText: l10n.guestTrialEndedBody,
      );
      final user = SupabaseConfig.currentUserOrNull;
      return user != null && !user.isAnonymous;
    };
    try {
      _linkSub = AppLinks().uriLinkStream.listen((Uri uri) {
        if (isAuthCallbackUri(uri)) handleAuthCallbackUri(uri);
      });
      // Wymiana ?code= z Google odbywa się na splashu (jedno miejsce), nie tutaj.
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
    final savedLocale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: savedLocale,
      localeResolutionCallback: (device, _) => resolveDeviceLocale(device),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
      builder: (context, child) {
        if (kIsWeb) _precacheOnboardingSvg(context);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
