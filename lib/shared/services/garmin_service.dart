import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/supabase_config.dart';
import '../models/activity.dart';

/// Serwis integracji z Garmin Connect - OAuth 2.0 PKCE, pobieranie aktywności.
/// Wymaga zatwierdzenia: https://www.garmin.com/en-US/forms/GarminConnectDeveloperAccess/
class GarminService {
  static const _authUrl = 'https://connect.garmin.com/oauth2Confirm';
  static const _tokenUrl = 'https://diauth.garmin.com/di-oauth2-service/oauth/token';
  /// Health API (aktywności). Przy InvalidPullTokenException: włącz Pull w healthapi.garmin.com/tools
  static const _apiBase = 'https://healthapi.garmin.com';
  static const _redirectScheme = 'latwaforma';
  static const _redirectHost = 'garmin-callback';

  String? get _clientId => SupabaseConfig.getEnv('GARMIN_CLIENT_ID');
  String? get _clientSecret => SupabaseConfig.getEnv('GARMIN_CLIENT_SECRET');
  String? get _redirectUriOverride => SupabaseConfig.getEnv('GARMIN_REDIRECT_URI');

  /// Do rozpoczęcia OAuth (otwarcie strony autoryzacji) wystarczy publiczny client_id.
  bool get isConfigured => (_clientId?.isNotEmpty ?? false);

  String get _redirectUri =>
      (_redirectUriOverride?.isNotEmpty ?? false)
          ? _redirectUriOverride!
          : '$_redirectScheme://$_redirectHost';

  /// Generuje code_verifier i code_challenge dla PKCE.
  static (String verifier, String challenge) generatePkce() {
    final random = List<int>.generate(
      43,
      (i) => ((DateTime.now().microsecondsSinceEpoch + i * 37) % 256),
    );
    final verifier = base64Url.encode(random).replaceAll('=', '');
    final challengeBytes = sha256.convert(utf8.encode(verifier)).bytes;
    final challenge = base64Url.encode(challengeBytes).replaceAll('=', '');
    return (verifier, challenge);
  }

  /// Otwiera stronę autoryzacji Garmin (OAuth 2.0 PKCE).
  Future<(String verifier, String state)> launchAuth() async {
    if (!isConfigured) {
      throw Exception(
        'Garmin nie jest skonfigurowane. Dodaj GARMIN_CLIENT_ID do env.',
      );
    }
    final (verifier, challenge) = generatePkce();
    final state = base64Url.encode(List<int>.generate(16, (_) => 0)).replaceAll('=', '');

    final uri = Uri.parse(_authUrl).replace(
      queryParameters: {
        'client_id': _clientId!,
        'redirect_uri': _redirectUri,
        'response_type': 'code',
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'state': state,
      },
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Nie udało się otworzyć Garmin Connect');
    }
    return (verifier, state);
  }

  /// Wymienia kod autoryzacji na tokeny (z code_verifier PKCE).
  Future<GarminTokenResponse> exchangeCode(String code, String codeVerifier) async {
    if (!isConfigured) {
      throw Exception('Garmin nie jest skonfigurowane');
    }
    final res = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId!,
        'client_secret': _clientSecret!,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code_verifier': codeVerifier,
      },
    );
    if (res.statusCode != 200) {
      debugPrint('Garmin token error: ${res.statusCode} ${res.body}');
      throw Exception('Błąd Garmin: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return GarminTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int? ?? 3600,
    );
  }

  /// Odświeża access token.
  Future<GarminTokenResponse> refreshToken(String refreshToken) async {
    if (!isConfigured) {
      throw Exception('Garmin nie jest skonfigurowane');
    }
    final res = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId!,
        'client_secret': _clientSecret!,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Błąd odświeżania tokenu Garmin');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return GarminTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int? ?? 3600,
    );
  }

  /// Pobiera aktywności z Garmin (Activity API / Wellness API).
  Future<List<GarminActivity>> fetchActivities(
    String accessToken, {
    int lastDays = 30,
  }) async {
    final endMs = DateTime.now().millisecondsSinceEpoch;
    final startMs = DateTime.now()
        .subtract(Duration(days: lastDays))
        .millisecondsSinceEpoch;

    final uri = Uri.parse('$_apiBase/wellness-api/rest/activities').replace(
      queryParameters: {
        'uploadStartTimeInSeconds': (startMs ~/ 1000).toString(),
        'uploadEndTimeInSeconds': (endMs ~/ 1000).toString(),
      },
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Błąd Garmin API: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is List) {
      return body
          .map((e) => GarminActivity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (body is Map && body['activities'] != null) {
      return (body['activities'] as List)
          .map((e) => GarminActivity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Mapuje aktywność Garmin na model Activity.
  Activity mapToActivity(GarminActivity g, String userId, double weightKg) {
    double calories = _estimateCalories(g, weightKg);
    final startDate = DateTime.fromMillisecondsSinceEpoch(g.startTimeMs);
    final durationMin = g.durationSec ~/ 60;
    final name = g.activityName.isNotEmpty
        ? '${g.activityName} (Garmin)'
        : '${g.activityType} (Garmin)';

    return Activity(
      userId: userId,
      name: name,
      caloriesBurned: calories,
      durationMinutes: durationMin > 0 ? durationMin : null,
      intensity: g.activityType,
      createdAt: startDate,
    );
  }

  double _estimateCalories(GarminActivity g, double weightKg) {
    if (g.calories != null && g.calories! > 0) return g.calories!.toDouble();
    final minutes = (g.durationSec / 60).clamp(1, 480);
    final met = _getMET(g.activityType);
    return met * weightKg * (minutes / 60);
  }

  double _getMET(String type) {
    final t = type.toLowerCase();
    if (t.contains('run') || t.contains('running')) return 9;
    if (t.contains('cycle') || t.contains('bike')) return 8;
    if (t.contains('swim')) return 8;
    if (t.contains('hike') || t.contains('walk')) return 5;
    if (t.contains('yoga') || t.contains('pilates')) return 3;
    if (t.contains('strength') || t.contains('training')) return 5;
    return 6;
  }
}

class GarminTokenResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  GarminTokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn = 3600,
  });
}

class GarminActivity {
  final String activityId;
  final String activityName;
  final String activityType;
  final int startTimeMs;
  final int durationSec;
  final double? calories;

  GarminActivity({
    required this.activityId,
    required this.activityName,
    required this.activityType,
    required this.startTimeMs,
    required this.durationSec,
    this.calories,
  });

  factory GarminActivity.fromJson(Map<String, dynamic> json) {
    int startMs = 0;
    final startVal = json['startTimeInSeconds'] ?? json['StartTimeInSeconds'] ?? json['startTimeGmt'] ?? json['start_time'] ?? json['beginTimestamp'];
    if (startVal is int) {
      startMs = startVal > 10000000000 ? startVal : startVal * 1000;
    } else if (startVal is String) {
      try {
        startMs = DateTime.parse(startVal).millisecondsSinceEpoch;
      } catch (_) {}
    }

    final duration = json['durationInSeconds'] ?? json['DurationInSeconds'] ?? json['duration'] ?? json['activeSeconds'] ?? 0;
    final durationSec = duration is int ? duration : 0;

    return GarminActivity(
      activityId: (json['activityId'] ?? json['activity_id'] ?? json['uuid'] ?? json['id'] ?? json['summaryId'] ?? json['uploadId'] ?? '').toString(),
      activityName: (json['activityName'] ?? json['activity_name'] ?? json['activity_type'] ?? '').toString(),
      activityType: (json['activityType'] ?? json['activity_type'] ?? 'Other').toString(),
      startTimeMs: startMs,
      durationSec: durationSec,
      calories: (json['calories'] as num?)?.toDouble(),
    );
  }
}
