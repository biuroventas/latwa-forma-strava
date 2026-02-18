import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/supabase_config.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/services/supabase_service.dart';

/// Provider profilu użytkownika (z Supabase). Cache’owany przez Riverpod.
final profileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) return null;

  final service = SupabaseService();
  return await service.getProfile(userId);
});
