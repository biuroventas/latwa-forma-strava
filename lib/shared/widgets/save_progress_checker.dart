import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/auth/sign_out_guard.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/guest/guest_trial.dart';
import '../../../core/router/app_router.dart';
import '../services/auth_link_service.dart';
import '../utils/pending_verification_email.dart';
import 'save_progress_modal.dart';

/// Karta na dashboardzie: ile zostało bez konta, jedno ciche przypomnienie,
/// a po 7 dniach pasek z prośbą o konto. Nowe wpisy blokuje [GuestTrial].
class SaveProgressChecker extends StatefulWidget {
  /// Pokazuje modal „Zapisz postępy” z opcjami Google/Email. Używane na dashboardzie
  /// i z karty w profilu. Przy „Później” tylko zamyka – bez zapisywania.
  static Future<void> showSaveProgressModal(
    BuildContext context, {
    required int mealsCount,
    VoidCallback? onInvalidate,
    bool allowDismiss = true,
    String? titleText,
    String? bodyText,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaveProgressModal(
        mealsCount: mealsCount,
        allowDismiss: allowDismiss,
        titleText: titleText,
        bodyText: bodyText,
        onDismiss: () {},
        onLinkEmail: () => _runLinkEmail(context, onInvalidate),
        onLinkApple: () => _runLinkApple(context, onInvalidate),
        onLinkGoogle: () => _runLinkGoogle(context, onInvalidate),
        onEnterCode: () => _runEnterCodeOnly(context, onInvalidate),
      ),
    );
  }

  static Future<void> _runLinkApple(BuildContext context, VoidCallback? onInvalidate) async {
    await _runLinkFlow(
      context,
      future: AuthLinkService().linkWithApple(),
      onInvalidate: onInvalidate,
      useLoadingDialog: false,
    );
  }

  static Future<void> _runLinkGoogle(BuildContext context, VoidCallback? onInvalidate) async {
    await _runLinkFlow(
      context,
      future: AuthLinkService().linkWithGoogle(),
      onInvalidate: onInvalidate,
      useLoadingDialog: false,
    );
  }

  static Future<void> _runLinkEmail(BuildContext context, VoidCallback? onInvalidate) async {
    // Email nie otwiera przeglądarki – modal „Łączenie konta...” jest OK
    final email = await _showEmailInputDialog(context);
    if (email == null || email.isEmpty || !context.mounted) return;
    await savePendingVerificationEmail(email);
    if (!context.mounted) return;
    await _runLinkFlow(
      context,
      future: AuthLinkService().linkWithEmail(email),
      onInvalidate: onInvalidate,
      useLoadingDialog: true,
      emailForVerification: email,
    );
  }

  /// Dialog: komunikat „wysłaliśmy link i kod” + pole na kod (do zamknięcia, bez SnackBara na dole).
  /// [isSignInFlow] – gdy true (logowanie do istniejącego konta), po weryfikacji pokazuje „Zalogowano” i zamyka nadrzędny modal.
  static Future<void> _showLinkAndCodeDialog(
    BuildContext context,
    String email,
    String? infoMessage,
    VoidCallback? onInvalidate, {
    String? dialogTitle,
    bool isSignInFlow = false,
  }) async {
    final l10n = context.l10n;
    final title = dialogTitle ?? l10n.onbCheckInbox;
    final codeController = TextEditingController();
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                infoMessage ??
                    l10n.onbSentLinkAndCode(email: email),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onbEnterCodeFromEmailLabel,
                style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.onbEmailCodeLabel,
                  hintText: l10n.onbEmailCodeHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim().replaceAll(RegExp(r'\s'), '');
              if (code.length < 6) return;
              Navigator.of(ctx).pop();
              final verifyResult = await AuthLinkService().verifyEmailOtp(email, code);
              if (!context.mounted) return;
              if (verifyResult.success) {
                await clearPendingVerificationEmail();
                await SaveProgressModal.markDismissed();
                onInvalidate?.call();
                if (!context.mounted) return;
                if (isSignInFlow) {
                  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
                }
                await showDialog<void>(
                  context: context,
                  builder: (ctx) {
                    final dialogL10n = ctx.l10n;
                    return AlertDialog(
                      title: Text(isSignInFlow ? dialogL10n.onbSignedIn : dialogL10n.onbAccountLinked),
                      content: Text(
                        isSignInFlow
                            ? dialogL10n.onbSignedInDataSaved
                            : dialogL10n.onbEmailLinkedSuccess,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(dialogL10n.commonOk),
                        ),
                      ],
                    );
                  },
                );
              } else if (verifyResult.errorMessage != null && context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (ctx) {
                    final dialogL10n = ctx.l10n;
                    return AlertDialog(
                      title: Text(dialogL10n.commonWarning),
                      content: Text(verifyResult.errorMessage!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(dialogL10n.commonOk),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            if (!context.mounted) return;
                            await savePendingVerificationEmail(email);
                            final res = await AuthLinkService().linkWithEmail(email);
                            if (!context.mounted) return;
                            if (res.success) {
                              await _showLinkAndCodeDialog(
                                context,
                                email,
                                res.infoMessage,
                                onInvalidate,
                                dialogTitle: context.l10n.onbEnterCodeFromEmailTitle,
                              );
                            } else if (res.errorMessage != null) {
                              await showDialog<void>(
                                context: context,
                                builder: (ctx) {
                                  final errL10n = ctx.l10n;
                                  return AlertDialog(
                                    title: Text(errL10n.commonWarning),
                                    content: Text(res.errorMessage!),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: Text(errL10n.commonOk),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(dialogL10n.onbResend),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text(l10n.onbConfirmCode),
          ),
        ],
      ),
    );
  }

  /// Wpisanie kodu bez ponownego wysyłania maila (gdy użytkownik zamknął okno lub wyłączył aplikację).
  static Future<void> _runEnterCodeOnly(BuildContext context, VoidCallback? onInvalidate) async {
    final savedEmail = await getPendingVerificationEmail();
    if (!context.mounted) return;
    final l10n = context.l10n;
    String? email = savedEmail;
    if (email == null || email.isEmpty) {
      final entered = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final dialogL10n = ctx.l10n;
          final controller = TextEditingController();
          return AlertDialog(
            title: Text(dialogL10n.onbEnterEmailTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dialogL10n.onbEnterEmailWhichAddress,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: dialogL10n.onbEmailAddressLabel,
                    hintText: dialogL10n.onbEmailAddressHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(dialogL10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final e = controller.text.trim();
                  if (e.isEmpty) return;
                  Navigator.of(ctx).pop(e);
                },
                child: Text(dialogL10n.commonContinue),
              ),
            ],
          );
        },
      );
      if (entered == null || !context.mounted) return;
      await savePendingVerificationEmail(entered);
      email = entered;
    }
    if (!context.mounted) return;
    await _showLinkAndCodeDialog(
      context,
      email,
      savedEmail != null
          ? l10n.onbCodeSentTo(email: email)
          : l10n.onbEnterCodeReceived(email: email),
      onInvalidate,
      dialogTitle: l10n.onbEnterCodeFromEmailTitle,
    );
  }

  static Future<String?> _showEmailInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = ctx.l10n;
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(l10n.onbSaveWithEmailTitle),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.onbEmailAddressLabel,
              hintText: l10n.onbEmailAddressHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: Text(l10n.onbSendLinkAndCode),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _runLinkFlow(
    BuildContext context, {
    required Future<AuthLinkResult> future,
    VoidCallback? onInvalidate,
    bool useLoadingDialog = true,
    String? emailForVerification,
  }) async {
    if (useLoadingDialog) {
      final l10n = context.l10n;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.onbLinkingAccount),
                ],
              ),
            ),
          ),
        ),
      );
    }

    var result = await future;

    if (!context.mounted) return;
    if (useLoadingDialog) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop(); // loading dialog
    }

    if (result.canceled) return;
    if (result.redirected) {
      await SaveProgressModal.markDismissed();
      onInvalidate?.call();
      return;
    }
    if (result.success) {
      if (emailForVerification != null) {
        await savePendingVerificationEmail(emailForVerification);
        if (!context.mounted) return;
        await _showLinkAndCodeDialog(
          context,
          emailForVerification,
          result.infoMessage,
          onInvalidate,
        );
        return;
      }
      await SaveProgressModal.markDismissed();
      onInvalidate?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.infoMessage ?? context.l10n.onbAccountSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      final l10n = context.l10n;
      if (result.suggestSignOutAndLogin && emailForVerification != null) {
        // Zamiast dialogu „E-mail już zarejestrowany” – od razu wyślij kod logowania i pokaż wpisywanie kodu.
        try {
          await SupabaseConfig.auth.signOut();
          await markSignOut();
        } catch (_) {}
        if (!context.mounted) return;
        final email = emailForVerification;
        final signInResult = await AuthLinkService().signInWithEmail(email);
        if (!context.mounted) return;
        if (signInResult.success) {
          await _showLinkAndCodeDialog(
            context,
            email,
            signInResult.infoMessage ?? l10n.onbCodeSentEnterBelow(email: email),
            onInvalidate,
            dialogTitle: l10n.onbEnterCodeFromEmailTitle,
            isSignInFlow: true,
          );
        } else {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              final dialogL10n = ctx.l10n;
              return AlertDialog(
                title: Text(dialogL10n.onbEmailAlreadyRegistered),
                content: Text(
                  '${signInResult.errorMessage ?? result.errorMessage}\n\n'
                  '${dialogL10n.onbClickBelowToLogin}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(dialogL10n.commonCancel),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      if (context.mounted) context.go(AppRoutes.welcome);
                    },
                    child: Text(dialogL10n.onbSignOutAndSignIn),
                  ),
                ],
              );
            },
          );
        }
      } else if (result.suggestSignOutAndLogin) {
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            final dialogL10n = ctx.l10n;
            return AlertDialog(
              title: Text(dialogL10n.onbEmailAlreadyRegistered),
              content: Text(
                '${result.errorMessage}\n\n'
                '${dialogL10n.onbClickBelowToLogin}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(dialogL10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await SupabaseConfig.auth.signOut();
                      await markSignOut();
                    } catch (_) {}
                    if (context.mounted) context.go(AppRoutes.welcome);
                  },
                  child: Text(dialogL10n.onbSignOutAndSignIn),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            final dialogL10n = ctx.l10n;
            return AlertDialog(
              title: Text(dialogL10n.commonWarning),
              content: Text(result.errorMessage ?? dialogL10n.commonError),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(dialogL10n.commonOk),
                ),
              ],
            );
          },
        );
      }
    }
  }

  const SaveProgressChecker({
    super.key,
    required this.totalMealsCount,
    required this.child,
    this.onInvalidate,
  });

  final int totalMealsCount;
  final Widget child;
  final VoidCallback? onInvalidate;

  @override
  State<SaveProgressChecker> createState() => _SaveProgressCheckerState();
}

class _SaveProgressCheckerState extends State<SaveProgressChecker> {
  Duration? _remaining;
  bool _dismissed = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null || !user.isAnonymous) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    await GuestTrial.startIfNeeded();
    final remaining = await GuestTrial.remaining();
    final dismissed = await GuestTrial.isCardDismissed();
    if (!mounted) return;
    setState(() {
      _remaining = remaining;
      _dismissed = dismissed;
      _loaded = true;
    });

    if (remaining != null &&
        remaining > Duration.zero &&
        remaining <= const Duration(hours: 24) &&
        !await GuestTrial.wasLastDayReminderShown()) {
      await GuestTrial.markLastDayReminderShown();
      if (!mounted) return;
      final l10n = context.l10n;
      await SaveProgressChecker.showSaveProgressModal(
        context,
        mealsCount: widget.totalMealsCount,
        onInvalidate: widget.onInvalidate,
        titleText: l10n.guestTrialLastDay,
        bodyText: l10n.guestTrialCardBody,
      );
    }
  }

  Future<void> _openLink({required bool expired}) async {
    final l10n = context.l10n;
    await SaveProgressChecker.showSaveProgressModal(
      context,
      mealsCount: widget.totalMealsCount,
      onInvalidate: widget.onInvalidate,
      allowDismiss: !expired,
      titleText: expired ? l10n.guestTrialEndedTitle : null,
      bodyText: expired ? l10n.guestTrialEndedBody : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _remaining == null) return widget.child;
    final expired = _remaining == Duration.zero;
    final lastDay = !expired && _remaining! <= const Duration(hours: 24);
    if (!expired && !lastDay && _dismissed) return widget.child;

    final l10n = context.l10n;
    final days = _remaining!.inDays;
    final title = expired
        ? l10n.guestTrialEndedTitle
        : lastDay
            ? l10n.guestTrialLastDay
            : days <= 1
                ? l10n.guestTrialOneDay
                : l10n.guestTrialDaysLeft(days: days);
    final body = expired ? l10n.guestTrialEndedBody : l10n.guestTrialCardBody;

    return Column(
      children: [
        Material(
          color: const Color(0xFFFF9800),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!expired && !lastDay)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          await GuestTrial.dismissCard();
                          if (mounted) setState(() => _dismissed = true);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: l10n.onbLater,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE65100),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _openLink(expired: expired),
                    child: Text(l10n.onbSaveProgressTitle),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
