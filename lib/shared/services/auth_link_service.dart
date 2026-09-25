import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_callback_handler.dart';
import '../../core/auth/sign_out_guard.dart';
import '../../core/config/supabase_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/platform_stub.dart'
    if (dart.library.io) '../../core/utils/platform_io.dart' as platform;
import 'apple_native_sign_in_stub.dart'
    if (dart.library.io) 'apple_native_sign_in_io.dart' as apple_native;

/// Adres przekierowania po OAuth (Safari / mobile) – schemat latwaforma.
const String _oauthRedirectUrl = 'latwaforma://auth/callback';

/// Na webie ZAWSZE bieżąca origin + slash – żeby powrót z Google był na tę samą domenę
/// (np. latwaforma.pl vs www.latwaforma.pl to inny localStorage). W Supabase dodaj oba w Redirect URLs.
String get _redirectUrl {
  if (!kIsWeb) return _oauthRedirectUrl;
  final origin = Uri.base.origin.trim();
  if (origin.isEmpty) return '${AppConstants.webAuthRedirectUrl.trim()}/';
  return origin.endsWith('/') ? origin : '$origin/';
}

/// Dla magic link (e-mail) używamy HTTPS – klienty e-mail nie obsługują custom scheme.
/// Strona HTTPS przekierowuje na latwaforma://auth/callback.
String get _emailRedirectUrl {
  final url = dotenv.env['EMAIL_AUTH_REDIRECT_URL']?.trim();
  return (url != null && url.isNotEmpty) ? url : _oauthRedirectUrl;
}

/// Serwis do łączenia konta anonimowego z providerami (Google, Apple, Email).
/// Google na iOS: ASWebAuthenticationSession (bez pytania Safari).
class AuthLinkService {
  static final AuthLinkService _instance = AuthLinkService._();
  factory AuthLinkService() => _instance;
  AuthLinkService._();

  final _auth = SupabaseConfig.auth;

  AppLocalizations get _l10n => lookupAppLocalizations(currentAppLocale());

  /// Logowanie przez Google (dla użytkowników wracających – bez anonimowego konta).
  Future<AuthLinkResult> signInWithGoogle() async {
    try {
      await clearSignOutMark();
      if (!kIsWeb && platform.isIOS) {
        return await _oauthViaAuthSession(
          () => _auth.getOAuthSignInUrl(
            provider: OAuthProvider.google,
            redirectTo: _redirectUrl,
            queryParams: const {'prompt': 'select_account'},
          ),
        );
      }
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: _oauthLaunchMode,
        queryParams: const {'prompt': 'select_account'},
      );
      return AuthLinkResult.redirected();
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
      return AuthLinkResult.error(_l10n.authEnterFullCode);
    }
    try {
      await _auth.verifyOTP(
        email: trimmed,
        token: code,
        type: OtpType.email,
      );
      return AuthLinkResult.success(message: _l10n.authSignedIn);
    } catch (e, st) {
      debugPrint('verifyEmailOtp error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('expired') || msg.contains('invalid')) {
        return AuthLinkResult.error(_l10n.authCodeExpired);
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Logowanie przez magic link na email.
  /// Mail zawiera link I 6-cyfrowy kod (jeśli szablon w Supabase ma {{ .Token }}).
  Future<AuthLinkResult> signInWithEmail(String email) async {
    if (email.trim().isEmpty) {
      return AuthLinkResult.error(_l10n.authEnterEmail);
    }
    final trimmed = email.trim();
    if (!_isValidEmail(trimmed)) {
      return AuthLinkResult.error(_l10n.authInvalidEmail);
    }
    try {
      await _auth.signInWithOtp(
        email: trimmed,
        emailRedirectTo: kIsWeb ? _redirectUrl : _emailRedirectUrl,
      );
      return AuthLinkResult.success(
        message: _l10n.authLinkAndCodeSent(email: trimmed),
      );
    } catch (e, st) {
      debugPrint('signInWithEmail error: $e\n$st');
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Logowanie przez Apple: na iOS systemowy arkusz, na Androidzie / webie OAuth.
  Future<AuthLinkResult> signInWithApple() async {
    return _appleAuth(linkIfAnonymous: true);
  }

  /// Łączy konto anonimowe z Apple.
  Future<AuthLinkResult> linkWithApple() async {
    return _appleAuth(linkIfAnonymous: true, forceLink: true);
  }

  Future<AuthLinkResult> _appleAuth({
    required bool linkIfAnonymous,
    bool forceLink = false,
  }) async {
    try {
      await clearSignOutMark();
      try {
        final native = await apple_native.nativeAppleCredential();
        if (native != null) {
          return await _completeAppleIdToken(
            idToken: native.idToken,
            rawNonce: native.rawNonce,
            givenName: native.givenName,
            familyName: native.familyName,
            forceLink: forceLink || (linkIfAnonymous && _isAnonymous),
          );
        }
      } on apple_native.AppleNativeCanceled {
        return AuthLinkResult.canceled();
      }

      final user = _auth.currentUser;
      final shouldLink = forceLink || (linkIfAnonymous && user != null && user.isAnonymous);
      if (shouldLink) {
        await _auth.linkIdentity(
          OAuthProvider.apple,
          redirectTo: _redirectUrl,
          authScreenLaunchMode: _appleOAuthLaunchMode,
        );
      } else {
        await _auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: _redirectUrl,
          authScreenLaunchMode: _appleOAuthLaunchMode,
        );
      }
      return AuthLinkResult.redirected();
    } catch (e, st) {
      debugPrint('Apple auth error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('cancel') || msg.contains('User cancelled')) {
        return AuthLinkResult.canceled();
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  bool get _isAnonymous {
    final user = _auth.currentUser;
    return user != null && user.isAnonymous;
  }

  LaunchMode get _oauthLaunchMode =>
      kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;

  /// iOS: systemowa karta logowania (ASWebAuthenticationSession) – bez „Otwórz w Łatwa Forma?”.
  Future<AuthLinkResult> _oauthViaAuthSession(
    Future<OAuthResponse> Function() getUrl,
  ) async {
    final res = await getUrl();
    final url = res.url;
    if (url.isEmpty) {
      return AuthLinkResult.error(_l10n.authCouldNotStart);
    }
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'latwaforma',
        options: const FlutterWebAuth2Options(
          preferEphemeral: false,
          timeout: 90,
        ),
      );
      await handleAuthCallbackUri(Uri.parse(result));
      return AuthLinkResult.success();
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return AuthLinkResult.canceled();
      return AuthLinkResult.error(_formatError(e));
    }
  }

  /// Android: karta w aplikacji. iOS zapas (gdy brak natywnego arkusza): Safari.
  LaunchMode get _appleOAuthLaunchMode {
    if (kIsWeb) return LaunchMode.platformDefault;
    if (platform.isIOS) return LaunchMode.externalApplication;
    return LaunchMode.inAppBrowserView;
  }

  Future<AuthLinkResult> _completeAppleIdToken({
    required String idToken,
    required String rawNonce,
    String? givenName,
    String? familyName,
    required bool forceLink,
  }) async {
    if (forceLink) {
      await _auth.linkIdentityWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } else {
      await _auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    }
    final name = [givenName, familyName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) {
      try {
        await _auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              if (givenName != null && givenName.trim().isNotEmpty) 'given_name': givenName.trim(),
              if (familyName != null && familyName.trim().isNotEmpty) 'family_name': familyName.trim(),
            },
          ),
        );
      } catch (e) {
        debugPrint('Apple name update skipped: $e');
      }
    }
    return AuthLinkResult.success();
  }

  /// Łączy konto anonimowe z Google. Obecnie przez przeglądarkę (natywny powodował crash na iOS).
  Future<AuthLinkResult> linkWithGoogle() async {
    return linkWithGoogleViaBrowser();
  }

  /// Łączy konto przez przeglądarkę (OAuth). Na iOS: sesja systemowa, bez pytania Safari.
  Future<AuthLinkResult> linkWithGoogleViaBrowser() async {
    try {
      await clearSignOutMark();
      if (!kIsWeb && platform.isIOS) {
        return await _oauthViaAuthSession(
          () => _auth.getLinkIdentityUrl(
            OAuthProvider.google,
            redirectTo: _redirectUrl,
            queryParams: const {'prompt': 'select_account'},
          ),
        );
      }
      await _auth.linkIdentity(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: _oauthLaunchMode,
        queryParams: const {'prompt': 'select_account'},
      );
      return AuthLinkResult.redirected();
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
      return AuthLinkResult.error(_l10n.authEnterEmail);
    }
    final trimmed = email.trim();
    if (!_isValidEmail(trimmed)) {
      return AuthLinkResult.error(_l10n.authInvalidEmail);
    }

    try {
      await _auth.updateUser(
        UserAttributes(email: trimmed),
        emailRedirectTo: _emailRedirectUrl,
      );
      return AuthLinkResult.success(
        message: _l10n.authLinkAndCodeSent(email: trimmed),
      );
    } catch (e, st) {
      debugPrint('linkWithEmail error: $e\n$st');
      final msg = e.toString();
      if (msg.contains('already been registered') || msg.contains('email address has already')) {
        return AuthLinkResult.error(
          _l10n.authEmailTaken,
          suggestSignOutAndLogin: true,
        );
      }
      return AuthLinkResult.error(_formatError(e));
    }
  }

  String _formatError(Object e) {
    final s = e.toString();
    if (s.contains('Identity is already linked')) {
      return _l10n.authAlreadyLinked;
    }
    if (s.contains('manual_linking_disabled') || s.contains('Manual linking is disabled')) {
      return _l10n.authManualLinking;
    }
    if (s.contains('network') || s.contains('connection') || s.contains('SocketException')) {
      return _l10n.authConnection;
    }
    if (s.contains('rate limit') || s.contains('rate_limit') || s.contains('429')) {
      return _l10n.authTooManyAttempts;
    }
    if (s.contains('Invalid email') || s.contains('invalid_email')) {
      return _l10n.authInvalidEmailAddress;
    }
    if (s.contains('Email rate limit') || s.contains('email_not_confirmed')) {
      return _l10n.authTooManyEmails;
    }
    final detail = s.length > 80 ? '${s.substring(0, 80)}...' : s;
    return _l10n.authGenericError(detail: detail);
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
    this.redirected = false,
    this.errorMessage,
    this.infoMessage,
    this.suggestTryBrowser = false,
    this.suggestSignOutAndLogin = false,
  });

  factory AuthLinkResult.success({String? message}) => AuthLinkResult._(
        success: true,
        infoMessage: message,
      );
  factory AuthLinkResult.redirected() => AuthLinkResult._(success: true, redirected: true);
  factory AuthLinkResult.error(String message, {bool suggestTryBrowser = false, bool suggestSignOutAndLogin = false}) =>
      AuthLinkResult._(errorMessage: message, suggestTryBrowser: suggestTryBrowser, suggestSignOutAndLogin: suggestSignOutAndLogin);
  factory AuthLinkResult.canceled() => AuthLinkResult._(canceled: true);

  final bool success;
  final bool canceled;
  /// Przeglądarka otwarta (OAuth) – nie pokazuj dialogu „sukces”.
  final bool redirected;
  final String? errorMessage;
  final String? infoMessage;
  /// Sugeruje wyświetlenie opcji „Spróbuj przez przeglądarkę”.
  final bool suggestTryBrowser;
  /// Sugeruje wylogowanie i przejście do ekranu logowania (email już zarejestrowany).
  final bool suggestSignOutAndLogin;
}
