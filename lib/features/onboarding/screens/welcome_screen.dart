import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/auth_link_service.dart';
import '../../../shared/utils/pending_verification_email.dart';
import 'easy_forma_onboarding.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _markWelcomeAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
  }

  Future<void> _onLogin(BuildContext context) async {
    bool acceptedTerms = false;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Zaloguj lub załóż konto',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masz konto? Zaloguj się. Nowy użytkownik? Załóż konto – Twoje dane będą zapisane.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: acceptedTerms,
                    onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text.rich(
                      TextSpan(
                        style: Theme.of(ctx).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Akceptuję '),
                          TextSpan(
                            text: 'Regulamin',
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openUrl(AppConstants.termsUrl),
                          ),
                          const TextSpan(text: ' i '),
                          TextSpan(
                            text: 'Politykę prywatności',
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openUrl(AppConstants.privacyPolicyUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: acceptedTerms
                        ? () async {
                            Navigator.of(ctx).pop();
                            await _runSignIn(context, () async {
                              try {
                                return await AuthLinkService().signInWithGoogle().timeout(
                                  const Duration(seconds: 90),
                                  onTimeout: () => throw TimeoutException('OAuth'),
                                );
                              } on TimeoutException {
                                return AuthLinkResult.error(
                                  'Logowanie nie zostało dokończone (timeout). Wróć do aplikacji i spróbuj ponownie.',
                                );
                              }
                            });
                          }
                        : null,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Zaloguj przez Google'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: acceptedTerms
                        ? () async {
                            Navigator.of(ctx).pop();
                            final result = await _showEmailDialog(ctx);
                            if (!context.mounted) return;
                            if (result == null) return;
                            if (result.enterCode) {
                              if (result.email != null && result.email!.isNotEmpty) {
                                await savePendingVerificationEmail(result.email!);
                              }
                              await _showEnterCodeDialog(context);
                              return;
                            }
                            if (result.email != null) {
                              await savePendingVerificationEmail(result.email!);
                              await _runSignInWithEmail(context, result.email!);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.email, size: 20),
                    label: const Text('Przez email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Zwraca: (enterCode: true, email?) = mam już kod (email z pola, jeśli wpisany);
  /// (enterCode: false, email) = wyślij link i kod; null = anuluj.
  Future<({bool enterCode, String? email})?> _showEmailDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;
    return showDialog<({bool enterCode, String? email})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Zaloguj lub załóż konto'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Adres email',
              hintText: 'np. jan@example.com',
              helperText: 'Działa do logowania i zakładania konta',
              errorText: errorText,
            ),
            onChanged: (_) {
              if (errorText != null) {
                setState(() => errorText = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                final email = controller.text.trim();
                Navigator.of(ctx).pop((enterCode: true, email: email.isEmpty ? null : email));
              },
              child: Text(
                'Mam już kod',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                final email = controller.text.trim();
                if (email.isEmpty) {
                  setState(() => errorText = 'Podaj adres email');
                  return;
                }
                Navigator.of(ctx).pop((enterCode: false, email: email));
              },
              child: const Text('Wyślij link oraz kod'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runSignInWithEmail(BuildContext context, String email) async {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Wysyłanie linku i kodu...'),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await AuthLinkService().signInWithEmail(email);

    if (!context.mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    if (result.canceled) return;
    if (result.errorMessage != null) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Uwaga'),
          content: Text(result.errorMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (result.success) {
      if (SupabaseConfig.auth.currentUser != null) {
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Zalogowano'),
            content: Text(result.infoMessage ?? 'Zalogowano pomyślnie!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (context.mounted) context.go(AppRoutes.splash);
        return;
      }
      await savePendingVerificationEmail(email);
      if (!context.mounted) return;
      await _showLinkAndCodeDialog(context, email, result.infoMessage);
    }
  }

  /// Pokazuje tylko okno do wpisania kodu (email już zapisany wcześniej, np. z dialogu logowania).
  Future<void> _showEnterCodeDialog(BuildContext context) async {
    final savedEmail = await getPendingVerificationEmail();
    if (savedEmail != null && savedEmail.isNotEmpty && context.mounted) {
      await _showLinkAndCodeDialog(
        context,
        savedEmail,
        'Wpisz poniżej kod, który otrzymałeś na adres $savedEmail.',
        dialogTitle: 'Wpisz kod z maila',
      );
      return;
    }
    await _onEnterCode(context);
  }

  /// Gdy użytkownik zamknął okno lub wyłączył aplikację przed wpisaniem kodu – od razu okno do wpisania kodu.
  Future<void> _onEnterCode(BuildContext context) async {
    final savedEmail = await getPendingVerificationEmail();
    final String email;
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email = savedEmail;
    } else {
      final entered = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Podaj adres email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Na który adres wysłaliśmy link i kod? Podaj go, a następnie wpiszesz kod.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Adres email',
                    hintText: 'np. jan@example.com',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () {
                  final e = controller.text.trim();
                  if (e.isEmpty) return;
                  Navigator.of(ctx).pop(e);
                },
                child: const Text('Dalej'),
              ),
            ],
          );
        },
      );
      if (entered == null || !context.mounted) return;
      await savePendingVerificationEmail(entered);
      email = entered;
    }
    if (!context.mounted) return;
    await _showLinkAndCodeDialog(
      context,
      email,
      savedEmail != null ? 'Kod wysłany na: $email' : 'Wpisz poniżej kod, który otrzymałeś na adres $email.',
      dialogTitle: 'Wpisz kod z maila',
    );
  }

  /// Jedno okienko: komunikat „wysłaliśmy link i kod” + pole do wpisania kodu (żeby było widać, gdzie go podać).
  Future<void> _showLinkAndCodeDialog(
    BuildContext context,
    String email,
    String? infoMessage, {
    String dialogTitle = 'Sprawdź skrzynkę',
  }) async {
    final codeController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                infoMessage ??
                    'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – możesz kliknąć link w mailu lub wpisać kod poniżej.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Wpisz kod z maila:',
                style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Kod z maila',
                  hintText: 'np. 123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zamknij'),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim().replaceAll(RegExp(r'\s'), '');
              if (code.length < 6) return;
              Navigator.of(ctx).pop();
              final verifyResult = await AuthLinkService().verifyEmailOtp(email, code);
              if (!context.mounted) return;
              if (verifyResult.success) {
                await clearPendingVerificationEmail();
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Zalogowano'),
                    content: const Text('Zalogowano pomyślnie!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                context.go(AppRoutes.splash);
              } else if (verifyResult.errorMessage != null) {
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Uwaga'),
                    content: Text(verifyResult.errorMessage!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          if (!context.mounted) return;
                          await _runSignInWithEmail(context, email);
                        },
                        child: const Text('Wyślij ponownie'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Zaloguj'),
          ),
        ],
      ),
    );
  }

  Future<void> _runSignIn(
    BuildContext context,
    Future<AuthLinkResult> Function() signIn, {
    bool showLoading = false,
  }) async {
    if (showLoading && context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Wysyłanie linku i kodu...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final result = await signIn();

    if (!context.mounted) return;
    if (showLoading) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }
    if (!context.mounted) return;

    if (result.canceled) return;
    if (result.errorMessage != null) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Uwaga'),
          content: Text(result.errorMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Nie pokazuj dialogu „Sukces” dla logowania przez Google – komunikat „Otwieram Safari…”
    // jest mylący po powrocie do aplikacji (użytkownik już wrócił).
    final isOAuthSafariMessage = result.infoMessage != null &&
        (result.infoMessage!.contains('Safari') || result.infoMessage!.contains('Otwieram'));
    if (result.success && result.infoMessage != null && !isOAuthSafariMessage) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sukces'),
          content: Text(result.infoMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    if (result.success && SupabaseConfig.auth.currentUser != null) {
      if (context.mounted) context.go(AppRoutes.splash);
    }
  }

  Future<void> _showOnboardingIntroDialog(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final primary = theme.colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 32,
                  color: primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Powiedz nam kilka rzeczy o sobie',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Pokażemy Ci ile jeść każdego dnia,\naby osiągnąć swój cel.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: primary.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Text(
                    'Zajmie mniej niż minutę',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Rozpocznij'),
            ),
          ],
        );
      },
    );
    if (proceed == true && context.mounted) {
      await _onZaczynamy(context);
    }
  }

  /// Na webie klient Flutter czasem nie działa – wywołanie REST API Supabase (Auth) bezpośrednio.
  Future<bool> _signInAnonymouslyViaRest() async {
    final url = dotenv.env['SUPABASE_URL']?.trim();
    final key = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    if (url == null || url.isEmpty || key == null || key.isEmpty) return false;
    try {
      final uri = Uri.parse('$url/auth/v1/signup');
      // Jak w gotrue: POST /signup z data+gotrue_meta_security (bez email/phone/hasła = anonim)
      final res = await http
          .post(
            uri,
            headers: {'apikey': key, 'Content-Type': 'application/json'},
            body: '{"data":{},"gotrue_meta_security":{}}',
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        debugPrint('REST signup anon: ${res.statusCode} ${res.body}');
        return false;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final refreshToken = json['refresh_token'] as String?;
      if (refreshToken == null) return false;
      await SupabaseConfig.auth.setSession(refreshToken);
      return true;
    } catch (e) {
      debugPrint('_signInAnonymouslyViaRest: $e');
      return false;
    }
  }

  Future<void> _onZaczynamy(BuildContext context) async {
    if (!SupabaseConfig.isInitialized) {
      if (context.mounted) _showAnonymousErrorDialog(context, isInitialized: false);
      return;
    }
    const timeout = Duration(seconds: 18);
    const pause = Duration(seconds: 2);
    int attempts = 0;
    const maxAttempts = 3;
    while (attempts < maxAttempts) {
      try {
        attempts++;
        final response = await SupabaseConfig.auth.signInAnonymously()
            .timeout(timeout, onTimeout: () => throw TimeoutException('signInAnonymously'));
        if (response.user == null) throw Exception('Brak użytkownika');
        await _markWelcomeAsSeen();
        if (!context.mounted) return;
        context.go(AppRoutes.onboarding);
        return;
      } on TimeoutException {
        debugPrint('signInAnonymously timeout (próba $attempts/$maxAttempts)');
        if (attempts >= maxAttempts && context.mounted) {
          if (kIsWeb) {
            final ok = await _signInAnonymouslyViaRest();
            if (ok && context.mounted) {
              await _markWelcomeAsSeen();
              if (context.mounted) context.go(AppRoutes.onboarding);
              return;
            }
          }
          _showAnonymousErrorDialog(context, timeout: true);
          return;
        }
        await Future<void>.delayed(pause);
      } catch (e, st) {
        debugPrint('Błąd signInAnonymously (próba $attempts): $e');
        debugPrint('$st');
        if (attempts >= maxAttempts || !context.mounted) {
          if (context.mounted && kIsWeb) {
            final ok = await _signInAnonymouslyViaRest();
            if (ok && context.mounted) {
              await _markWelcomeAsSeen();
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
                return;
              }
            }
          }
          if (context.mounted) _showAnonymousErrorDialog(context, error: e);
          return;
        }
        await Future<void>.delayed(pause);
      }
    }
  }

  void _showAnonymousErrorDialog(BuildContext context, {bool isInitialized = true, bool timeout = false, Object? error}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nie udało się rozpocząć bez konta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isInitialized)
                const Text(
                  'Aplikacja nie ma połączenia z serwerem (brak konfiguracji w buildzie).',
                )
              else if (timeout)
                const Text(
                  'Serwer nie odpowiedział w czasie. Sprawdź internet lub spróbuj później.',
                )
              else
                const Text(
                  'Połączenie z serwerem nie powiodło się. Możesz:',
                ),
              const SizedBox(height: 12),
              const Text('• Upewnij się, że jesteś na adresie latwaforma.pl.'),
              const SizedBox(height: 8),
              const Text('• Odśwież stronę (F5) i spróbuj ponownie.'),
              const SizedBox(height: 8),
              const Text('• Albo zaloguj się przez Google lub email – przyciski powyżej.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zamknij'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              launchUrl(Uri.parse(AppConstants.webAuthRedirectUrl), mode: LaunchMode.externalApplication);
            },
            child: const Text('Otwórz latwaforma.pl'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _onLogin(context);
            },
            child: const Text('Zaloguj przez Google'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyFormaOnboardingScreen(
      onLogin: () => _onLogin(context),
      onStartWithoutAccount: () => _showOnboardingIntroDialog(context),
      onEnterCode: null,
    );
  }
}
