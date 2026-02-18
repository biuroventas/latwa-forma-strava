import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/activity.dart';

/// Serwis integracji ze Strava - OAuth, pobieranie aktywności, synchronizacja kalorii.
class StravaService {
  static const _baseUrl = 'https://www.strava.com';
  static const _redirectScheme = 'latwaforma';
  static const _redirectHost = 'strava-callback';
  static const _scope = 'activity:read_all,read';

  String? get _clientId => dotenv.env['STRAVA_CLIENT_ID'];
  String? get _clientSecret => dotenv.env['STRAVA_CLIENT_SECRET'];
  String? get _redirectUriOverride => dotenv.env['STRAVA_REDIRECT_URI'];

  bool get isConfigured =>
      (_clientId?.isNotEmpty ?? false) && (_clientSecret?.isNotEmpty ?? false);

  String get _redirectUri =>
      (_redirectUriOverride?.isNotEmpty ?? false)
          ? _redirectUriOverride!
          : '$_redirectScheme://$_redirectHost';

  /// Otwiera stronę autoryzacji Strava.
  Future<void> launchAuth() async {
    if (!isConfigured) {
      throw Exception(
        'Strava nie jest skonfigurowana. Dodaj STRAVA_CLIENT_ID i STRAVA_CLIENT_SECRET do .env',
      );
    }
    final uri = Uri.parse('$_baseUrl/oauth/authorize').replace(
      queryParameters: {
        'client_id': _clientId!,
        'redirect_uri': _redirectUri,
        'response_type': 'code',
        'approval_prompt': 'force',
        'scope': _scope,
      },
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Nie udało się otworzyć Strava');
    }
  }

  /// Wymienia kod autoryzacji na tokeny.
  Future<StravaTokenResponse> exchangeCode(String code) async {
    if (!isConfigured) {
      throw Exception('Strava nie jest skonfigurowana');
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId!,
        'client_secret': _clientSecret!,
        'code': code,
        'grant_type': 'authorization_code',
      },
    );
    if (res.statusCode != 200) {
      debugPrint('Strava token error: ${res.statusCode} ${res.body}');
      throw Exception('Błąd Strava: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return StravaTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }

  /// Odświeża access token.
  Future<StravaTokenResponse> refreshToken(String refreshToken) async {
    if (!isConfigured) {
      throw Exception('Strava nie jest skonfigurowana');
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId!,
        'client_secret': _clientSecret!,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Błąd odświeżania tokenu Strava');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return StravaTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }

  /// Pobiera aktywności ze Strava (ostatnie N dni).
  Future<List<StravaActivity>> fetchActivities(
    String accessToken, {
    int lastDays = 30,
  }) async {
    final now = DateTime.now();
    final after = now.subtract(Duration(days: lastDays));
    final afterEpoch = after.millisecondsSinceEpoch ~/ 1000;
    final beforeEpoch = now.millisecondsSinceEpoch ~/ 1000;

    final uri = Uri.parse('$_baseUrl/api/v3/athlete/activities').replace(
      queryParameters: {
        'after': afterEpoch.toString(),
        'before': beforeEpoch.toString(),
        'per_page': '200',
      },
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (res.statusCode != 200) {
      throw Exception('Błąd Strava API: ${res.statusCode}');
    }

    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => StravaActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Pobiera szczegóły aktywności (m.in. kalorie dla biegania).
  Future<StravaActivity> fetchActivityDetails(
    String accessToken,
    int activityId,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/v3/activities/$activityId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (res.statusCode != 200) {
      throw Exception('Błąd Strava API: ${res.statusCode}');
    }
    return StravaActivity.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  /// Mapuje aktywność Strava na model Activity (z oszacowaniem kalorii gdy brak).
  Activity mapToActivity(StravaActivity s, String userId, double weightKg) {
    double calories = _estimateCalories(s, weightKg);
    final startDate = DateTime.parse(s.startDate);
    final durationMin = (s.movingTime ?? s.elapsedTime) ~/ 60;
    final name = s.name.isNotEmpty
        ? '${s.name} (Strava)'
        : '${s.type} (Strava)';

    return Activity(
      userId: userId,
      name: name,
      caloriesBurned: calories,
      durationMinutes: durationMin > 0 ? durationMin : null,
      intensity: s.type,
      createdAt: startDate,
    );
  }

  double _estimateCalories(StravaActivity s, double weightKg) {
    if (s.calories != null && s.calories! > 0) return s.calories!.toDouble();
    if (s.kilojoules != null && s.kilojoules! > 0) {
      return s.kilojoules! / 4.184;
    }
    final minutes = ((s.movingTime ?? s.elapsedTime) / 60).clamp(1, 480);
    final met = _getMET(s.type);
    return met * weightKg * (minutes / 60);
  }

  double _getMET(String type) {
    final t = type.toLowerCase();
    if (t.contains('run') || t.contains('bieg')) return 9;
    if (t.contains('ride') || t.contains('row') || t.contains('kolarstwo')) return 8;
    if (t.contains('swim') || t.contains('pływanie')) return 8;
    if (t.contains('hike') || t.contains('walk')) return 5;
    if (t.contains('yoga') || t.contains('pilates')) return 3;
    if (t.contains('weight') || t.contains('trening')) return 5;
    return 6;
  }

  /// Zwraca regex do dopasowania redirect URI (dla app_links).
  static String get redirectUriPattern => '$_redirectScheme://$_redirectHost';
}

class StravaTokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresAt;

  StravaTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}

class StravaActivity {
  final int id;
  final String name;
  final String type;
  final String startDate;
  final int? movingTime;
  final int elapsedTime;
  final double? distance;
  final double? calories;
  final double? kilojoules;

  StravaActivity({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    this.movingTime,
    required this.elapsedTime,
    this.distance,
    this.calories,
    this.kilojoules,
  });

  factory StravaActivity.fromJson(Map<String, dynamic> json) {
    return StravaActivity(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'Activity',
      startDate: json['start_date'] as String,
      movingTime: json['moving_time'] as int?,
      elapsedTime: json['elapsed_time'] as int? ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toDouble(),
      kilojoules: (json['kilojoules'] as num?)?.toDouble(),
    );
  }
}
