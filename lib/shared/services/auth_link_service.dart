import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/app_constants.dart';

/// Adres przekierowania po OAuth (Safari / mobile) – schemat latwaforma.
const String _oauthRedirectUrl = 'latwaforma://auth/callback';

/// Na webie przekierowanie musi być na URL strony (app.latwaforma.pl).
String get _redirectUrl =>
    kIsWeb ? AppConstants.webAuthRedirectUrl : _oauthRedirectUrl;

/// Dla magic link (e-mail) używamy HTTPS – klienty e-mail nie obsługują custom scheme.
/// Strona HTTPS przekierowuje na latwaforma://auth/callback.
String get _emailRedirectUrl {
  final url = dotenv.env['EMAIL_AUTH_REDIRECT_URL']?.trim();
  return (url != null && url.isNotEmpty) ? url : _oauthRedirectUrl;
}

/// Serwis do łączenia konta anonimowego z providerami (Google, Email).
/// Google przez przeglądarkę (natywny powodował crash na iOS).
class AuthLinkService {
  static final AuthLinkService _instance = AuthLinkService._();
  factory AuthLinkService() => _instance;
  AuthLinkService._();

  final _auth = SupabaseConfig.auth;

  /// Logowanie przez Google (dla użytkowników wracających – bez anonimowego konta).
  /// externalApplication – Safari. inAppWebView i inAppBrowserView na iOS pokazują pustą stronę.
  Future<AuthLinkResult> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      );
      return AuthLinkResult.success(
        message: kIsWeb
            ? 'Zostaniesz przekierowany do Google. Po zalogowaniu wrócisz tutaj.'
            : 'Otwieram Safari. Zaloguj się i wróć do aplikacji (może pojawić się pytanie „Otwórz w Latwa Forma?”).',
      );
    } catch (e, st) {
      debugPrint('signInWithGoogle error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('cancel') || msg.contains('User cancelled')) {
        return AuthLinkResult.canceled();
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Weryfikuje kod z maila (format zależy od szablonu Supabase – 6 lub więcej znaków).
  Future<AuthLinkResult> verifyEmailOtp(String email, String token) async {
    final trimmed = email.trim();
    final code = token.trim().replaceAll(RegExp(r'\s'), '');
    if (code.length < 6) {
      return AuthLinkResult.error('Wpisz pełny kod z maila.');
    }
    try {
      await _auth.verifyOTP(
        email: trimmed,
        token: code,
        type: OtpType.email,
      );
      return AuthLinkResult.success(message: 'Zalogowano pomyślnie!');
    } catch (e, st) {
      debugPrint('verifyEmailOtp error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('expired') || msg.contains('invalid')) {
        return AuthLinkResult.error('Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.');
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Logowanie przez magic link na email.
  /// Mail zawiera link I 6-cyfrowy kod (jeśli szablon w Supabase ma {{ .Token }}).
  Future<AuthLinkResult> signInWithEmail(String email) async {
    if (email.trim().isEmpty) {
      return AuthLinkResult.error('Podaj adres email');
    }
    final trimmed = email.trim();
    if (!_isValidEmail(trimmed)) {
      return AuthLinkResult.error('Nieprawidłowy format email');
    }
    try {
      await _auth.signInWithOtp(
        email: trimmed,
        emailRedirectTo: kIsWeb ? _redirectUrl : _emailRedirectUrl,
      );
      return AuthLinkResult.success(
        message: 'Wysłaliśmy link i kod na $trimmed. Sprawdź skrzynkę (także folder Spam) – kliknij link lub wpisz kod w aplikacji.',
      );
    } catch (e, st) {
      debugPrint('signInWithEmail error: $e\n$st');
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Łączy konto anonimowe z Google. Obecnie przez przeglądarkę (natywny powodował crash na iOS).
  Future<AuthLinkResult> linkWithGoogle() async {
    return linkWithGoogleViaBrowser();
  }

  /// Łączy konto przez przeglądarkę (OAuth).
  /// externalApplication – Safari; wbudowane widoki pokazują pustą stronę na iOS.
  Future<AuthLinkResult> linkWithGoogleViaBrowser() async {
    try {
      await _auth.linkIdentity(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      );
      return AuthLinkResult.success(
        message: 'Otwieram Safari. Zaloguj się i wróć do aplikacji.',
      );
    } catch (e, st) {
      debugPrint('linkWithGoogle (browser) error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('cancel') || msg.contains('User cancelled')) {
        return AuthLinkResult.canceled();
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Łączy konto anonimowe z emailem (magic link).
  /// Wysyła link weryfikacyjny na podany adres.
  Future<AuthLinkResult> linkWithEmail(String email) async {
    if (email.trim().isEmpty) {
      return AuthLinkResult.error('Podaj adres email');
    }
    final trimmed = email.trim();
    if (!_isValidEmail(trimmed)) {
      return AuthLinkResult.error('Nieprawidłowy format email');
    }

    try {
      await _auth.updateUser(
        UserAttributes(email: trimmed),
        emailRedirectTo: _emailRedirectUrl,
      );
      return AuthLinkResult.success(
        message: 'Wysłaliśmy link i kod na $trimmed. Sprawdź skrzynkę (także folder Spam) – kliknij link lub wpisz kod w aplikacji.',
      );
    } catch (e, st) {
      debugPrint('linkWithEmail error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('already been registered') || msg.contains('email address has already')) {
        return AuthLinkResult.error(
          'Ten adres e-mail jest już zarejestrowany. Zaloguj się linkiem z maila (sprawdź spam).',
          suggestSignOutAndLogin: true,
        );
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  String _formatError(Object e) {
    final s = e.toString();
    if (s.contains('Identity is already linked')) {
      return 'To konto jest już połączone z innym użytkownikiem.';
    }
    if (s.contains('manual_linking_disabled') || s.contains('Manual linking is disabled')) {
      return 'Łączenie kont wymaga włączenia w Supabase. Włącz "Manual linking" w Authentication → Providers.';
    }
    if (s.contains('network') || s.contains('connection') || s.contains('SocketException')) {
      return 'Błąd połączenia. Sprawdź internet.';
    }
    if (s.contains('rate limit') || s.contains('rate_limit') || s.contains('429')) {
      return 'Zbyt dużo prób logowania. Spróbuj za godzinę.';
    }
    if (s.contains('Invalid email') || s.contains('invalid_email')) {
      return 'Nieprawidłowy adres email.';
    }
    if (s.contains('Email rate limit') || s.contains('email_not_confirmed')) {
      return 'Zbyt wiele wiadomości na ten adres. Sprawdź skrzynkę lub spróbuj za chwilę.';
    }
    return 'Błąd: ${s.length > 80 ? '${s.substring(0, 80)}...' : s}';
  }

  bool _isValidEmail(String email) {
    // TLD 2+ znaki (np. .pl, .museum, .travel)
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }
}

/// Wynik próby łączenia konta.
class AuthLinkResult {
  const AuthLinkResult._({
    this.success = false,
    this.canceled = false,
    this.errorMessage,
    this.infoMessage,
    this.suggestTryBrowser = false,
    this.suggestSignOutAndLogin = false,
  });

  factory AuthLinkResult.success({String? message}) => AuthLinkResult._(
        success: true,
        infoMessage: message,
      );
  factory AuthLinkResult.error(String message, {bool suggestTryBrowser = false, bool suggestSignOutAndLogin = false}) =>
      AuthLinkResult._(errorMessage: message, suggestTryBrowser: suggestTryBrowser, suggestSignOutAndLogin: suggestSignOutAndLogin);
  factory AuthLinkResult.canceled() => AuthLinkResult._(canceled: true);

  final bool success;
  final bool canceled;
  final String? errorMessage;
  final String? infoMessage;
  /// Sugeruje wyświetlenie opcji „Spróbuj przez przeglądarkę”.
  final bool suggestTryBrowser;
  /// Sugeruje wylogowanie i przejście do ekranu logowania (email już zarejestrowany).
  final bool suggestSignOutAndLogin;
}
