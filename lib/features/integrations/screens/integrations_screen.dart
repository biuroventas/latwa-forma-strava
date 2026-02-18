import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
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
      if (mounted) {
        SuccessMessage.show(context, 'Strava połączona pomyślnie');
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
      final tokens = await _garminService.exchangeCode(code, verifier);
      final expiresAt = DateTime.now().add(Duration(seconds: tokens.expiresIn));
      await _supabaseService.upsertGarminIntegration(
        userId: userId,
        accessToken: tokens.accessToken,
        expiresAt: expiresAt,
        refreshToken: tokens.refreshToken,
      );
      ref.invalidate(garminIntegrationProvider);
      if (mounted) {
        SuccessMessage.show(context, 'Garmin Connect połączony pomyślnie');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd Garmin: $e')),
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
              'Dodaj GARMIN_CLIENT_ID i GARMIN_CLIENT_SECRET do pliku .env (po zatwierdzeniu programu).',
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
    await _supabaseService.deleteGarminIntegration(userId);
    ref.invalidate(garminIntegrationProvider);
    if (mounted) SuccessMessage.show(context, 'Garmin Connect odłączony');
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

    if (expiresAt != null && DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)))) {
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

    setState(() => _isSyncingGarmin = true);
    try {
      final activities = await _garminService.fetchActivities(accessToken!);
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
        SuccessMessage.show(
          context,
          imported > 0
              ? 'Zaimportowano $imported aktywności z Garmin'
              : 'Brak nowych aktywności do importu',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd synchronizacji Garmin: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncingGarmin = false);
    }
  }

  Future<void> _disconnectStrava() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;
    await _supabaseService.deleteStravaIntegration(userId);
    ref.invalidate(stravaIntegrationProvider);
    if (mounted) SuccessMessage.show(context, 'Strava odłączona');
  }

  Future<void> _syncStrava() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    final integration = await _supabaseService.getStravaIntegration(userId);
    if (integration == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najpierw połącz konto Strava')),
        );
      }
      return;
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

      if (mounted) {
        SuccessMessage.show(
          context,
          imported > 0
              ? 'Zaimportowano $imported aktywności ze Strava'
              : 'Brak nowych aktywności do importu',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd synchronizacji: $e')),
        );
      }
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
          if (!_stravaService.isConfigured)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Strava nie jest skonfigurowana. Dodaj STRAVA_CLIENT_ID i STRAVA_CLIENT_SECRET do pliku .env (załóż aplikację na strava.com/settings/api).',
                  style: Theme.of(context).textTheme.bodyMedium,
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
