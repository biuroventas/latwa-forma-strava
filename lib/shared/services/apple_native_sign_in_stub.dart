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

/// Na webie / gdy brak dart:io – zawsze OAuth.
Future<AppleNativeCredential?> nativeAppleCredential() async => null;
