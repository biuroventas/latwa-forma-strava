import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/sign_out_guard.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../services/auth_link_service.dart';
import '../utils/pending_verification_email.dart';
import 'save_progress_modal.dart';

/// Opakowuje dziecko i wyświetla modal „Zapisz postępy”, gdy użytkownik anonimowy
/// ma >= X posiłków. Przy „Później” komunikat pojawi się ponownie przy następnym uruchomieniu.
class SaveProgressChecker extends StatefulWidget {
  /// Pokazuje modal „Zapisz postępy” z opcjami Google/Email. Używane na dashboardzie
  /// i z karty w profilu. Przy „Później” tylko zamyka – bez zapisywania.
  static Future<void> showSaveProgressModal(
    BuildContext context, {
    required int mealsCount,
    VoidCallback? onInvalidate,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaveProgressModal(
        mealsCount: mealsCount,
        onDismiss: () {}, // Później – nie zapisuj, pojawi się przy następnym uruchomieniu
        onLinkEmail: () => _runLinkEmail(context, onInvalidate),
        onLinkApple: null, // Wyłączone – wymaga Apple Developer Program
        onLinkGoogle: () => _runLinkGoogle(context, onInvalidate),
        onEnterCode: () => _runEnterCodeOnly(context, onInvalidate),
      ),
    );
  }

  static Future<void> _runLinkGoogle(BuildContext context, VoidCallback? onInvalidate) async {
    // Google przez inAppWebView – OAuth w aplikacji, bez crash przy powrocie
    await _runLinkFlow(
      context,
      future: AuthLinkService().linkWithGoogle(),
      onInvalidate: onInvalidate,
      useLoadingDialog: true,
    );
  }

  static Future<void> _runLinkEmail(BuildContext context, VoidCallback? onInvalidate) async {
    // Email nie otwiera przeglądarki – modal „Łączenie konta...” jest OK
    final email = await _showEmailInputDialog(context);
    if (email == null || email.isEmpty || !context.mounted) return;
    await savePendingVerificationEmail(email);
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
    String dialogTitle = 'Sprawdź skrzynkę',
    bool isSignInFlow = false,
  }) async {
    final codeController = TextEditingController();
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                infoMessage ??
                    'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – możesz kliknąć link w mailu lub wpisać kod poniżej.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Wpisz kod z maila:',
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
                decoration: const InputDecoration(
                  labelText: 'Kod z maila',
                  hintText: 'np. 123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zamknij'),
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
                  builder: (ctx) => AlertDialog(
                    title: Text(isSignInFlow ? 'Zalogowano' : 'Konto połączone'),
                    content: Text(
                      isSignInFlow
                          ? 'Zostałeś zalogowany. Twoje dane są zapisane.'
                          : 'Twój adres e-mail został połączony z kontem. Możesz się teraz logować tym emailem.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else if (verifyResult.errorMessage != null && context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Uwaga'),
                    content: Text(verifyResult.errorMessage!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
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
                              dialogTitle: 'Wpisz kod z maila',
                            );
                          } else if (res.errorMessage != null) {
                            await showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Uwaga'),
                                content: Text(res.errorMessage!),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text('Wyślij ponownie'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Potwierdź kod'),
          ),
        ],
      ),
    );
  }

  /// Wpisanie kodu bez ponownego wysyłania maila (gdy użytkownik zamknął okno lub wyłączył aplikację).
  static Future<void> _runEnterCodeOnly(BuildContext context, VoidCallback? onInvalidate) async {
    final savedEmail = await getPendingVerificationEmail();
    String? email = savedEmail;
    if (email == null || email.isEmpty) {
      final entered = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Podaj adres email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Na który adres wysłaliśmy link i kod? Podaj go, a następnie wpiszesz kod.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Adres email',
                    hintText: 'np. jan@example.com',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () {
                  final e = controller.text.trim();
                  if (e.isEmpty) return;
                  Navigator.of(ctx).pop(e);
                },
                child: const Text('Dalej'),
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
      savedEmail != null ? 'Kod wysłany na: $email' : 'Wpisz poniżej kod, który otrzymałeś na adres $email.',
      onInvalidate,
      dialogTitle: 'Wpisz kod z maila',
    );
  }

  static Future<String?> _showEmailInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Zapisz z emailem'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Adres email',
              hintText: 'np. jan@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Wyślij link oraz kod'),
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
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Łączenie konta...'),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Otwieram przeglądarkę...'),
          duration: Duration(seconds: 2),
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
            content: Text(result.infoMessage ?? 'Konto zapisane pomyślnie!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
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
            signInResult.infoMessage ?? 'Wysłaliśmy kod na $email. Wpisz go poniżej.',
            onInvalidate,
            dialogTitle: 'Wpisz kod z maila',
            isSignInFlow: true,
          );
        } else {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('E-mail już zarejestrowany'),
              content: Text(
                '${signInResult.errorMessage ?? result.errorMessage}\n\n'
                'Kliknij poniżej, aby przejść do logowania:',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Anuluj'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    if (context.mounted) context.go(AppRoutes.welcome);
                  },
                  child: const Text('Wyloguj i zaloguj się'),
                ),
              ],
            ),
          );
        }
      } else if (result.suggestSignOutAndLogin) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('E-mail już zarejestrowany'),
            content: Text(
              '${result.errorMessage}\n\n'
              'Kliknij poniżej, aby przejść do logowania:',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Anuluj'),
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
                child: const Text('Wyloguj i zaloguj się'),
              ),
            ],
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Uwaga'),
            content: Text(result.errorMessage ?? 'Błąd'),
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
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowModal());
  }

  @override
  void didUpdateWidget(SaveProgressChecker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalMealsCount != widget.totalMealsCount && !_checked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowModal());
    }
  }

  Future<void> _maybeShowModal() async {
    if (_checked) return;

    final user = SupabaseConfig.auth.currentUser;
    if (user == null || !user.isAnonymous) return;
    if (widget.totalMealsCount < AppConstants.saveProgressMealsThreshold) return;

    // Krótkie opóźnienie, żeby dashboard zdążył się wyrenderować przed modalem.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _checked = true;

    if (!mounted) return;
    await SaveProgressChecker.showSaveProgressModal(
      context,
      mealsCount: widget.totalMealsCount,
      onInvalidate: widget.onInvalidate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
