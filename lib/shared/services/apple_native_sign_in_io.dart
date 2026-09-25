import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Wynik natywnego Sign in with Apple (tylko iOS).
class AppleNativeCredential {
  const AppleNativeCredential({
    required this.idToken,
    required this.rawNonce,
    this.givenName,
    this.familyName,
  });

  final String idToken;
  final String rawNonce;
  final String? givenName;
  final String? familyName;
}

class AppleNativeCanceled implements Exception {}

/// Systemowy arkusz Apple na iOS. Na Androidzie `null` → OAuth.
Future<AppleNativeCredential?> nativeAppleCredential() async {
  if (!Platform.isIOS) return null;
  final available = await SignInWithApple.isAvailable();
  if (!available) return null;

  final rawNonce = _generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Brak tokenu Apple');
    }
    return AppleNativeCredential(
      idToken: idToken,
      rawNonce: rawNonce,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  } on SignInWithAppleAuthorizationException catch (e) {
    // Anulowanie arkusza oraz powrót bez zalogowania do Apple ID
    // (symulator zgłasza wtedy „unknown” / błąd 1000, nie „canceled”).
    if (e.code == AuthorizationErrorCode.canceled ||
        e.code == AuthorizationErrorCode.unknown) {
      throw AppleNativeCanceled();
    }
    rethrow;
  }
}

String _generateRawNonce() {
  final random = Random.secure();
  return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
}
