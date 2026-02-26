import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/garmin_service.dart';
import '../../../shared/services/strava_service.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../core/utils/success_message.dart';

final stravaIntegrationProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) return null;
  return SupabaseService().getStravaIntegration(userId);
});

final garminIntegrationProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) return null;
  return SupabaseService().getGarminIntegration(userId);
});

class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  final _stravaService = StravaService();
  final _garminService = GarminService();
  final _supabaseService = SupabaseService();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<AuthState>? _garminAuthSub;
  bool _isConnecting = false;
  bool _isSyncing = false;
  bool _isConnectingGarmin = false;
  bool _isSyncingGarmin = false;
  static const _garminVerifierKey = 'garmin_pkce_verifier';

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _linkSubscription = AppLinks().uriLinkStream.listen(_onAppLink);
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleWebStravaCallback();
        _handleWebGarminCallback();
      });
    }
  }

  /// Na webie: odczytaj strava_code z URL (po przekierowaniu z strava-callback.html) i wymień na tokeny.
  void _handleWebStravaCallback() {
    if (!mounted) return;
    final base = Uri.base;
    String? code;
    if (base.fragment.isNotEmpty) {
      final fragment = base.fragment.startsWith('/') ? base.fragment : '/${base.fragment}';
      final qIndex = fragment.indexOf('?');
      if (qIndex >= 0 && qIndex < fragment.length - 1) {
        final query = fragment.substring(qIndex + 1);
        code = Uri.splitQueryString(query)['strava_code'];
      }
    }
    if (base.queryParameters['strava_code'] != null) {
      code = base.queryParameters['strava_code'];
    }
    if (code == null || code.isEmpty) return;
    context.go(AppRoutes.integrations);
    _waitForUserThenExchangeStrava(code);
  }

  /// Po przekierowaniu z callbacku sesja może być jeszcze nie przywrócona – czekamy na użytkownika, potem wymieniamy kod.
  Future<void> _waitForUserThenExchangeStrava(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < 50; i++) {
      if (!mounted) return;
      if (SupabaseConfig.currentUserOrNull != null) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    if (SupabaseConfig.currentUserOrNull == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zaloguj się, aby dokończyć połączenie ze Strava')),
        );
      }
      return;
    }
    await _exchangeStravaCode(code);
  }

  /// Na webie: odczytaj garmin_code z URL (po przekierowaniu z garmin-callback.html) i wymień na tokeny.
  void _handleWebGarminCallback() {
    if (!mounted) return;
    final base = Uri.base;
    String? code;
    if (base.fragment.isNotEmpty) {
      final fragment = base.fragment.startsWith('/') ? base.fragment : '/${base.fragment}';
      final qIndex = fragment.indexOf('?');
      if (qIndex >= 0 && qIndex < fragment.length - 1) {
        final query = fragment.substring(qIndex + 1);
        code = Uri.splitQueryString(query)['garmin_code'];
      }
    }
    if (base.queryParameters['garmin_code'] != null) {
      code = base.queryParameters['garmin_code'];
    }
    if (code == null || code.isEmpty) return;
    context.go(AppRoutes.integrations);
    _waitForUserThenExchangeGarmin(code);
  }

  Future<void> _waitForUserThenExchangeGarmin(String code) async {
    // Po powrocie z Garmin strona ładuje się od zera – sesja jest przywracana z localStorage.
    // Czekamy na pojawienie się użytkownika (onAuthStateChange) albo 15 s.
    if (SupabaseConfig.currentUserOrNull != null) {
      await _exchangeGarminCode(code);
      return;
    }
    var exchanged = false;
    final done = Completer<void>();
    final timer = Timer(const Duration(seconds: 15), () {
      if (!exchanged && !done.isCompleted) {
        done.complete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zaloguj się, aby dokończyć połączenie z Garmin')),
          );
        }
      }
    });
    _garminAuthSub?.cancel();
    _garminAuthSub = SupabaseConfig.auth.onAuthStateChange.listen((data) async {
      if (exchanged || !mounted || done.isCompleted) return;
      if (data.session != null) {
        exchanged = true;
        timer.cancel();
        _garminAuthSub?.cancel();
        _garminAuthSub = null;
        if (!done.isCompleted) done.complete();
        await _exchangeGarminCode(code);
      }
    });
    await done.future;
    timer.cancel();
    _garminAuthSub?.cancel();
    _garminAuthSub = null;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _garminAuthSub?.cancel();
    super.dispose();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await AppLinks().getInitialLink();
      if (uri != null) _onAppLink(uri);
    } catch (_) {}
  }

  void _onAppLink(Uri uri) {
    if (uri.host == 'strava-callback') {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) _exchangeStravaCode(code);
      return;
    }
    if (uri.host == 'garmin-callback') {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) _exchangeGarminCode(code);
      return;
    }
  }

  Future<void> _exchangeStravaCode(String code) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isConnecting = true);
    try {
      final tokens = await _stravaService.exchangeCode(code);
      await _supabaseService.upsertStravaIntegration(
        userId: userId,
        refreshToken: tokens.refreshToken,
        accessToken: tokens.accessToken,
        expiresAt: tokens.expiresAt,
      );
      ref.invalidate(stravaIntegrationProvider);
      final _ = ref.refresh(stravaIntegrationProvider);
      if (!mounted) return;
      setState(() => _isConnecting = false);

      // Automatyczna synchronizacja od razu po połączeniu – użytkownik widzi wynik.
      final imported = await _syncStrava(silent: true);
      if (!mounted) return;
      if (imported != null) {
        SuccessMessage.show(
          context,
          imported > 0
              ? 'Strava połączona. Zaimportowano $imported aktywności.'
              : 'Strava połączona. Brak nowych aktywności do importu.',
          duration: const Duration(seconds: 4),
        );
      } else {
        SuccessMessage.show(context, 'Strava połączona pomyślnie');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronizacja nie powiodła się. Kliknij „Synchronizuj aktywności” później.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _exchangeGarminCode(String code) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final verifier = prefs.getString(_garminVerifierKey);
    if (verifier == null || verifier.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesja wygasła. Spróbuj ponownie połączyć Garmin.')),
        );
      }
      return;
    }
    await prefs.remove(_garminVerifierKey);

    setState(() => _isConnectingGarmin = true);
    try {
      // Po powrocie z Garmin (web) sesja jest przywracana z localStorage – dajemy chwilę na odświeżenie tokenu.
      if (kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        try {
          await SupabaseConfig.auth.refreshSession();
        } catch (_) {}
      }

      final url = Uri.parse('${SupabaseConfig.functionsBaseUrl}/garmin_exchange_code');
      final body = jsonEncode({'code': code, 'code_verifier': verifier});

      Future<http.Response> sendWithCurrentSession() async {
        Session? session;
        try {
          final refreshed = await SupabaseConfig.auth.refreshSession();
          session = refreshed.session ?? SupabaseConfig.auth.currentSession;
        } catch (_) {
          session = SupabaseConfig.auth.currentSession;
        }
        final accessToken = session?.accessToken;
        if (accessToken == null) return http.Response('', 401);
        return http.post(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: body,
        );
      }

      http.Response res = await sendWithCurrentSession();
      if (res.statusCode == 401) {
        await Future<void>.delayed(const Duration(seconds: 2));
        await SupabaseConfig.auth.refreshSession();
        res = await sendWithCurrentSession();
      }
      if (res.statusCode == 401) {
        String serverMsg = '';
        try {
          final err = jsonDecode(res.body) as Map<String, dynamic>?;
          serverMsg = (err?['error'] ?? err?['message'] ?? '').toString();
        } catch (_) {}
        if (serverMsg.isNotEmpty) {
          throw Exception('Sesja odrzucona: $serverMsg. Wyloguj się, zaloguj ponownie i spróbuj połączyć Garmin.');
        }
        throw Exception(
          'Sesja wygasła. Wyloguj się i zaloguj ponownie do Łatwej Formy, potem kliknij „Połącz z Garmin Connect”.',
        );
      }
      if (res.statusCode != 200) {
        final err = jsonDecode(res.body) as Map<String, dynamic>?;
        throw Exception(err?['detail'] ?? err?['error'] ?? res.body);
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final tokens = GarminTokenResponse(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String?,
        expiresIn: (data['expires_in'] as int?) ?? 3600,
      );
      final expiresAt = DateTime.now().add(Duration(seconds: tokens.expiresIn));
      await _supabaseService.upsertGarminIntegration(
        userId: userId,
        accessToken: tokens.accessToken,
        expiresAt: expiresAt,
        refreshToken: tokens.refreshToken,
      );
      // Pobierz Garmin User ID i zapisz (potrzebne do odbierania push – mapowanie payloadu na user_id)
      try {
        final session = SupabaseConfig.auth.currentSession;
        final jwt = session?.accessToken;
        if (jwt != null) {
          final idRes = await http.get(
            Uri.parse('${SupabaseConfig.functionsBaseUrl}/garmin_user_id'),
            headers: {'Authorization': 'Bearer $jwt'},
          );
          if (idRes.statusCode == 200) {
            final idData = jsonDecode(idRes.body) as Map<String, dynamic>?;
            final garminUserId = idData?['userId'] as String?;
            if (garminUserId != null && garminUserId.isNotEmpty) {
              await _supabaseService.updateGarminUserId(userId, garminUserId);
            }
          }
        }
      } catch (_) {
        // Nie blokuj sukcesu – garmin_user_id można uzupełnić później przy sync
      }
      ref.invalidate(garminIntegrationProvider);
      if (mounted) {
        SuccessMessage.show(context, 'Garmin Connect połączony pomyślnie');
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        final isSessionError = msg.contains('401') || msg.contains('Invalid JWT');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSessionError
                  ? 'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem połącz Garmin.'
                  : 'Błąd Garmin: $e',
            ),
            duration: isSessionError ? const Duration(seconds: 5) : const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingGarmin = false;
        });
      }
    }
  }

  Future<void> _connectStrava() async {
    if (!_stravaService.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dodaj STRAVA_CLIENT_ID i STRAVA_CLIENT_SECRET do pliku .env',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _isConnecting = true);
    try {
      await _stravaService.launchAuth();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _connectGarmin() async {
    if (!_garminService.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dodaj GARMIN_CLIENT_ID do env (po zatwierdzeniu programu).',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _isConnectingGarmin = true);
    try {
      final (verifier, _) = await _garminService.launchAuth();
      await (await SharedPreferences.getInstance()).setString(_garminVerifierKey, verifier);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnectingGarmin = false);
    }
  }

  Future<void> _disconnectGarmin() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    final integration = await _supabaseService.getGarminIntegration(userId);
    var accessToken = integration?['access_token'] as String?;
    final refreshToken = integration?['refresh_token'] as String?;
    if (accessToken == null && refreshToken != null) {
      try {
        final tokens = await _garminService.refreshToken(refreshToken);
        accessToken = tokens.accessToken;
      } catch (_) {}
    }
    if (accessToken != null) {
      try {
        await _garminService.deleteUserRegistration(accessToken);
      } catch (_) {}
    }
    await _supabaseService.deleteGarminIntegration(userId);
    ref.invalidate(garminIntegrationProvider);
    if (mounted) SuccessMessage.show(context, 'Garmin Connect odłączony');
  }

  /// Pobiera Garmin User ID (do Data Viewera) z Edge Function i pokazuje w dialogu.
  Future<void> _showGarminUserId() async {
    Session? session = SupabaseConfig.auth.currentSession;
    try {
      final refreshed = await SupabaseConfig.auth.refreshSession();
      session = refreshed.session ?? session;
    } catch (_) {}
    final jwt = session?.accessToken;
    if (jwt == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesja wygasła. Zaloguj się ponownie.')),
        );
      }
      return;
    }
    final url = Uri.parse('${SupabaseConfig.functionsBaseUrl}/garmin_user_id');
    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $jwt'},
      );
      if (res.statusCode != 200) {
        final err = jsonDecode(res.body) as Map<String, dynamic>?;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err?['error'] ?? res.body)),
          );
        }
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final garminUserId = data['userId'] as String?;
      if (garminUserId == null || garminUserId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Brak User ID w odpowiedzi')),
          );
        }
        return;
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Garmin User ID (do Data Viewera)'),
          content: SelectableText(garminUserId),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Zamknij'),
            ),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: garminUserId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Skopiowano do schowka')),
                );
                Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.copy),
              label: const Text('Kopiuj'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    }
  }

  Future<void> _syncGarmin() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    final integration = await _supabaseService.getGarminIntegration(userId);
    if (integration == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najpierw połącz konto Garmin')),
        );
      }
      return;
    }

    var accessToken = integration['access_token'] as String?;
    var refreshToken = integration['refresh_token'] as String?;
    final expiresAt = integration['expires_at'] != null
        ? DateTime.parse(integration['expires_at'] as String)
        : null;

    if (!kIsWeb &&
        expiresAt != null &&
        DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)))) {
      if (refreshToken != null) {
        final tokens = await _garminService.refreshToken(refreshToken);
        accessToken = tokens.accessToken;
        final newExpires = DateTime.now().add(Duration(seconds: tokens.expiresIn));
        await _supabaseService.upsertGarminIntegration(
          userId: userId,
          accessToken: tokens.accessToken,
          expiresAt: newExpires,
          refreshToken: tokens.refreshToken ?? refreshToken,
        );
      }
    }

    // Uzupełnij garmin_user_id jeśli brak (np. po migracji) – potrzebne do odbierania push
    final garminUserIdStored = integration['garmin_user_id'] as String?;
    if (garminUserIdStored == null || garminUserIdStored.isEmpty) {
      try {
        final session = SupabaseConfig.auth.currentSession;
        final jwt = session?.accessToken;
        if (jwt != null) {
          final idRes = await http.get(
            Uri.parse('${SupabaseConfig.functionsBaseUrl}/garmin_user_id'),
            headers: {'Authorization': 'Bearer $jwt'},
          );
          if (idRes.statusCode == 200) {
            final idData = jsonDecode(idRes.body) as Map<String, dynamic>?;
            final garminUserId = idData?['userId'] as String?;
            if (garminUserId != null && garminUserId.isNotEmpty) {
              await _supabaseService.updateGarminUserId(userId, garminUserId);
            }
          }
        }
      } catch (_) {}
    }

    setState(() => _isSyncingGarmin = true);
    bool showedEmptyHintDialog = false;
    try {
      List<GarminActivity> activities;
      if (kIsWeb) {
        final endSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final startSec = endSec - 30 * 86400;
        // Odśwież sesję i przekaż JWT w nagłówku (unikamy 401 przy ...co//functions i gubieniu Authorization).
        Session? session = SupabaseConfig.auth.currentSession;
        try {
          final refreshed = await SupabaseConfig.auth.refreshSession();
          session = refreshed.session ?? session;
        } catch (_) {}
        final jwt = session?.accessToken;
        if (jwt == null || jwt.isEmpty) {
          throw Exception(
            'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem spróbuj synchronizacji Garmin.',
          );
        }
        final response = await SupabaseConfig.client.functions.invoke(
          'garmin_fetch_activities',
          body: {
            'access_token': accessToken,
            'upload_start_seconds': startSec,
            'upload_end_seconds': endSec,
            'debug': true,
          },
          headers: {'Authorization': 'Bearer $jwt'},
        );
        if (response.status != 200) {
          final data = response.data;
          String errStr = '${response.status}';
          if (data is Map) {
            final err = data['message'] ?? data['error'] ?? data['detail'];
            final detail = data['detail']?.toString();
            errStr = err?.toString() ?? errStr;
            if (detail != null && detail.isNotEmpty && detail != errStr) {
              errStr = '$errStr $detail';
            }
          }
          if (response.status == 401 && errStr.toLowerCase().contains('invalid jwt')) {
            throw Exception(
              'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem spróbuj synchronizacji Garmin.',
            );
          }
          throw Exception(errStr);
        }
        final responseBody = response.data;
        if (responseBody is List) {
          activities = responseBody
              .map((e) => GarminActivity.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (responseBody is Map && responseBody['activities'] != null) {
          activities = ((responseBody['activities'] as List))
              .map((e) => GarminActivity.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          activities = [];
        }
        if (activities.isEmpty && responseBody is Map<String, dynamic>) {
          final emptyHint = responseBody['empty_hint']?.toString() ?? '';
          final debug = responseBody['_debug'] as Map<String, dynamic>?;
          final snippet = debug?['firstResponseSnippet']?.toString() ?? '';
          if (mounted) {
            if (emptyHint.isNotEmpty) {
              showedEmptyHintDialog = true;
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Brak aktywności z Garmin'),
                  content: SingleChildScrollView(
                    child: SelectableText(emptyHint),
                  ),
                  actions: [
                    if (snippet.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showGarminResponseDialog(context, snippet);
                        },
                        child: const Text('Szczegóły odpowiedzi API'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Zamknij'),
                    ),
                  ],
                ),
              );
            } else if (debug != null && snippet.isNotEmpty) {
              _showGarminResponseDialog(context, snippet);
            }
          }
        }
      } else {
        activities = await _garminService.fetchActivities(accessToken!);
      }
      final profile = await _supabaseService.getProfile(userId);
      final weightKg = profile?.currentWeightKg ?? 70;

      int imported = 0;
      for (final ga in activities) {
        if (ga.activityId.isEmpty) continue;
        final alreadySynced = await _supabaseService.isGarminActivitySynced(
          userId,
          ga.activityId,
        );
        if (alreadySynced) continue;

        final activity = _garminService.mapToActivity(ga, userId, weightKg);
        final created = await _supabaseService.createActivity(activity);
        await _supabaseService.markGarminActivitySynced(
          userId: userId,
          garminActivityId: ga.activityId,
          activityId: created.id!,
        );
        imported++;
      }

      if (mounted) {
        if (imported > 0) {
          SuccessMessage.show(context, 'Zaimportowano $imported aktywności z Garmin');
        } else if (!showedEmptyHintDialog) {
          SuccessMessage.show(context, 'Brak nowych aktywności do importu');
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        final isInvalidJwt = msg.contains('invalid jwt') || msg.contains('sesja wygasła');
        final isRevoked = msg.contains('revoked') || (msg.contains('jwt') && msg.contains('revocation'));
        if (isRevoked) {
          await _supabaseService.deleteGarminIntegration(userId);
          if (!mounted) return;
          ref.invalidate(garminIntegrationProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Połączenie z Garmin zostało odłączone (np. w Garmin Connect). Kliknij „Połącz z Garmin Connect”, aby połączyć ponownie.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        } else if (isInvalidJwt) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem spróbuj synchronizacji Garmin.',
              ),
              duration: Duration(seconds: 6),
            ),
          );
        } else {
          final msgRaw = e.toString();
          final isTokenNotSet = msgRaw.contains('GARMIN_PULL_TOKEN nie ustawiony') ||
              msgRaw.contains('GARMIN_PULL_TOKEN is not set');
          final isPullTokenError = !isTokenNotSet &&
              (msgRaw.contains('Invalid Pull Token') ||
                  msgRaw.contains('InvalidPullToken') ||
                  msgRaw.contains('Pull TokenException'));
          String snackText;
          if (isTokenNotSet) {
            snackText = 'Synchronizacja Garmin: sekret GARMIN_PULL_TOKEN nie jest widoczny w funkcji. '
                'Ustaw: supabase secrets set GARMIN_PULL_TOKEN=\'CPT_...\' i wdróż: supabase functions deploy garmin_fetch_activities';
          } else if (isPullTokenError) {
            snackText = 'Synchronizacja z Garmin jest tymczasowo niedostępna (ograniczenie po stronie Garmin API). '
                'Możesz dodawać aktywności ręcznie. Problem zgłoś: connect-support@developer.garmin.com';
          } else {
            snackText = 'Błąd synchronizacji Garmin: $e';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackText),
              duration: isTokenNotSet || isPullTokenError ? const Duration(seconds: 10) : const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSyncingGarmin = false);
    }
  }

  void _showGarminResponseDialog(BuildContext context, String snippet) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Odpowiedź Garmin (fragment)'),
        content: SingleChildScrollView(
          child: SelectableText(
            snippet.isEmpty
                ? 'Garmin zwrócił pustą odpowiedź. W środowisku Evaluation API może nie udostępniać danych Pull.'
                : snippet,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnectStrava() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    await _supabaseService.deleteStravaIntegration(userId);
    ref.invalidate(stravaIntegrationProvider);
    if (mounted) SuccessMessage.show(context, 'Strava odłączona');
  }

  /// Zwraca liczbę zaimportowanych aktywności lub null przy błędzie.
  /// [silent] true = nie pokazuj SnackBara (np. gdy wywołanie z _exchangeStravaCode).
  Future<int?> _syncStrava({bool silent = false}) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return null;

    final integration = await _supabaseService.getStravaIntegration(userId);
    if (integration == null) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najpierw połącz konto Strava')),
        );
      }
      return null;
    }

    var accessToken = integration['access_token'] as String?;
    var refreshToken = integration['refresh_token'] as String?;
    var expiresAt = (integration['expires_at'] as num?)?.toInt() ?? 0;

    if (DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt - 3600) {
      final tokens = await _stravaService.refreshToken(refreshToken!);
      accessToken = tokens.accessToken;
      refreshToken = tokens.refreshToken;
      expiresAt = tokens.expiresAt;
      await _supabaseService.upsertStravaIntegration(
        userId: userId,
        refreshToken: refreshToken,
        accessToken: accessToken,
        expiresAt: expiresAt,
      );
    }

    setState(() => _isSyncing = true);
    try {
      final activities = await _stravaService.fetchActivities(accessToken!);
      final profile = await _supabaseService.getProfile(userId);
      final weightKg = profile?.currentWeightKg ?? 70;

      int imported = 0;
      for (final sa in activities) {
        final alreadySynced = await _supabaseService.isStravaActivitySynced(
          userId,
          sa.id,
        );
        if (alreadySynced) continue;

        final activity = _stravaService.mapToActivity(sa, userId, weightKg);
        final created = await _supabaseService.createActivity(activity);
        await _supabaseService.markStravaActivitySynced(
          userId: userId,
          stravaActivityId: sa.id,
          activityId: created.id!,
        );
        imported++;
      }

      if (!silent && mounted) {
        SuccessMessage.show(
          context,
          imported > 0
              ? 'Zaimportowano $imported aktywności ze Strava'
              : 'Brak nowych aktywności do importu',
          duration: const Duration(seconds: 3),
        );
      }
      return imported;
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd synchronizacji: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final integration = ref.watch(stravaIntegrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integracje'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_bike,
                          color: Colors.orange.shade800,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Strava',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Importuj wszystkie aktywności i spalone kalorie',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  integration.when(
                    data: (data) {
                      if (data != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Połączona',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _isSyncing ? null : _syncStrava,
                              icon: _isSyncing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.sync),
                              label: Text(_isSyncing ? 'Synchronizuję...' : 'Synchronizuj aktywności'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _isConnecting ? null : _disconnectStrava,
                              child: const Text('Odłącz Strava'),
                            ),
                          ],
                        );
                      }
                      return FilledButton.icon(
                        onPressed: _isConnecting ? null : _connectStrava,
                        icon: _isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.link),
                        label: Text(
                          _isConnecting ? 'Łączę...' : 'Połącz ze Strava',
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('Błąd: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.watch,
                          color: Colors.blue.shade800,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Garmin Connect',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Importuj aktywności z zegarków i urządzeń Garmin',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Synchronizacja z ostatnich 7 dni (limit Garmin Health API).',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ref.watch(garminIntegrationProvider).when(
                    data: (data) {
                      if (data != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Połączona',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _isSyncingGarmin ? null : _syncGarmin,
                              icon: _isSyncingGarmin
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.sync),
                              label: Text(_isSyncingGarmin ? 'Synchronizuję...' : 'Synchronizuj aktywności'),
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              onPressed: _showGarminUserId,
                              icon: const Icon(Icons.info_outline, size: 18),
                              label: const Text('Pokaż Garmin User ID (do Data Viewera)'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _isConnectingGarmin ? null : _disconnectGarmin,
                              child: const Text('Odłącz Garmin'),
                            ),
                          ],
                        );
                      }
                      return FilledButton.icon(
                        onPressed: _isConnectingGarmin ? null : _connectGarmin,
                        icon: _isConnectingGarmin
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.link),
                        label: Text(
                          _isConnectingGarmin ? 'Łączę...' : 'Połącz z Garmin Connect',
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('Błąd: $e'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
