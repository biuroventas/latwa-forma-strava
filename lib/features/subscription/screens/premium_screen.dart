import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/store_product_ids.dart';
import '../../../core/constants/trial_constants.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/auth_link_service.dart';
import '../../../shared/services/revenuecat_service.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/widgets/health_disclaimer.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../legal/legal_document_screen.dart';


class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

/// Plan subskrypcji: miesięczny, roczny (subskrypcja) lub roczny jednorazowo (web: tylko BLIK).
enum _PremiumPlan { monthly, yearly, yearlyOnce }

class _PremiumScreenState extends ConsumerState<PremiumScreen> with WidgetsBindingObserver {
  bool _isActivating = false;
  bool _isLoadingStripe = false;
  bool _isLoadingPortal = false;
  bool _isLoadingIap = false;
  bool _isRestoring = false;
  _PremiumPlan _selectedPlan = kIsWeb ? _PremiumPlan.yearlyOnce : _PremiumPlan.yearly;
  String _monthlyPriceLabel = StoreProductIds.monthlyPriceLabel;
  String _yearlyPriceLabel = StoreProductIds.yearlyPriceLabel;
  String _yearlyOncePriceLabel = StoreProductIds.yearlyPriceLabel;
  String _yearlyPerMonthLabel = StoreProductIds.yearlyPerMonthLabel;
  final _loginEmailController = TextEditingController();
  final _loginCodeController = TextEditingController();
  final _promoController = TextEditingController();
  bool _showPromoField = false;
  String? _loginEmail;
  bool _loginCodeSent = false;
  bool _isSendingCode = false;
  bool _isVerifying = false;
  bool _isSigningInWithGoogle = false;
  bool _isSigningInWithApple = false;
  /// 'update_with_current' = zaktualizuj konto danymi z urządzenia; 'restore_account' = przywróć dane konta
  String? _mergeChoice;
  String? _anonymousUserIdForMerge;

  String? _priceLocale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStorePrices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_priceLocale == code) return;
    final first = _priceLocale == null;
    _priceLocale = code;
    _yearlyPerMonthLabel = context.l10n.premYearlyPerMonthFallback;
    if (!first) setState(() {});
    _loadStorePrices();
  }

  Future<void> _loadStorePrices() async {
    if (kIsWeb) return;
    final prices = await RevenueCatService.instance.loadPlanPrices();
    if (!mounted || prices == null) return;
    setState(() {
      _monthlyPriceLabel = prices.monthlyLabel;
      _yearlyPriceLabel = prices.yearlyLabel;
      if (prices.yearlyOnceLabel != null) {
        _yearlyOncePriceLabel = prices.yearlyOnceLabel!;
      }
      if (prices.yearlyPerMonthLabel != null) {
        _yearlyPerMonthLabel = prices.yearlyPerMonthLabel!;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loginEmailController.dispose();
    _loginCodeController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(profileProvider);
      if (mounted) setState(() {});
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
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLoginCode() async {
    final email = _loginEmailController.text.trim();
    if (email.isEmpty) {
      await _showMessageDialog(context.l10n.commonWarning, context.l10n.premEnterEmail);
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
              title: Text(context.l10n.premCodeSent),
              content: SingleChildScrollView(
                child: Text(linkResult.infoMessage ?? context.l10n.premCodeSentBody(email: email)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(context.l10n.commonOk),
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
              await _showMessageDialog(context.l10n.premSignedIn, context.l10n.premSignedInBuy);
            }
          }
        } else {
          if (mounted) await _showMessageDialog(context.l10n.commonError, signInResult.errorMessage ?? context.l10n.commonError);
        }
        return;
      }
      if (mounted) await _showMessageDialog(context.l10n.commonError, linkResult.errorMessage ?? context.l10n.commonError);
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
            title: Text(context.l10n.premCodeSent),
            content: SingleChildScrollView(
              child: Text(result.infoMessage ?? context.l10n.premCodeSentBody(email: email)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.commonOk),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) await _showMessageDialog(context.l10n.commonError, result.errorMessage ?? context.l10n.commonError);
    }
  }

  Future<String?> _showAccountConflictDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.premAccountExistsTitle),
        content: SingleChildScrollView(
          child: Text(context.l10n.premAccountExistsBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('restore_account'),
            child: Text(context.l10n.premRestoreAccountData),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('update_with_current'),
            child: Text(context.l10n.premUpdateWithCurrent),
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
            title: Text(context.l10n.premConfirmIdentity),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.premVerifyEmailSent(email: email),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.premVerificationCode,
                      hintText: context.l10n.premCodeHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: verifying ? null : () => Navigator.of(ctx).pop(false),
                child: Text(context.l10n.commonClose),
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
                                title: Text(context.l10n.commonWarning),
                                content: Text(context.l10n.premEnterFullCode),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dctx).pop(),
                                    child: Text(context.l10n.commonOk),
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
                                      title: Text(context.l10n.commonWarning),
                                      content: SingleChildScrollView(
                                        child: Text(context.l10n.premLoggedInMergeError(error: '$err')),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dctx).pop(),
                                          child: Text(context.l10n.commonOk),
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
                                    title: Text(context.l10n.commonWarning),
                                    content: SingleChildScrollView(
                                      child: Text(context.l10n.premLoggedInMergeError(error: '$e')),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dctx).pop(),
                                        child: Text(context.l10n.commonOk),
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
                                title: Text(context.l10n.premVerifyErrorTitle),
                                content: SingleChildScrollView(
                                  child: Text(result.errorMessage ?? context.l10n.premVerifyErrorBody),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dctx).pop(),
                                    child: Text(context.l10n.commonOk),
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
                    : Text(context.l10n.premConfirm),
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
      await _showMessageDialog(context.l10n.commonWarning, context.l10n.premEnterFullCode);
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
            if (mounted) await _showMessageDialog(context.l10n.commonWarning, context.l10n.premLoggedInMergeError(error: '$err'));
          }
        } catch (e) {
          if (mounted) await _showMessageDialog(context.l10n.commonWarning, context.l10n.premLoggedInMergeError(error: '$e'));
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
        await _showMessageDialog(context.l10n.premSignedIn, context.l10n.premSignedInBuy);
      }
    } else {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.premVerifyErrorTitle),
            content: SingleChildScrollView(
              child: Text(result.errorMessage ?? context.l10n.premVerifyErrorBody),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.commonOk),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Wywołuje Edge Function create-checkout-session przez HTTP z tokenem (bez bramki JWT – płatność działa od razu).
  Future<({int status, Map<String, dynamic>? data})> _invokeCreateCheckoutSession(
    String token,
    String plan, {
    String? promoCode,
  }) async {
    final url = Uri.parse('${SupabaseConfig.functionsBaseUrl}/create-checkout-session');
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'plan': plan,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      }),
    );
    Map<String, dynamic>? data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>?;
      } catch (_) {}
    }
    return (status: res.statusCode, data: data);
  }

  /// Otwiera Stripe Checkout (Edge Function tworzy sesję, zwraca URL).
  /// Tylko na webie – na mobile używamy IAP (RevenueCat).
  Future<void> _openStripeCheckout() async {
    if (!kIsWeb) {
      await _purchaseWithIap();
      return;
    }
    setState(() => _isLoadingStripe = true);
    try {
      Session? session;
      try {
        final authResponse = await SupabaseConfig.auth.refreshSession();
        session = authResponse.session;
        if (session != null && kIsWeb) {
          await SupabaseConfig.auth.setSession(session.refreshToken ?? session.accessToken);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (_) {
        session = null;
      }
      if (session == null) {
        if (!mounted) return;
        setState(() => _isLoadingStripe = false);
        await _showMessageDialog(
          context.l10n.premConnErrorTitle,
          context.l10n.premConnErrorBody,
        );
        return;
      }
      if (session.user.isAnonymous) {
        if (!mounted) return;
        setState(() => _isLoadingStripe = false);
        await _showMessageDialog(
          context.l10n.commonWarning,
          context.l10n.premLoginToBuy,
        );
        return;
      }

      final plan = _selectedPlan == _PremiumPlan.yearlyOnce
          ? 'yearly_once'
          : _selectedPlan == _PremiumPlan.yearly
              ? 'yearly'
              : 'monthly';
      final promoCode = _promoController.text.trim();
      if (promoCode.isNotEmpty && plan == 'yearly_once') {
        if (!mounted) return;
        setState(() => _isLoadingStripe = false);
        await _showMessageDialog(
          context.l10n.premCodeLabel,
          context.l10n.premCodeNotForOnce,
        );
        return;
      }
      var token = session.accessToken;
      var result = await _invokeCreateCheckoutSession(
        token,
        plan,
        promoCode: promoCode,
      );

      if (!mounted) return;

      const retryDelays = [500, 900, 1200];
      for (int retry = 0; retry < 3 && result.status == 401 && mounted; retry++) {
        await Future.delayed(Duration(milliseconds: retryDelays[retry]));
        try {
          final authResponse = await SupabaseConfig.auth.refreshSession();
          final retrySession = authResponse.session;
          if (retrySession != null) {
            if (kIsWeb) await SupabaseConfig.auth.setSession(retrySession.refreshToken ?? retrySession.accessToken);
            token = retrySession.accessToken;
            result = await _invokeCreateCheckoutSession(
              token,
              plan,
              promoCode: promoCode,
            );
          } else {
            break;
          }
        } catch (_) {
          break;
        }
      }

      if (!mounted) return;
      if (result.status == 401) {
        setState(() => _isLoadingStripe = false);
        final data = result.data;
        final errorMsg = data?['error'] as String?;
        final detail = data?['detail'] as String?;
        final hint = context.l10n.premTryLaterContact;
        final fullMsg = [
          errorMsg,
          if (detail != null && detail.isNotEmpty) detail,
          hint,
        ].where((e) => e != null && e.toString().isNotEmpty).join('\n\n');
        await _showMessageDialog(context.l10n.premOpenPaymentFailed, fullMsg);
        return;
      }

      final data = result.data;
      final urlString = data?['url'] as String?;
      final errorMsg = data?['error'] as String?;

      if (urlString != null && urlString.isNotEmpty) {
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!mounted) return;
          ref.invalidate(profileProvider);
        } else {
          if (mounted) await _showMessageDialog(context.l10n.commonError, context.l10n.premCannotOpenPaymentPage);
        }
      } else {
        if (mounted) await _showMessageDialog(context.l10n.commonError, errorMsg ?? context.l10n.premCheckoutSessionError);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final is401 = msg.contains('401') || msg.contains('Invalid JWT');
      final hint = context.l10n.premTryLaterContactShort;
      await _showMessageDialog(is401 ? context.l10n.premOpenPaymentFailed : context.l10n.commonError, hint);
    } finally {
      if (mounted) setState(() => _isLoadingStripe = false);
    }
  }

  Future<void> _onHaveCode() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null || user.isAnonymous) {
      await _showMessageDialog(
        context.l10n.commonWarning,
        context.l10n.premLoginToUseCode,
      );
      return;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await RevenueCatService.instance.logIn(user.id);
        await RevenueCatService.instance.presentAppleOfferCodeSheet();
        if (!mounted) return;
        ref.invalidate(profileProvider);
      } catch (_) {
        if (!mounted) return;
        await _showMessageDialog(
          context.l10n.premCodeLabel,
          context.l10n.premCodeSheetFailed,
        );
      }
      return;
    }
    setState(() => _showPromoField = true);
  }

  Future<void> _redeemOnPlay() async {
    final user = SupabaseConfig.auth.currentUser;
    final l10n = context.l10n;
    if (user == null || user.isAnonymous) {
      await _showMessageDialog(
        l10n.commonWarning,
        l10n.premLoginToUseCode,
      );
      return;
    }
    await RevenueCatService.instance.logIn(user.id);
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      await _showMessageDialog(l10n.premCodeLabel, l10n.premEnterCode);
      return;
    }
    final uri = Uri.parse(
      'https://play.google.com/redeem?code=${Uri.encodeComponent(code)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      await _showMessageDialog(l10n.premCodeLabel, l10n.premPlayStoreFailed);
    }
  }

  /// Zakup Premium przez App Store / Play Billing (RevenueCat).
  Future<void> _purchaseWithIap() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null || user.isAnonymous) {
      await _showMessageDialog(
        context.l10n.commonWarning,
        context.l10n.premLoginToBuyMobile,
      );
      return;
    }
    setState(() => _isLoadingIap = true);
    try {
      await RevenueCatService.instance.logIn(user.id);
      final plan = switch (_selectedPlan) {
        _PremiumPlan.monthly => StorePremiumPlan.monthly,
        _PremiumPlan.yearly => StorePremiumPlan.yearly,
        _PremiumPlan.yearlyOnce => StorePremiumPlan.yearlyOnce,
      };
      final ok = await RevenueCatService.instance.purchasePlan(plan: plan);
      if (ok) {
        final now = DateTime.now();
        final expires = _selectedPlan == _PremiumPlan.monthly
            ? DateTime(now.year, now.month + 1, now.day)
            : DateTime(now.year + 1, now.month, now.day);
        await SupabaseService().updateSubscriptionTier(
          user.id,
          tier: 'premium',
          expiresAt: expires,
        );
      }
      if (!mounted) return;
      ref.invalidate(profileProvider);
      // Webhook może chwilę potrwać – kilka odświeżeń profilu.
      for (var i = 0; i < 4; i++) {
        await Future<void>.delayed(Duration(milliseconds: 600 + i * 400));
        if (!mounted) return;
        ref.invalidate(profileProvider);
      }
      if (!mounted) return;
      if (ok) {
        await _showMessageDialog(
          context.l10n.premTitle,
          context.l10n.premThanksActive,
        );
      } else {
        await _showMessageDialog(
          context.l10n.premInfo,
          context.l10n.premPurchasePending,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      if (msg.contains('purchase_cancelled') ||
          msg.contains('cancelled') ||
          msg.contains('canceled') ||
          msg.contains('user cancelled')) {
        return;
      }
      await _showMessageDialog(
        context.l10n.premPurchaseErrorTitle,
        context.l10n.premPurchaseErrorBody(error: '$e'),
      );
    } finally {
      if (mounted) setState(() => _isLoadingIap = false);
    }
  }

  Future<void> _restorePurchases() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null || user.isAnonymous) {
      await _showMessageDialog(context.l10n.commonWarning, context.l10n.premLoginToRestore);
      return;
    }
    setState(() => _isRestoring = true);
    try {
      await RevenueCatService.instance.logIn(user.id);
      final ok = await RevenueCatService.instance.restorePurchases();
      if (ok) {
        await SupabaseService().updateSubscriptionTier(user.id, tier: 'premium');
      }
      if (!mounted) return;
      ref.invalidate(profileProvider);
      for (var i = 0; i < 3; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        ref.invalidate(profileProvider);
      }
      if (!mounted) return;
      await _showMessageDialog(
        ok ? context.l10n.premRestoredTitle : context.l10n.premNoPurchasesTitle,
        ok
            ? context.l10n.premRestoredBody
            : context.l10n.premNoPurchasesBody,
      );
    } catch (e) {
      if (!mounted) return;
      await _showMessageDialog(context.l10n.commonError, context.l10n.premRestoreFailed(error: '$e'));
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _manageMobileSubscription() async {
    final uri = Uri.parse(
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      await _showMessageDialog(
        context.l10n.premSubscription,
        context.l10n.premManageHint,
      );
    }
  }

  /// Otwiera Stripe Customer Portal – zarządzanie subskrypcją, rezygnacja (miesięczna lub roczna).
  /// Przy 401 próbuje raz odświeżyć sesję (używa sesji z refreshSession) i ponowić żądanie.
  Future<void> _openPortalSession() async {
    if (!kIsWeb) {
      await _manageMobileSubscription();
      return;
    }
    setState(() => _isLoadingPortal = true);
    try {
      Session? session;
      try {
        final authResponse = await SupabaseConfig.auth.refreshSession();
        session = authResponse.session ?? SupabaseConfig.auth.currentSession;
      } catch (_) {
        session = SupabaseConfig.auth.currentSession;
      }
      if (session == null) {
        if (!mounted) return;
        setState(() => _isLoadingPortal = false);
        await _showMessageDialog(context.l10n.premSessionExpired, context.l10n.premLoginAgain);
        return;
      }

      var token = session.accessToken;
      var response = await SupabaseConfig.client.functions.invoke(
        'create-portal-session',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;

      if (response.status == 401) {
        if (kIsWeb) await Future.delayed(const Duration(milliseconds: 400));
        final authResponse = await SupabaseConfig.auth.refreshSession();
        final retrySession = authResponse.session ?? SupabaseConfig.auth.currentSession;
        if (retrySession != null) {
          token = retrySession.accessToken;
          response = await SupabaseConfig.client.functions.invoke(
            'create-portal-session',
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }

      if (!mounted) return;
      if (response.status == 401) {
        setState(() => _isLoadingPortal = false);
        final portalHint = kIsWeb
            ? context.l10n.premPortalHintWeb
            : context.l10n.premPortalHintMobile;
        await _showMessageDialog(context.l10n.premSessionExpired, portalHint);
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
          if (mounted) await _showMessageDialog(context.l10n.commonError, context.l10n.premCannotOpenPortal);
        }
      } else {
        if (mounted) await _showMessageDialog(context.l10n.commonError, errorMsg ?? context.l10n.premPortalOpenError);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final is401 = msg.contains('401') || msg.contains('Invalid JWT');
      await _showMessageDialog(
        context.l10n.commonError,
        is401
            ? context.l10n.premSessionExpiredCancel
            : context.l10n.premErrorWithDetail(error: '$e'),
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
      await _showMessageDialog(context.l10n.premTitle, context.l10n.premActivatedEnjoy);
    } catch (e) {
      if (!mounted) return;
      await _showMessageDialog(context.l10n.commonError, context.l10n.premErrorWithDetail(error: '$e'));
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
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: Text(context.l10n.premTitle),
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
                    isPremium ? context.l10n.premHavePremium : context.l10n.premUnlockPotential,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.l10n.premAllFeaturesAvailable,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (isPremium && expiresAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.l10n.premValidUntil(date: _formatDate(expiresAt)),
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
                            context.l10n.premTrialTitle,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.premTrialBody(
                          remaining: trialRemaining != null
                              ? context.l10n.premTrialLeft(
                                  hours: trialRemaining.inHours,
                                  minutes: trialRemaining.inMinutes % 60,
                                )
                              : '',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!isPremium) ...[
              _buildFeatureRow(context, icon: Icons.calendar_today, label: context.l10n.premFeatHistoryOtherDays),
              _buildFeatureRow(context, icon: Icons.pie_chart_outline, label: context.l10n.premFeatMacrosDash),
              _buildFeatureRow(context, icon: Icons.psychology, label: context.l10n.premFeatAiAdvice),
              _buildFeatureRow(context, icon: Icons.camera_alt, label: context.l10n.premFeatAiPhoto),
              _buildFeatureRow(context, icon: Icons.restaurant_menu, label: context.l10n.premFeatIngredients),
              _buildFeatureRow(context, icon: Icons.storefront, label: context.l10n.premFeatEatingOut),
              _buildFeatureRow(context, icon: Icons.directions_run, label: context.l10n.premFeatQuickActivity),
              _buildFeatureRow(context, icon: Icons.share, label: context.l10n.premFeatShare),
              _buildFeatureRow(context, icon: Icons.picture_as_pdf, label: context.l10n.premFeatPdf),
              _buildFeatureRow(context, icon: Icons.tune, label: context.l10n.premFeatCustomCalories),
              _buildFeatureRow(context, icon: Icons.balance, label: context.l10n.premFeatCustomMacros),
              _buildFeatureRow(context, icon: Icons.sync, label: context.l10n.premFeatStrava),
              _buildFeatureRow(context, icon: Icons.emoji_events, label: context.l10n.premFeatGoals),
              const SizedBox(height: 24),
              if (!isLoggedIn) _buildLoginToBuyCard(context) else ...[
              Text(
                context.l10n.premChoosePlan,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                context,
                plan: _PremiumPlan.monthly,
                title: context.l10n.premPlanMonthly,
                price: _monthlyPriceLabel,
                period: context.l10n.premPlanMonthlyPeriod,
              ),
              const SizedBox(height: 8),
              _buildPlanCard(
                context,
                plan: _PremiumPlan.yearly,
                title: context.l10n.premPlanYearly,
                price: _yearlyPriceLabel,
                period: context.l10n.premPlanYearlyPeriod,
                badge: context.l10n.premBadgeSave,
                priceSubtitle: _yearlyPerMonthLabel,
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                _buildPlanCard(
                  context,
                  plan: _PremiumPlan.yearlyOnce,
                  title: context.l10n.premPlanYearlyOnce,
                  price: _yearlyOncePriceLabel,
                  period: context.l10n.premPlanYearlyOncePeriod,
                  badge: context.l10n.premBadgeBlik,
                  priceSubtitle: context.l10n.premYearlyOnceSubtitle,
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: (_isLoadingStripe || _isLoadingIap) ? null : _onHaveCode,
                  child: Text(context.l10n.premHaveCode),
                ),
              ),
              if (_showPromoField && (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS)) ...[
                TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.premCodeLabel,
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: kIsWeb
                        ? null
                        : IconButton(
                            tooltip: context.l10n.premRedeemTooltip,
                            onPressed: _redeemOnPlay,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                  ),
                  onSubmitted: kIsWeb ? null : (_) => _redeemOnPlay(),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: (_isLoadingStripe || _isLoadingIap)
                    ? null
                    : (kIsWeb ? _openStripeCheckout : _purchaseWithIap),
                icon: (_isLoadingStripe || _isLoadingIap)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.workspace_premium),
                label: Text(
                  (_isLoadingStripe || _isLoadingIap)
                      ? (kIsWeb ? context.l10n.premOpeningPayment : context.l10n.premProcessingPurchase)
                      : context.l10n.premBuy,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isRestoring ? null : _restorePurchases,
                  icon: _isRestoring
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore),
                  label: Text(_isRestoring ? context.l10n.premRestoring : context.l10n.premRestorePurchases),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kIsWeb
                        ? context.l10n.premPaymentNoteWeb
                        : context.l10n.premPaymentNoteMobile,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.premAutoActivate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => openLegalOrExternal(
                          context,
                          AppConstants.privacyPolicyUrl,
                        ),
                        child: Text(context.l10n.premPrivacy),
                      ),
                      TextButton(
                        onPressed: () => openLegalOrExternal(
                          context,
                          AppConstants.termsUrl,
                        ),
                        child: Text(context.l10n.premTerms),
                      ),
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(AppConstants.appleEulaUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(context.l10n.premEula),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const HealthDisclaimer(compact: true),
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
                  label: Text(_isActivating ? context.l10n.premActivating : context.l10n.premActivateTest),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
              ],
            ] else ...[
              Text(
                context.l10n.premAvailableFeatures,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(context, icon: Icons.calendar_today, label: context.l10n.premFeatActiveHistory, isActive: true),
              _buildFeatureRow(context, icon: Icons.pie_chart_outline, label: context.l10n.premFeatActiveMacros, isActive: true),
              _buildFeatureRow(context, icon: Icons.psychology, label: context.l10n.premFeatAiAdvice, isActive: true),
              _buildFeatureRow(context, icon: Icons.camera_alt, label: context.l10n.premFeatActiveAiPhoto, isActive: true),
              _buildFeatureRow(context, icon: Icons.restaurant_menu, label: context.l10n.premFeatActiveIngredients, isActive: true),
              _buildFeatureRow(context, icon: Icons.storefront, label: context.l10n.premFeatActiveEatingOut, isActive: true),
              _buildFeatureRow(context, icon: Icons.directions_run, label: context.l10n.premFeatActiveQuickActivity, isActive: true),
              _buildFeatureRow(context, icon: Icons.share, label: context.l10n.premFeatActiveShare, isActive: true),
              _buildFeatureRow(context, icon: Icons.picture_as_pdf, label: context.l10n.premFeatActivePdf, isActive: true),
              _buildFeatureRow(context, icon: Icons.tune, label: context.l10n.premFeatActiveCalories, isActive: true),
              _buildFeatureRow(context, icon: Icons.balance, label: context.l10n.premFeatActiveMacrosCustom, isActive: true),
              _buildFeatureRow(context, icon: Icons.sync, label: context.l10n.premFeatActiveStrava, isActive: true),
              _buildFeatureRow(context, icon: Icons.emoji_events, label: context.l10n.premFeatActiveGoals, isActive: true),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoadingPortal
                    ? null
                    : (kIsWeb ? _openPortalSession : _manageMobileSubscription),
                icon: _isLoadingPortal
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.settings),
                label: Text(
                  _isLoadingPortal
                      ? context.l10n.premOpening
                      : (kIsWeb ? context.l10n.premCancelSub : context.l10n.premManageSub),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? context.l10n.premCancelNoteWeb
                    : context.l10n.premCancelNoteMobile,
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
    await _handleSocialLoginResult(result);
  }

  Future<void> _signInWithApple() async {
    setState(() => _isSigningInWithApple = true);
    final result = await AuthLinkService().signInWithApple();
    if (!mounted) return;
    setState(() => _isSigningInWithApple = false);
    await _handleSocialLoginResult(result);
  }

  Future<void> _handleSocialLoginResult(AuthLinkResult result) async {
    if (result.canceled || result.redirected) return;
    if (result.success) {
      ref.invalidate(profileProvider);
      if (mounted) setState(() {});
      return;
    }
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      await _showMessageDialog(context.l10n.commonError, result.errorMessage!);
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
              context.l10n.premLoginToBuyCard,
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
              label: Text(_isSigningInWithGoogle ? context.l10n.premSigningIn : context.l10n.premContinueGoogle),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSigningInWithApple ? null : _signInWithApple,
              icon: _isSigningInWithApple
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.apple, size: 22),
              label: Text(_isSigningInWithApple ? context.l10n.premSigningIn : context.l10n.premContinueApple),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.premOrEmail,
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
                decoration: InputDecoration(
                  labelText: context.l10n.premEmailLabel,
                  hintText: context.l10n.premEmailHint,
                  border: const OutlineInputBorder(),
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
                label: Text(_isSendingCode ? context.l10n.premSending : context.l10n.premSendCode),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ] else ...[
              Text(
                context.l10n.premConfirmIdentityHint,
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
                decoration: InputDecoration(
                  labelText: context.l10n.premVerificationCode,
                  hintText: context.l10n.premCodeHint,
                  border: const OutlineInputBorder(),
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
                label: Text(_isVerifying ? context.l10n.premChecking : context.l10n.premConfirmAndSignIn),
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
                child: Text(context.l10n.premResendOtherEmail),
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
    final radioColor = isSelected ? WidgetStateProperty.all(colorScheme.onPrimary) : null;

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
                // ignore: deprecated_member_use -- RadioGroup refactor deferred
                groupValue: _selectedPlan,
                // ignore: deprecated_member_use -- RadioGroup refactor deferred
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
