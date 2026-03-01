import '../../core/config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/activity.dart';
import '../models/water_log.dart';
import '../models/weight_log.dart';
import '../models/body_measurement.dart';
import '../models/favorite_meal.dart';
import '../models/favorite_activity.dart';
import '../models/streak.dart';
import '../models/goal_challenge.dart';

class SupabaseService {
  final _client = SupabaseConfig.client;

  // Profile operations
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    var profile = UserProfile.fromJson(response);

    // Synchronizacja wagi z ostatniego loga
    final weightLogs = await getWeightLogs(userId, limit: 1);
    if (weightLogs.isNotEmpty) {
      profile = profile.copyWith(currentWeightKg: weightLogs.first.weightKg);
    }
    return profile;
  }

  Future<UserProfile> createProfile(UserProfile profile) async {
    // Używamy upsert zamiast insert, aby zaktualizować profil jeśli już istnieje
    final response = await _client
        .from('profiles')
        .upsert(
          profile.toJson(),
          onConflict: 'user_id',
        )
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('user_id', profile.userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  Future<void> updateSubscriptionTier(
    String userId, {
    required String tier,
    DateTime? expiresAt,
  }) async {
    await _client.from('profiles').update({
      'subscription_tier': tier,
      if (expiresAt != null) 'subscription_expires_at': expiresAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  // Meal operations
  /// Zwraca liczbę wszystkich posiłków użytkownika (dla modalu „Zapisz postępy”)
  Future<int> getMealsCount(String userId) async {
    final meals = await getMeals(userId); // bez date = wszystkie posiłki
    return meals.length;
  }

  Future<List<Meal>> getMeals(String userId, {DateTime? date}) async {
    var query = _client
        .from('meals')
        .select()
        .eq('user_id', userId);

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Meal.fromJson(json)).toList();
  }

  Future<Meal> createMeal(Meal meal) async {
    final response = await _client
        .from('meals')
        .insert(meal.toJson())
        .select()
        .single();

    return Meal.fromJson(response);
  }

  Future<Meal> updateMeal(Meal meal) async {
    if (meal.id == null) throw Exception('Meal ID is required for update');
    final response = await _client
        .from('meals')
        .update(meal.toJson())
        .eq('id', meal.id!)
        .select()
        .single();

    return Meal.fromJson(response);
  }

  Future<void> deleteMeal(String mealId) async {
    await _client.from('meals').delete().eq('id', mealId);
  }

  // Activity operations
  Future<List<Activity>> getActivities(String userId, {DateTime? date}) async {
    var query = _client
        .from('activities')
        .select('id, user_id, name, calories_burned, duration_minutes, activity_type, created_at, excluded_from_balance')
        .eq('user_id', userId);

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Activity.fromJson(json)).toList();
  }

  Future<Activity> createActivity(Activity activity) async {
    final response = await _client
        .from('activities')
        .insert(activity.toJson())
        .select()
        .single();

    return Activity.fromJson(response);
  }

  Future<Activity> updateActivity(Activity activity) async {
    if (activity.id == null) throw Exception('Activity ID is required for update');
    final response = await _client
        .from('activities')
        .update(activity.toJson())
        .eq('id', activity.id!)
        .select()
        .single();

    return Activity.fromJson(response);
  }

  Future<void> deleteActivity(String activityId) async {
    await _client.from('activities').delete().eq('id', activityId);
  }

  // Water log operations
  Future<List<WaterLog>> getWaterLogs(String userId, {DateTime? date}) async {
    var query = _client
        .from('water_logs')
        .select()
        .eq('user_id', userId);

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => WaterLog.fromJson(json)).toList();
  }

  Future<double> getTotalWaterToday(String userId) async {
    return getTotalWaterForDate(userId, DateTime.now());
  }

  Future<double> getTotalWaterForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('water_logs')
        .select('amount_ml')
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String());

    if (response.isEmpty) return 0.0;

    double total = 0.0;
    for (var item in response) {
      total += (item['amount_ml'] as num).toDouble();
    }
    return total;
  }

  Future<WaterLog> createWaterLog(WaterLog waterLog) async {
    final response = await _client
        .from('water_logs')
        .insert(waterLog.toJson())
        .select()
        .single();

    return WaterLog.fromJson(response);
  }

  Future<WaterLog> updateWaterLog(WaterLog waterLog) async {
    if (waterLog.id == null) throw Exception('WaterLog id is required for update');
    final response = await _client
        .from('water_logs')
        .update({'amount_ml': waterLog.amountMl})
        .eq('id', waterLog.id!)
        .select()
        .single();

    return WaterLog.fromJson(response);
  }

  Future<void> deleteWaterLog(String waterLogId) async {
    await _client.from('water_logs').delete().eq('id', waterLogId);
  }

  // Weight log operations
  Future<List<WeightLog>> getWeightLogs(String userId, {int? limit}) async {
    var query = _client
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final response = limit != null 
        ? await query.limit(limit)
        : await query;
    
    return (response as List).map((json) => WeightLog.fromJson(json)).toList();
  }

  /// Pobiera logi wagi z zakresu dat (włącznie).
  Future<List<WeightLog>> getWeightLogsInRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));

    final response = await _client
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String())
        .order('created_at', ascending: true);

    return (response as List).map((json) => WeightLog.fromJson(json)).toList();
  }

  Future<WeightLog> createWeightLog(WeightLog weightLog) async {
    final response = await _client
        .from('weight_logs')
        .insert(weightLog.toJson())
        .select()
        .single();

    return WeightLog.fromJson(response);
  }

  Future<void> deleteWeightLog(String weightLogId) async {
    await _client.from('weight_logs').delete().eq('id', weightLogId);
  }

  // Body measurement operations
  Future<List<BodyMeasurement>> getBodyMeasurements(
    String userId, {
    String? measurementType,
    int? limit,
  }) async {
    var query = _client
        .from('body_measurements')
        .select()
        .eq('user_id', userId);

    if (measurementType != null) {
      query = query.eq('measurement_type', measurementType);
    }

    final orderedQuery = query.order('created_at', ascending: false);

    final response = limit != null 
        ? await orderedQuery.limit(limit)
        : await orderedQuery;
    
    return (response as List).map((json) => BodyMeasurement.fromJson(json)).toList();
  }

  Future<BodyMeasurement> createBodyMeasurement(BodyMeasurement measurement) async {
    final response = await _client
        .from('body_measurements')
        .insert(measurement.toJson())
        .select()
        .single();

    return BodyMeasurement.fromJson(response);
  }

  Future<void> deleteBodyMeasurement(String measurementId) async {
    await _client.from('body_measurements').delete().eq('id', measurementId);
  }

  // Favorite Meals operations
  Future<List<FavoriteMeal>> getFavoriteMeals(String userId) async {
    final response = await _client
        .from('favorite_meals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => FavoriteMeal.fromJson(json)).toList();
  }

  Future<FavoriteMeal> createFavoriteMeal(FavoriteMeal favoriteMeal) async {
    final response = await _client
        .from('favorite_meals')
        .insert(favoriteMeal.toJson())
        .select()
        .single();

    return FavoriteMeal.fromJson(response);
  }

  Future<FavoriteMeal> updateFavoriteMeal(FavoriteMeal favoriteMeal) async {
    if (favoriteMeal.id == null) throw Exception('Favorite meal ID is required for update');
    final response = await _client
        .from('favorite_meals')
        .update(favoriteMeal.toJson())
        .eq('id', favoriteMeal.id!)
        .select()
        .single();

    return FavoriteMeal.fromJson(response);
  }

  Future<void> deleteFavoriteMeal(String favoriteMealId) async {
    await _client.from('favorite_meals').delete().eq('id', favoriteMealId);
  }

  // Favorite activities
  Future<List<FavoriteActivity>> getFavoriteActivities(String userId) async {
    final response = await _client
        .from('favorite_activities')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => FavoriteActivity.fromJson(json)).toList();
  }

  Future<FavoriteActivity> createFavoriteActivity(FavoriteActivity fa) async {
    final response = await _client
        .from('favorite_activities')
        .insert(fa.toJson())
        .select()
        .single();
    return FavoriteActivity.fromJson(response);
  }

  Future<void> deleteFavoriteActivity(String favoriteActivityId) async {
    await _client.from('favorite_activities').delete().eq('id', favoriteActivityId);
  }

  // Streaks operations
  Future<List<Streak>> getStreaks(String userId) async {
    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', userId);

    return (response as List).map((json) => Streak.fromJson(json)).toList();
  }

  Future<Streak> upsertStreak(Streak streak) async {
    final response = await _client
        .from('streaks')
        .upsert(
          streak.toJson(),
          onConflict: 'user_id,streak_type',
        )
        .select()
        .single();

    return Streak.fromJson(response);
  }

  Future<void> updateStreak(String userId, String streakType, DateTime date) async {
    // Pobierz aktualny streak
    final streaks = await getStreaks(userId);
    final existingStreak = streaks.firstWhere(
      (s) => s.streakType == streakType,
      orElse: () => Streak(
        userId: userId,
        streakType: streakType,
        currentStreak: 0,
        longestStreak: 0,
      ),
    );

    final today = DateTime(date.year, date.month, date.day);
    final lastDate = existingStreak.lastDate != null
        ? DateTime(
            existingStreak.lastDate!.year,
            existingStreak.lastDate!.month,
            existingStreak.lastDate!.day,
          )
        : null;

    int newCurrentStreak = existingStreak.currentStreak;
    int newLongestStreak = existingStreak.longestStreak;

    if (lastDate == null) {
      // Pierwszy raz
      newCurrentStreak = 1;
      newLongestStreak = 1;
    } else {
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 0) {
        // Ten sam dzień - nie zwiększaj streak
        return;
      } else if (daysDifference == 1) {
        // Kolejny dzień - zwiększ streak
        newCurrentStreak = existingStreak.currentStreak + 1;
        newLongestStreak = newCurrentStreak > existingStreak.longestStreak
            ? newCurrentStreak
            : existingStreak.longestStreak;
      } else {
        // Przerwa - reset streak
        newCurrentStreak = 1;
        newLongestStreak = existingStreak.longestStreak; // Zachowaj najdłuższy
      }
    }

    final updatedStreak = Streak(
      id: existingStreak.id,
      userId: userId,
      streakType: streakType,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastDate: today,
    );

    await upsertStreak(updatedStreak);
  }

  // Goal Challenges operations
  Future<List<GoalChallenge>> getGoalChallenges(String userId) async {
    final response = await _client
        .from('goal_challenges')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => GoalChallenge.fromJson(json)).toList();
  }

  Future<GoalChallenge> createGoalChallenge(GoalChallenge challenge) async {
    final response = await _client
        .from('goal_challenges')
        .insert(challenge.toJson())
        .select()
        .single();

    return GoalChallenge.fromJson(response);
  }

  Future<GoalChallenge> updateGoalChallenge(GoalChallenge challenge) async {
    if (challenge.id == null) throw Exception('Challenge ID is required for update');
    final response = await _client
        .from('goal_challenges')
        .update(challenge.toJson())
        .eq('id', challenge.id!)
        .select()
        .single();

    return GoalChallenge.fromJson(response);
  }

  Future<void> deleteGoalChallenge(String challengeId) async {
    await _client.from('goal_challenges').delete().eq('id', challengeId);
  }

  // Strava integration
  Future<Map<String, dynamic>?> getStravaIntegration(String userId) async {
    final response = await _client
        .from('strava_integrations')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> upsertStravaIntegration({
    required String userId,
    required String refreshToken,
    required String accessToken,
    required int expiresAt,
  }) async {
    await _client.from('strava_integrations').upsert(
      {
        'user_id': userId,
        'refresh_token': refreshToken,
        'access_token': accessToken,
        'expires_at': expiresAt,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  Future<void> deleteStravaIntegration(String userId) async {
    await _client.from('strava_integrations').delete().eq('user_id', userId);
  }

  Future<bool> isStravaActivitySynced(String userId, int stravaActivityId) async {
    final response = await _client
        .from('strava_synced_activities')
        .select('id')
        .eq('user_id', userId)
        .eq('strava_activity_id', stravaActivityId)
        .maybeSingle();
    return response != null;
  }

  Future<void> markStravaActivitySynced({
    required String userId,
    required int stravaActivityId,
    required String activityId,
  }) async {
    await _client.from('strava_synced_activities').insert({
      'user_id': userId,
      'strava_activity_id': stravaActivityId,
      'activity_id': activityId,
    });
  }

  // Garmin integration
  Future<Map<String, dynamic>?> getGarminIntegration(String userId) async {
    final response = await _client
        .from('garmin_integrations')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> upsertGarminIntegration({
    required String userId,
    required String accessToken,
    required DateTime expiresAt,
    String? refreshToken,
    String? garminUserId,
  }) async {
    await _client.from('garmin_integrations').upsert(
      {
        'user_id': userId,
        'access_token': accessToken,
        'expires_at': expiresAt.toIso8601String(),
        ...? (refreshToken != null ? {'refresh_token': refreshToken} : null),
        ...? (garminUserId != null ? {'garmin_user_id': garminUserId} : null),
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  /// Aktualizuje tylko garmin_user_id (np. po pierwszym połączeniu, dla push).
  Future<void> updateGarminUserId(String userId, String garminUserId) async {
    await _client.from('garmin_integrations').update({
      'garmin_user_id': garminUserId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  Future<void> deleteGarminIntegration(String userId) async {
    await _client.from('garmin_integrations').delete().eq('user_id', userId);
  }

  Future<bool> isGarminActivitySynced(String userId, String garminActivityId) async {
    final response = await _client
        .from('garmin_synced_activities')
        .select('id')
        .eq('user_id', userId)
        .eq('garmin_activity_id', garminActivityId)
        .maybeSingle();
    return response != null;
  }

  Future<void> markGarminActivitySynced({
    required String userId,
    required String garminActivityId,
    required String activityId,
  }) async {
    await _client.from('garmin_synced_activities').insert({
      'user_id': userId,
      'garmin_activity_id': garminActivityId,
      'activity_id': activityId,
    });
  }

  // Goal History operations
  Future<void> saveGoalHistory({
    required String userId,
    double? oldTargetCalories,
    double? newTargetCalories,
    DateTime? oldTargetDate,
    DateTime? newTargetDate,
    double? oldWeeklyWeightChange,
    double? newWeeklyWeightChange,
    String? reason,
  }) async {
    final data = <String, dynamic>{
      'user_id': userId,
    };
    
    if (oldTargetCalories != null) data['old_target_calories'] = oldTargetCalories;
    if (newTargetCalories != null) data['new_target_calories'] = newTargetCalories;
    if (oldTargetDate != null) data['old_target_date'] = oldTargetDate.toIso8601String().split('T')[0];
    if (newTargetDate != null) data['new_target_date'] = newTargetDate.toIso8601String().split('T')[0];
    if (oldWeeklyWeightChange != null) data['old_weekly_weight_change'] = oldWeeklyWeightChange;
    if (newWeeklyWeightChange != null) data['new_weekly_weight_change'] = newWeeklyWeightChange;
    if (reason != null) data['reason'] = reason;
    
    await _client.from('goal_history').insert(data);
  }

  // Products (catalog from OFF import / user / restaurant)
  /// Mapuje wiersz z tabeli products na format używany w UI (BarcodeProductScreen, ProductSearchScreen).
  static Map<String, dynamic> _productRowToMap(Map<String, dynamic> row) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return {
      'name': row['name'] as String? ?? 'Produkt',
      'barcode': row['barcode'] as String? ?? '',
      'calories': toDouble(row['calories_per_100g']),
      'proteinG': toDouble(row['protein_g']),
      'fatG': toDouble(row['fat_g']),
      'carbsG': toDouble(row['carbs_g']),
      'weightG': row['weight_g'] != null ? toDouble(row['weight_g']) : null,
      'imageUrl': row['image_url'] as String?,
      'brand': row['brand'] as String?,
      'ingredients': row['ingredients'] as String?,
    };
  }

  /// Pobiera produkt po kodzie kreskowym. Zwraca mapę w formacie UI lub null.
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final response = await _client
        .from('products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();
    if (response == null) return null;
    return _productRowToMap(response);
  }

  /// Wyszukuje produkty po nazwie (ilike). Zwraca listę map w formacie UI.
  Future<List<Map<String, dynamic>>> searchProducts(String query, {int limit = 24}) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final response = await _client
        .from('products')
        .select()
        .ilike('name', '%$q%')
        .limit(limit);
    return (response as List).map((row) => _productRowToMap(row as Map<String, dynamic>)).toList();
  }
}
