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
const _splashTimeout = Duration(seconds: 10);
/// Maksymalny czas całego splashu – po tym zawsze przechodzimy dalej (na welcome).
const _splashMaxTime = Duration(seconds: 12);
/// Po tym czasie pokazujemy przycisk „Przerwij”, żeby użytkownik mógł wyjść z ładowania.
const _splashShowSkipAfter = Duration(seconds: 5);

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
      if (userId == null) {
        final sessionSet = await tryProcessInitialAuthLink();
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
    } catch (e) {
      debugPrint('Błąd podczas sprawdzania profilu: $e');
      if (!mounted) return;
      _navigateDone = true;
      final elapsed = stopwatch.elapsed;
      if (elapsed < minDisplayTime) await Future.delayed(minDisplayTime - elapsed);
      if (!mounted) return;
      context.go(AppRoutes.welcome);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nie udało się zalogować. Uzupełnij profil lub spróbuj zalogować się ponownie.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder dla logo - później zastąpimy prawdziwym logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Łatwa Forma',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            if (_showSkipButton) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  if (_navigateDone) return;
                  _navigateDone = true;
                  context.go(AppRoutes.welcome);
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                label: const Text(
                  'Przerwij',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
