import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_callback_handler.dart';
import '../../../core/auth/sign_out_guard.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/supabase_service.dart';

/// Maksymalny czas oczekiwania na Supabase (getUser / getProfile) – po przekroczeniu przechodzimy na welcome.
const _splashTimeout = Duration(seconds: 8);
/// Maksymalny czas całego splashu – po tym zawsze przechodzimy dalej (na welcome).
const _splashMaxTime = Duration(seconds: 12);
/// Po tym czasie pokazujemy przycisk „Przerwij” (logowanie Google bywa wolne).
const _splashShowSkipAfter = Duration(seconds: 3);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  bool _navigateDone = false;
  DateTime? _splashStartedAt;
  bool _showSkipButton = false;

  @override
  void initState() {
    super.initState();
    _splashStartedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _navigateToNext();
    Future<void>.delayed(_splashShowSkipAfter, () {
      if (!_navigateDone && mounted) setState(() => _showSkipButton = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_navigateDone || !mounted) return;
    final elapsed = _splashStartedAt != null
        ? DateTime.now().difference(_splashStartedAt!)
        : Duration.zero;
    if (elapsed > _splashMaxTime) {
      _navigateDone = true;
      debugPrint('Splash: app resumed after ${elapsed.inSeconds}s – przechodzę na welcome');
      context.go(AppRoutes.welcome);
    }
  }

  Future<void> _navigateToNext() async {
    // Zabezpieczenie: po _splashMaxTime zawsze idź na welcome
    Future<void>.delayed(_splashMaxTime, () {
      if (!_navigateDone && mounted) {
        _navigateDone = true;
        debugPrint('Splash: max time reached – przechodzę na welcome');
        context.go(AppRoutes.welcome);
      }
    });

    const minDisplayTime = Duration(milliseconds: 800);
    final stopwatch = Stopwatch()..start();

    try {
      if (!SupabaseConfig.isInitialized) {
        debugPrint('Splash: Supabase nie zainicjalizowany – przechodzę na welcome');
        await Future.delayed(minDisplayTime);
        if (!mounted) return;
        _navigateDone = true;
        context.go(AppRoutes.welcome);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brak połączenia z serwerem. Sprawdź konfigurację (.env) i internet.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      var user = SupabaseConfig.auth.currentUser;
      var userId = user?.id;

      // Na iOS cold start z „Otwórz w Latwa Forma” link bywa dostępny dopiero tutaj.
      // Z timeoutem, żeby przy ?code= z Google ekran nie wisiał w nieskończoność.
      if (userId == null) {
        final sessionSet = await tryProcessInitialAuthLink()
            .timeout(const Duration(seconds: 5), onTimeout: () => false);
        if (sessionSet && mounted) {
          user = SupabaseConfig.auth.currentUser;
          userId = user?.id;
        }
      }

      if (userId != null) {
        // Zweryfikuj sesję – z limitem czasu, żeby aplikacja nie wisiała przy słabym sieci
        try {
          await SupabaseConfig.auth.getUser().timeout(
            _splashTimeout,
            onTimeout: () => throw TimeoutException('getUser'),
          );
        } on TimeoutException {
          debugPrint('Splash: timeout getUser – przechodzę na welcome');
          if (!mounted) return;
          _navigateDone = true;
          final elapsed = stopwatch.elapsed;
          if (elapsed < minDisplayTime) await Future.delayed(minDisplayTime - elapsed);
          if (!mounted) return;
          context.go(AppRoutes.welcome);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brak połączenia. Sprawdź internet i spróbuj ponownie.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        } on Object {
          // Sesja nieważna (np. użytkownik usunięty) – wyloguj i przejdź na start
          await SupabaseConfig.auth.signOut();
          await markSignOut();
          if (!mounted) return;
          _navigateDone = true;
          final elapsed = stopwatch.elapsed;
          if (elapsed < minDisplayTime) await Future.delayed(minDisplayTime - elapsed);
          if (!mounted) return;
          context.go(AppRoutes.welcome);
          return;
        }

        UserProfile? profile;
        try {
          final service = SupabaseService();
          profile = await service.getProfile(userId).timeout(
            _splashTimeout,
            onTimeout: () => throw TimeoutException('getProfile'),
          );
        } on TimeoutException {
          debugPrint('Splash: timeout getProfile – przechodzę na welcome');
          if (!mounted) return;
          _navigateDone = true;
          final elapsed = stopwatch.elapsed;
          if (elapsed < minDisplayTime) await Future.delayed(minDisplayTime - elapsed);
          if (!mounted) return;
          context.go(AppRoutes.welcome);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brak połączenia. Sprawdź internet i spróbuj ponownie.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        if (!mounted) return;

        final elapsed = stopwatch.elapsed;
        if (elapsed < minDisplayTime) {
          await Future.delayed(minDisplayTime - elapsed);
        }
        if (!mounted) return;

        if (profile != null) {
          if (!mounted) return;
          _navigateDone = true;
          context.go(AppRoutes.dashboard);
          return;
        }

        _navigateDone = true;
        context.go(AppRoutes.onboarding);
        return;
      }

      await Future.delayed(minDisplayTime);
      if (!mounted) return;
      _navigateDone = true;
      context.go(AppRoutes.welcome);
      if (mounted) _showWelcomeSnackBarIfGoogleFailed(context);
    } catch (e) {
      debugPrint('Błąd podczas sprawdzania profilu: $e');
      if (!mounted) return;
      _navigateDone = true;
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDisplayTime) await Future.delayed(minDisplayTime - elapsed);
      if (!mounted) return;
      context.go(AppRoutes.welcome);
      if (mounted) {
        if (!lastGoogleCallbackFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nie udało się zalogować. Uzupełnij profil lub spróbuj zalogować się ponownie.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          _showWelcomeSnackBarIfGoogleFailed(context);
        }
      }
    }
  }

  void _showWelcomeSnackBarIfGoogleFailed(BuildContext context) {
    if (!lastGoogleCallbackFailed) return;
    clearLastGoogleCallbackFailed();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Logowanie Google nie powiodło się. Zaloguj się ponownie w tej samej karcie.',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    // Bez własnego AppBackground – tło daje ShellRoute (jednolite z resztą aplikacji).
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/logo400x400.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.fitness_center, size: 60, color: Color(0xFF4CAF50)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
            if (_showSkipButton) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  if (_navigateDone) return;
                  _navigateDone = true;
                  context.go(AppRoutes.welcome);
                },
                icon: Icon(Icons.close, color: primary, size: 20),
                label: Text(
                  'Przerwij',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
