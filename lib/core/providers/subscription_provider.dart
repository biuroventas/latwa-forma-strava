import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/trial_constants.dart';
import 'profile_provider.dart';

/// Provider zwracający czy użytkownik ma aktywną subskrypcję Premium.
final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(profileProvider).valueOrNull;
  return profile?.isPremium ?? false;
});

/// Data pierwszego użycia aplikacji (dla tego użytkownika na tym urządzeniu).
/// Przy pierwszym odczycie zapisuje bieżący czas, jeśli jeszcze nie zapisano.
/// W razie błędu (np. SharedPreferences) zwraca null – aplikacja nie blokuje się.
final firstUseAtProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  try {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final key = '${trialStartPrefKeyPrefix}$userId';
    final stored = prefs.getInt(key);
    if (stored == null) {
      final now = DateTime.now();
      await prefs.setInt(key, now.millisecondsSinceEpoch);
      return now;
    }
    return DateTime.fromMillisecondsSinceEpoch(stored);
  } catch (_) {
    return null;
  }
});

/// Dostęp do funkcji premium: subskrypcja Premium LUB okres próbny (24 h od pierwszego użycia).
/// Używaj do bramkowania funkcji – w trakcie trialu użytkownik ma pełny dostęp.
/// Gdy firstUseAt ładuje się (np. po wejściu anonima z onboardingu), uznajemy dostęp – unikamy migania „zablokowane”.
final hasPremiumAccessProvider = Provider<bool>((ref) {
  if (ref.watch(isPremiumProvider)) return true;
  final firstUseAsync = ref.watch(firstUseAtProvider);
  if (firstUseAsync.isLoading) return true; // optymistycznie: trial w trakcie ładowania
  final firstUse = firstUseAsync.valueOrNull;
  if (firstUse == null) return false;
  return DateTime.now().difference(firstUse) < trialDuration;
});

/// Czy użytkownik jest w okresie próbnym (nie ma Premium, ale ma jeszcze czas trialu).
final isInTrialProvider = Provider<bool>((ref) {
  if (ref.watch(isPremiumProvider)) return false;
  final firstUse = ref.watch(firstUseAtProvider).valueOrNull;
  if (firstUse == null) return false;
  return DateTime.now().difference(firstUse) < trialDuration;
});
