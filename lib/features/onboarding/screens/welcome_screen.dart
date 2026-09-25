import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/auth/auth_callback_handler.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/auth_link_service.dart';
import '../../../shared/utils/pending_verification_email.dart';
import 'easy_forma_onboarding.dart';

/// Na webie po powrocie z Google w URL może być hash z tokenami – rozpoznajemy to
/// w [auth_callback_handler]. Jeśli z jakiegoś powodu main() nie przetworzył callbacku,
/// ten wrapper przy pierwszym wyświetleniu Welcome próbuje ustawić sesję z URL i przejść do splash.
class _WelcomeAuthRecovery extends StatefulWidget {
  const _WelcomeAuthRecovery({required this.child});
  final Widget child;

  @override
  State<_WelcomeAuthRecovery> createState() => _WelcomeAuthRecoveryState();
}

class _WelcomeAuthRecoveryState extends State<_WelcomeAuthRecovery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryRecoverSessionFromUrl());
  }

  Future<void> _tryRecoverSessionFromUrl() async {
    if (!mounted || !kIsWeb || !SupabaseConfig.isInitialized) return;
    if (!isAuthCallbackUri(Uri.base)) return;
    try {
      await handleAuthCallbackUri(Uri.base);
    } catch (_) {}
    if (!mounted) return;
    final user = SupabaseConfig.auth.currentUser;
    if (user != null && !user.isAnonymous) {
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _markWelcomeAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
  }

  Future<AuthLinkResult> _signInWithGoogleTimed() async {
    try {
      return await AuthLinkService().signInWithGoogle().timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw TimeoutException('OAuth'),
      );
    } on TimeoutException {
      // Okno logowania już zamknięte — użytkownik jest w aplikacji.
      return AuthLinkResult.canceled();
    }
  }

  Future<void> _onApple(BuildContext context) async {
    await _runSignIn(context, () => AuthLinkService().signInWithApple());
  }

  Future<void> _onGoogle(BuildContext context) async {
    await _runSignIn(context, _signInWithGoogleTimed);
  }

  Future<void> _onCreateAccount(BuildContext context) async {
    final result = await _showEmailDialog(context);
    if (!context.mounted) return;
    if (result == null) return;
    if (result.enterCode) {
      if (result.email != null && result.email!.isNotEmpty) {
        await savePendingVerificationEmail(result.email!);
      }
      if (!context.mounted) return;
      await _showEnterCodeDialog(context);
      return;
    }
    if (result.email != null) {
      await savePendingVerificationEmail(result.email!);
      if (!context.mounted) return;
      await _runSignInWithEmail(context, result.email!);
    }
  }

  /// Zwraca: (enterCode: true, email?) = mam już kod (email z pola, jeśli wpisany);
  /// (enterCode: false, email) = wyślij link i kod; null = anuluj.
  Future<({bool enterCode, String? email})?> _showEmailDialog(BuildContext context) {
    return showModalBottomSheet<({bool enterCode, String? email})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => const _EmailSignupSheet(),
    );
  }

  Future<void> _runSignInWithEmail(BuildContext context, String email) async {
    if (!context.mounted) return;
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.onbSendingLinkAndCode),
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
          title: Text(ctx.l10n.commonWarning),
          content: Text(result.errorMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ctx.l10n.commonOk),
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
            title: Text(ctx.l10n.onbSignedIn),
            content: Text(result.infoMessage ?? ctx.l10n.onbSignedInSuccess),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(ctx.l10n.commonOk),
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
      final l10n = context.l10n;
      await _showLinkAndCodeDialog(
        context,
        savedEmail,
        l10n.onbEnterCodeReceived(email: savedEmail),
        dialogTitle: l10n.onbEnterCodeFromEmailTitle,
      );
      return;
    }
    if (!context.mounted) return;
    await _onEnterCode(context);
  }

  /// Gdy użytkownik zamknął okno lub wyłączył aplikację przed wpisaniem kodu – od razu okno do wpisania kodu.
  Future<void> _onEnterCode(BuildContext context) async {
    final savedEmail = await getPendingVerificationEmail();
    if (!context.mounted) return;
    final l10n = context.l10n;
    final String email;
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email = savedEmail;
    } else {
      final entered = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final dialogL10n = ctx.l10n;
          final controller = TextEditingController();
          return AlertDialog(
            title: Text(dialogL10n.onbEnterEmailTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dialogL10n.onbEnterEmailWhichAddress,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: dialogL10n.onbEmailAddressLabel,
                    hintText: dialogL10n.onbEmailAddressHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(dialogL10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final e = controller.text.trim();
                  if (e.isEmpty) return;
                  Navigator.of(ctx).pop(e);
                },
                child: Text(dialogL10n.commonContinue),
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
      savedEmail != null
          ? l10n.onbCodeSentTo(email: email)
          : l10n.onbEnterCodeReceived(email: email),
      dialogTitle: l10n.onbEnterCodeFromEmailTitle,
    );
  }

  /// Jedno okienko: komunikat „wysłaliśmy link i kod” + pole do wpisania kodu (żeby było widać, gdzie go podać).
  Future<void> _showLinkAndCodeDialog(
    BuildContext context,
    String email,
    String? infoMessage, {
    String? dialogTitle,
  }) async {
    final l10n = context.l10n;
    final title = dialogTitle ?? l10n.onbCheckInbox;
    final codeController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                infoMessage ??
                    l10n.onbSentLinkAndCode(email: email),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onbEnterCodeFromEmailLabel,
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
                decoration: InputDecoration(
                  labelText: l10n.onbEmailCodeLabel,
                  hintText: l10n.onbEmailCodeHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
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
                    title: Text(ctx.l10n.onbSignedIn),
                    content: Text(ctx.l10n.onbSignedInSuccess),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(ctx.l10n.commonOk),
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
                    title: Text(ctx.l10n.commonWarning),
                    content: Text(verifyResult.errorMessage!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(ctx.l10n.commonOk),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          if (!context.mounted) return;
                          await _runSignInWithEmail(context, email);
                        },
                        child: Text(ctx.l10n.onbResend),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(l10n.onbSignIn),
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
      final l10n = context.l10n;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.onbSendingLinkAndCode),
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

    if (result.canceled || result.redirected) return;
    if (result.errorMessage != null) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.commonWarning),
          content: Text(result.errorMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ctx.l10n.commonOk),
            ),
          ],
        ),
      );
      return;
    }
    // Nie pokazuj dialogu „Sukces” dla logowania OAuth – użytkownik wraca z przeglądarki sam.
    final isOAuthRedirectMessage = result.infoMessage != null &&
        (result.infoMessage!.contains('Safari') ||
            result.infoMessage!.contains('Otwieram') ||
            result.infoMessage!.contains('Zostaniesz przekierowany'));
    if (result.success && result.infoMessage != null && !isOAuthRedirectMessage) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.onbSuccess),
          content: Text(result.infoMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ctx.l10n.commonOk),
            ),
          ],
        ),
      );
    }
    if (result.success) {
      // Na webie po powrocie z Google callback może być w URL – odczytaj sesję i przejdź do splash.
      if (kIsWeb && isAuthCallbackUri(Uri.base)) {
        try {
          await handleAuthCallbackUri(Uri.base);
        } catch (_) {}
      }
      if (context.mounted && SupabaseConfig.auth.currentUser != null &&
          !SupabaseConfig.auth.currentUser!.isAnonymous) {
        context.go(AppRoutes.splash);
      }
    }
  }

  Future<void> _showOnboardingIntroDialog(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final primary = theme.colorScheme.primary;
        final l10n = ctx.l10n;
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
                l10n.onbIntroTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onbIntroBody,
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
                    l10n.onbIntroDuration,
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
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(l10n.onbIntroStart),
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
          if (!context.mounted) return;
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
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.onbAnonErrorTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isInitialized)
                  Text(l10n.onbAnonErrorNoConfig)
                else if (timeout)
                  Text(l10n.onbAnonErrorTimeout)
                else
                  Text(l10n.onbAnonErrorFailed),
                const SizedBox(height: 12),
                Text(l10n.onbAnonErrorTipDomain),
                const SizedBox(height: 8),
                Text(l10n.onbAnonErrorTipRefresh),
                const SizedBox(height: 8),
                Text(l10n.onbAnonErrorTipLogin),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonClose),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchUrl(Uri.parse(AppConstants.webAuthRedirectUrl), mode: LaunchMode.externalApplication);
              },
              child: Text(l10n.onbOpenLatwaForma),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _onCreateAccount(context);
              },
              child: Text(l10n.onbLoginOrCreateShort),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _WelcomeAuthRecovery(
      child: EasyFormaOnboardingScreen(
        onApple: () => _onApple(context),
        onGoogle: () => _onGoogle(context),
        onCreateAccount: () => _onCreateAccount(context),
        onStartWithoutAccount: () => _showOnboardingIntroDialog(context),
        onEnterCode: null,
      ),
    );
  }
}

class _EmailSignupSheet extends StatefulWidget {
  const _EmailSignupSheet();

  @override
  State<_EmailSignupSheet> createState() => _EmailSignupSheetState();
}

class _EmailSignupSheetState extends State<_EmailSignupSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = context.l10n.onbEnterEmailRequired);
      return;
    }
    Navigator.of(context).pop((enterCode: false, email: email));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onbCreateAccountEmail,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onbEmailSignupBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.onbEmailAddressLabelAlt,
              hintText: l10n.onbEmailAddressHint,
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: Text(l10n.onbSendLinkAndCode),
          ),
          TextButton(
            onPressed: () {
              final email = _controller.text.trim();
              Navigator.of(context).pop((
                enterCode: true,
                email: email.isEmpty ? null : email,
              ));
            },
            child: Text(l10n.onbAlreadyHaveCode),
          ),
        ],
      ),
    );
  }
}
