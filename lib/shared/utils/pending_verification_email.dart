import 'package:shared_preferences/shared_preferences.dart';

const String _key = 'pending_verification_email';

/// Zapisuje adres email po wysłaniu linku/kodu, żeby przy „Mam już kod” od razu pokazać okno z polem na kod.
Future<void> savePendingVerificationEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, email.trim());
}

/// Pobiera zapisany email (gdy użytkownik wraca, żeby wpisać kod).
Future<String?> getPendingVerificationEmail() async {
  final prefs = await SharedPreferences.getInstance();
  final e = prefs.getString(_key);
  return e != null && e.isNotEmpty ? e : null;
}

/// Czyści po udanej weryfikacji.
Future<void> clearPendingVerificationEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_key);
}
