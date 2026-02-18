import 'package:flutter/foundation.dart';
import '../../shared/services/supabase_service.dart';

class StreakUpdater {
  static Future<void> updateStreak(String userId, String streakType, DateTime date) async {
    try {
      final service = SupabaseService();
      await service.updateStreak(userId, streakType, date);
    } catch (e) {
      // Ignoruj błędy streak - nie blokuj głównej funkcjonalności
      debugPrint('Błąd aktualizacji streak: $e');
    }
  }
}
