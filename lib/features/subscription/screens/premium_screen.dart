import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/trial_constants.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../shared/services/auth_link_service.dart';
import '../../../shared/services/supabase_service.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

/// Plan subskrypcji: miesięczny, roczny (subskrypcja) lub roczny jednorazowo (BLIK + karta).
enum _PremiumPlan { monthly, yearly, yearlyOnce }

class _PremiumScreenState extends ConsumerState<PremiumScreen> with WidgetsBindingObserver {
  bool _isActivating = false;
  bool _isLoadingStripe = false;
  bool _isLoadingPortal = false;
  _PremiumPlan _selectedPlan = _PremiumPlan.yearlyOnce;
  final _loginEmailController = TextEditingController();
  final _loginCodeController = TextEditingController();
  String? _loginEmail;
  bool _loginCodeSent = false;
  bool _isSendingCode = false;
  bool _isVerifying = false;
  bool _isSigningInWithGoogle = false;
  /// 'update_with_current' = zaktualizuj konto danymi z urządzenia; 'restore_account' = przywróć dane konta
  String? _mergeChoice;
  String? _anonymousUserIdForMerge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loginEmailController.dispose();
    _loginCodeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(profileProvider);
    }
  }

  /// Pokazuje komunikat w okienku dialogowym – użytkownik może spokojnie przeczytać i zamknąć.
  Future<void> _showMessageDialog(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLoginCode() async {
    final email = _loginEmailController.text.trim();
    if (email.isEmpty) {
      await _showMessageDialog('Uwaga', 'Podaj adres e-mail.');
      return;
    }
    final user = SupabaseConfig.auth.currentUser;
    final isAnonymous = user != null && user.isAnonymous;

    setState(() => _isSendingCode = true);
    if (isAnonymous) {
      final linkResult = await AuthLinkService().linkWithEmail(email);
      if (!mounted) return;
      setState(() => _isSendingCode = false);
      if (linkResult.success) {
        setState(() {
          _loginEmail = email;
          _loginCodeSent = true;
        });
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Kod wysłany'),
              content: SingleChildScrollView(
                child: Text(linkResult.infoMessage ?? 'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – kliknij link w mailu albo wpisz kod poniżej.'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
      if (linkResult.suggestSignOutAndLogin) {
        final choice = await _showAccountConflictDialog();
        if (!mounted || choice == null) return;
        setState(() {
          _mergeChoice = choice;
          if (choice == 'update_with_current') _anonymousUserIdForMerge = user.id;
          _isSendingCode = true;
        });
        final signInResult = await AuthLinkService().signInWithEmail(email);
        if (!mounted) return;
        setState(() => _isSendingCode = false);
        if (signInResult.success) {
          setState(() => _loginEmail = email);
          if (!mounted) return;
          final verified = await _showVerificationCodeDialog(
            email: email,
            mergeChoice: choice,
            anonymousUserId: choice == 'update_with_current' ? user.id : null,
          );
          if (!mounted) return;
          if (verified == true) {
            setState(() {
              _loginEmail = null;
              _mergeChoice = null;
              _anonymousUserIdForMerge = null;
              _loginEmailController.clear();
              _loginCodeController.clear();
            });
            ref.invalidate(profileProvider);
            if (mounted) {
              await _showMessageDialog('Zalogowano', 'Możesz teraz wykupić Premium.');
            }
          }
        } else {
          if (mounted) await _showMessageDialog('Błąd', signInResult.errorMessage ?? 'Błąd');
        }
        return;
      }
      if (mounted) await _showMessageDialog('Błąd', linkResult.errorMessage ?? 'Błąd');
      return;
    }
    final result = await AuthLinkService().signInWithEmail(email);
    if (!mounted) return;
    setState(() => _isSendingCode = false);
    if (result.success) {
      setState(() {
        _loginEmail = email;
        _loginCodeSent = true;
      });
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Kod wysłany'),
            content: SingleChildScrollView(
              child: Text(result.infoMessage ?? 'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – kliknij link w mailu albo wpisz kod poniżej.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) await _showMessageDialog('Błąd', result.errorMessage ?? 'Błąd');
    }
  }

  Future<String?> _showAccountConflictDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Konto z tym adresem e-mail istnieje.'),
        content: const SingleChildScrollView(
          child: Text(
            'Próbujesz się zalogować na konto powiązane z tym adresem e-mail. '
            'Na tym urządzeniu masz inne dane (profil, posiłki itd.).\n\n'
            'Co chcesz zrobić?\n\n'
            '• Zaktualizować tamto konto – obecnymi danymi z tego urządzenia (profil, posiłki zostaną przeniesione).\n\n'
            '• Przywrócić dane konta – zobaczysz dane przypisane do konta z tym e-mailem (obecne dane z urządzenia nie będą użyte).\n\n'
            'W obu przypadkach musisz potwierdzić tożsamość – kliknij link w mailu lub wpisz kod weryfikacyjny.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('restore_account'),
            child: const Text('Przywróć dane konta'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('update_with_current'),
            child: const Text('Zaktualizuj konto tymi danymi'),
          ),
        ],
      ),
    );
  }

  /// Okienko z informacją i polem na kod – do zamknięcia; po zatwierdzeniu weryfikacja i ewentualny merge.
  Future<bool?> _showVerificationCodeDialog({
    required String email,
    required String? mergeChoice,
    required String? anonymousUserId,
  }) async {
    final codeController = TextEditingController();
    try {
      bool verifying = false;
      return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Potwierdź tożsamość'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Wysłaliśmy wiadomość na $email. '
                    'Możesz kliknąć link weryfikacyjny w mailu albo wpisać kod poniżej (sprawdź też folder Spam).',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Kod weryfikacyjny',
                      hintText: 'np. 123456',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: verifying ? null : () => Navigator.of(ctx).pop(false),
                child: const Text('Zamknij'),
              ),
              FilledButton(
                onPressed: verifying
                    ? null
                    : () async {
                        final code = codeController.text.trim().replaceAll(RegExp(r'\s'), '');
                        if (code.length < 6) {
                          if (context.mounted) {
                            await showDialog<void>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                title: const Text('Uwaga'),
                                content: const Text('Wpisz pełny kod z maila (min. 6 znaków).'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return;
                        }
                        setDialogState(() => verifying = true);
                        final result = await AuthLinkService().verifyEmailOtp(email, code);
                        if (!context.mounted) return;
                        setDialogState(() => verifying = false);
                        if (result.success) {
                          if (mergeChoice == 'update_with_current' && anonymousUserId != null && context.mounted) {
                            setDialogState(() => verifying = true);
                            try {
                              final mergeResponse = await SupabaseConfig.client.functions.invoke(
                                'merge-anonymous-data',
                                body: {'anonymous_user_id': anonymousUserId},
                              );
                              if (context.mounted && mergeResponse.status != 200) {
                                final err = mergeResponse.data is Map
                                    ? (mergeResponse.data as Map)['error']
                                    : mergeResponse.status;
                                if (context.mounted) {
                                  await showDialog<void>(
                                    context: context,
                                    builder: (dctx) => AlertDialog(
                                      title: const Text('Uwaga'),
                                      content: SingleChildScrollView(
                                        child: Text('Zalogowano. Błąd przenoszenia danych: $err'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dctx).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                await showDialog<void>(
                                  context: context,
                                  builder: (dctx) => AlertDialog(
                                    title: const Text('Uwaga'),
                                    content: SingleChildScrollView(
                                      child: Text('Zalogowano. Błąd przenoszenia danych: $e'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dctx).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                            if (context.mounted) setDialogState(() => verifying = false);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop(true);
                        } else {
                          if (context.mounted) {
                            await showDialog<void>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                title: const Text('Błąd weryfikacji'),
                                content: SingleChildScrollView(
                                  child: Text(result.errorMessage ?? 'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                child: verifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zatwierdź'),
              ),
            ],
          );
        },
      ),
    );
    } finally {
      codeController.dispose();
    }
  }

  Future<void> _verifyLoginCode() async {
    final email = _loginEmail ?? _loginEmailController.text.trim();
    final code = _loginCodeController.text.trim().replaceAll(RegExp(r'\s'), '');
    if (email.isEmpty || code.length < 6) {
      await _showMessageDialog('Uwaga', 'Wpisz pełny kod z maila (min. 6 znaków).');
      return;
    }
    final anonymousIdToMerge = _anonymousUserIdForMerge;
    final mergeChoice = _mergeChoice;

    setState(() => _isVerifying = true);
    final result = await AuthLinkService().verifyEmailOtp(email, code);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (result.success) {
      if (mergeChoice == 'update_with_current' && anonymousIdToMerge != null && mounted) {
        setState(() => _isVerifying = true);
        try {
          final mergeResponse = await SupabaseConfig.client.functions.invoke(
            'merge-anonymous-data',
            body: {'anonymous_user_id': anonymousIdToMerge},
          );
          if (mounted && mergeResponse.status != 200) {
            final err = mergeResponse.data is Map ? (mergeResponse.data as Map)['error'] : mergeResponse.status;
            if (mounted) await _showMessageDialog('Uwaga', 'Zalogowano. Błąd przenoszenia danych: $err');
          }
        } catch (e) {
          if (mounted) await _showMessageDialog('Uwaga', 'Zalogowano. Błąd przenoszenia danych: $e');
        }
        if (mounted) setState(() => _isVerifying = false);
      }
      setState(() {
        _loginCodeSent = false;
        _loginEmail = null;
        _mergeChoice = null;
        _anonymousUserIdForMerge = null;
        _loginEmailController.clear();
        _loginCodeController.clear();
      });
      ref.invalidate(profileProvider);
      if (mounted) {
        await _showMessageDialog('Zalogowano', 'Możesz teraz wykupić Premium.');
      }
    } else {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Błąd weryfikacji'),
            content: SingleChildScrollView(
              child: Text(result.errorMessage ?? 'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Otwiera Stripe Checkout (Edge Function tworzy sesję, zwraca URL).
  Future<void> _openStripeCheckout() async {
    setState(() => _isLoadingStripe = true);
    try {
      try {
        await SupabaseConfig.auth.refreshSession();
      } catch (_) {}
      final session = SupabaseConfig.auth.currentSession;
      if (session == null || session.user.isAnonymous) {
        if (!mounted) return;
        setState(() => _isLoadingStripe = false);
        await _showMessageDialog(
          'Uwaga',
          'Aby wykupić Premium, zaloguj się (Google lub e-mail z kodem powyżej).',
        );
        return;
      }

      final plan = _selectedPlan == _PremiumPlan.yearlyOnce
          ? 'yearly_once'
          : _selectedPlan == _PremiumPlan.yearly
              ? 'yearly'
              : 'monthly';
      final token = session.accessToken;
      final response = await SupabaseConfig.client.functions.invoke(
        'create-checkout-session',
        body: {'plan': plan},
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.status == 401) {
        setState(() => _isLoadingStripe = false);
        final data = response.data as Map<String, dynamic>?;
        final errorMsg = data?['error'] as String?;
        final detail = data?['detail'] as String?;
        final fullMsg = [
          errorMsg,
          if (detail != null && detail.isNotEmpty) detail,
          'Wyloguj się w profilu i zaloguj ponownie, potem spróbuj wykupić Premium.',
        ].where((e) => e != null && e.toString().isNotEmpty).join('\n\n');
        await _showMessageDialog('Sesja wygasła', fullMsg);
        return;
      }

      final data = response.data as Map<String, dynamic>?;
      final urlString = data?['url'] as String?;
      final errorMsg = data?['error'] as String?;

      if (urlString != null && urlString.isNotEmpty) {
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!mounted) return;
          ref.invalidate(profileProvider);
        } else {
          if (mounted) await _showMessageDialog('Błąd', 'Nie można otworzyć strony płatności.');
        }
      } else {
        if (mounted) await _showMessageDialog('Błąd', errorMsg ?? 'Błąd tworzenia sesji płatności.');
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final is401 = msg.contains('401') || msg.contains('Invalid JWT');
      await _showMessageDialog(
        is401 ? 'Sesja wygasła' : 'Błąd',
        is401
            ? 'Sesja wygasła. Wyloguj się w profilu i zaloguj ponownie, potem spróbuj wykupić Premium jeszcze raz.'
            : 'Błąd: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoadingStripe = false);
    }
  }

  /// Otwiera Stripe Customer Portal – zarządzanie subskrypcją, rezygnacja (miesięczna lub roczna).
  Future<void> _openPortalSession() async {
    setState(() => _isLoadingPortal = true);
    try {
      await SupabaseConfig.auth.refreshSession();
      final session = SupabaseConfig.auth.currentSession;
      if (session == null) {
        if (!mounted) return;
        setState(() => _isLoadingPortal = false);
        await _showMessageDialog('Sesja wygasła', 'Zaloguj się ponownie.');
        return;
      }

      final token = session.accessToken;
      final response = await SupabaseConfig.client.functions.invoke(
        'create-portal-session',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;

      if (response.status == 401) {
        setState(() => _isLoadingPortal = false);
        await _showMessageDialog(
          'Sesja wygasła',
          'Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.',
        );
        return;
      }

      final data = response.data as Map<String, dynamic>?;
      final urlString = data?['url'] as String?;
      final errorMsg = data?['error'] as String?;

      if (urlString != null && urlString.isNotEmpty) {
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!mounted) return;
          ref.invalidate(profileProvider);
        } else {
          if (mounted) await _showMessageDialog('Błąd', 'Nie można otworzyć portalu.');
        }
      } else {
        if (mounted) await _showMessageDialog('Błąd', errorMsg ?? 'Błąd otwierania portalu.');
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final is401 = msg.contains('401') || msg.contains('Invalid JWT');
      await _showMessageDialog(
        'Błąd',
        is401
            ? 'Sesja wygasła. Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.'
            : 'Błąd: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoadingPortal = false);
    }
  }

  Future<void> _activatePremiumTest() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isActivating = true);
    try {
      await SupabaseService().updateSubscriptionTier(userId, tier: 'premium', expiresAt: null);
      ref.invalidate(profileProvider);
      if (!mounted) return;
      await _showMessageDialog('Premium', 'Premium aktywowane. Ciesz się pełnym dostępem!');
    } catch (e) {
      if (!mounted) return;
      await _showMessageDialog('Błąd', 'Błąd: $e');
    } finally {
      if (mounted) setState(() => _isActivating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final isPremium = profile?.isPremium ?? false;
    final isInTrial = ref.watch(isInTrialProvider);
    final firstUseAt = ref.watch(firstUseAtProvider).valueOrNull;
    final expiresAt = profile?.subscriptionExpiresAt;
    final user = SupabaseConfig.auth.currentUser;
    final isLoggedIn = user != null && !user.isAnonymous;

    Duration? trialRemaining;
    if (isInTrial && firstUseAt != null) {
      final elapsed = DateTime.now().difference(firstUseAt);
      trialRemaining = trialDuration - elapsed;
      if (trialRemaining.isNegative) trialRemaining = Duration.zero;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Łatwa Forma Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              child: Column(
                children: [
                  Icon(
                    isPremium ? Icons.workspace_premium : Icons.star_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPremium ? 'Masz Premium!' : 'Odblokuj pełny potencjał',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Wszystkie funkcje premium są dla Ciebie dostępne.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (isPremium && expiresAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Ważne do: ${_formatDate(expiresAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 32),
            if (isInTrial && !isPremium)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Okres próbny (24 h)',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Wszystkie funkcje premium są teraz dostępne. '
                        '${trialRemaining != null ? 'Pozostało: ${trialRemaining.inHours}h ${trialRemaining.inMinutes % 60}min. ' : ''}'
                        'Po tym czasie wykup Premium, żeby zachować dostęp.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isPremium) ...[
              _buildFeatureRow(context, icon: Icons.calendar_today, label: 'Przeglądanie historii innych dni niż dziś'),
              _buildFeatureRow(context, icon: Icons.pie_chart_outline, label: 'Podgląd makroskładników na dashboardzie'),
              _buildFeatureRow(context, icon: Icons.psychology, label: 'Nieograniczona porada AI'),
              _buildFeatureRow(context, icon: Icons.camera_alt, label: 'Analiza AI posiłku ze zdjęcia'),
              _buildFeatureRow(context, icon: Icons.restaurant_menu, label: 'Dodawanie posiłku ze składników'),
              _buildFeatureRow(context, icon: Icons.storefront, label: 'Dodawanie posiłku „na mieście”'),
              _buildFeatureRow(context, icon: Icons.directions_run, label: 'Szybkie dodawanie w aktywnościach'),
              _buildFeatureRow(context, icon: Icons.share, label: 'Udostępnianie tygodniowych statystyk'),
              _buildFeatureRow(context, icon: Icons.picture_as_pdf, label: 'Eksport raportów do PDF'),
              _buildFeatureRow(context, icon: Icons.tune, label: 'Własny cel kaloryczny w edycji profilu'),
              _buildFeatureRow(context, icon: Icons.balance, label: 'Własne makroskładniki w edycji profilu'),
              _buildFeatureRow(context, icon: Icons.sync, label: 'Integracje Strava i Garmin bez limitów'),
              _buildFeatureRow(context, icon: Icons.emoji_events, label: 'Zaawansowane cele i wyzwania'),
              const SizedBox(height: 24),
              if (!isLoggedIn) _buildLoginToBuyCard(context) else ...[
              Text(
                'Wybierz plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                context,
                plan: _PremiumPlan.monthly,
                title: 'Miesięcznie',
                price: '69,98 zł',
                period: 'miesięcznie',
              ),
              const SizedBox(height: 8),
              _buildPlanCard(
                context,
                plan: _PremiumPlan.yearly,
                title: 'Rocznie',
                price: '194,95 zł',
                period: 'rocznie',
                badge: 'Oszczędzasz ~17%',
                priceSubtitle: 'ok. 16,25 zł / miesięcznie',
              ),
              const SizedBox(height: 8),
              _buildPlanCard(
                context,
                plan: _PremiumPlan.yearlyOnce,
                title: 'Rocznie (jednorazowo)',
                price: '194,95 zł',
                period: 'za rok',
                badge: 'BLIK + karta',
                priceSubtitle: 'płatność raz na rok, bez subskrypcji',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoadingStripe ? null : _openStripeCheckout,
                icon: _isLoadingStripe
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.workspace_premium),
                label: Text(_isLoadingStripe ? 'Otwieram płatność…' : 'Wykup Premium (Stripe)'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BLIK, PayPal i karta przy „Rocznie (jednorazowo)”; subskrypcja – karta, Apple Pay, Google Pay.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Po opłaceniu konto Premium aktywuje się automatycznie.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isActivating ? null : _activatePremiumTest,
                  icon: _isActivating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.science),
                  label: Text(_isActivating ? 'Aktywuję…' : 'Aktywuj Premium (test)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
              ],
            ] else ...[
              Text(
                'Dostępne funkcje:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(context, icon: Icons.calendar_today, label: 'Historia innych dni', isActive: true),
              _buildFeatureRow(context, icon: Icons.pie_chart_outline, label: 'Makroskładniki na dashboardzie', isActive: true),
              _buildFeatureRow(context, icon: Icons.psychology, label: 'Nieograniczona porada AI', isActive: true),
              _buildFeatureRow(context, icon: Icons.camera_alt, label: 'Analiza AI posiłku', isActive: true),
              _buildFeatureRow(context, icon: Icons.restaurant_menu, label: 'Posiłek ze składników', isActive: true),
              _buildFeatureRow(context, icon: Icons.storefront, label: 'Posiłek „na mieście”', isActive: true),
              _buildFeatureRow(context, icon: Icons.directions_run, label: 'Szybkie dodawanie aktywności', isActive: true),
              _buildFeatureRow(context, icon: Icons.share, label: 'Udostępnianie statystyk', isActive: true),
              _buildFeatureRow(context, icon: Icons.picture_as_pdf, label: 'Eksport do PDF', isActive: true),
              _buildFeatureRow(context, icon: Icons.tune, label: 'Własny cel kaloryczny', isActive: true),
              _buildFeatureRow(context, icon: Icons.balance, label: 'Własne makroskładniki', isActive: true),
              _buildFeatureRow(context, icon: Icons.sync, label: 'Integracje Strava i Garmin', isActive: true),
              _buildFeatureRow(context, icon: Icons.emoji_events, label: 'Zaawansowane cele', isActive: true),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoadingPortal ? null : _openPortalSession,
                icon: _isLoadingPortal
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.settings),
                label: Text(
                  _isLoadingPortal ? 'Otwieram…' : 'Anuluj subskrypcję',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Możesz anulować subskrypcję. Dostęp do Premium pozostanie do końca opłaconego okresu.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningInWithGoogle = true);
    final result = await AuthLinkService().signInWithGoogle();
    if (!mounted) return;
    setState(() => _isSigningInWithGoogle = false);
    if (result.success && result.infoMessage != null) {
      await _showMessageDialog('Informacja', result.infoMessage!);
    } else if (result.canceled) {
      // użytkownik anulował – bez komunikatu
    } else if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      await _showMessageDialog('Błąd', result.errorMessage!);
    }
  }

  Widget _buildLoginToBuyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aby wykupić Premium, potrzebne jest konto. Zaloguj się przez Google albo podaj adres e-mail – wyślemy wiadomość z linkiem weryfikacyjnym i kodem.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: _isSigningInWithGoogle ? null : _signInWithGoogle,
              icon: _isSigningInWithGoogle
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.g_mobiledata, size: 24),
              label: Text(_isSigningInWithGoogle ? 'Otwieram…' : 'Kontynuuj z Google'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 16),
            Text(
              'lub e-mail:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (!_loginCodeSent) ...[
              TextField(
                controller: _loginEmailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Adres e-mail',
                  hintText: 'np. jan@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSendingCode ? null : _sendLoginCode,
                icon: _isSendingCode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.email),
                label: Text(_isSendingCode ? 'Wysyłam…' : 'Wyślij kod'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ] else ...[
              Text(
                'Potwierdź tożsamość: wpisz poniżej kod z maila albo kliknij link weryfikacyjny w wiadomości (sprawdź też folder Spam).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _loginCodeController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Kod weryfikacyjny',
                  hintText: 'np. 123456',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isVerifying ? null : _verifyLoginCode,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isVerifying ? 'Sprawdzam…' : 'Zatwierdź i zaloguj'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isSendingCode
                    ? null
                    : () {
                        setState(() {
                          _loginCodeSent = false;
                          _loginCodeController.clear();
                        });
                      },
                child: const Text('Wyślij kod ponownie na inny adres'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required _PremiumPlan plan,
    required String title,
    required String price,
    required String period,
    String? badge,
    String? priceSubtitle,
  }) {
    final isSelected = _selectedPlan == plan;
    final colorScheme = Theme.of(context).colorScheme;
    // Zaznaczony plan: zielone tło (primary), biały tekst (onPrimary) dla dobrej czytelności
    final bgColor = isSelected ? colorScheme.primary : Theme.of(context).cardColor;
    final titleColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface;
    final priceColor = isSelected ? colorScheme.onPrimary : colorScheme.primary;
    final subtitleColor = isSelected ? colorScheme.onPrimary.withValues(alpha: 0.9) : colorScheme.onSurfaceVariant;
    final radioColor = isSelected ? MaterialStateProperty.all(colorScheme.onPrimary) : null;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: bgColor,
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<_PremiumPlan>(
                value: plan,
                groupValue: _selectedPlan,
                onChanged: (_) => setState(() => _selectedPlan = plan),
                fillColor: radioColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.onPrimary.withValues(alpha: 0.2)
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isSelected ? colorScheme.onPrimary : Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price / $period',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: priceColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (priceSubtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        priceSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? null : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (isActive) Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
        ],
      ),
    );
  }

}
