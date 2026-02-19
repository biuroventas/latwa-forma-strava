import 'package:flutter/material.dart';

// --- Theme / design tokens ---
abstract final class OnboardingTokens {
  // Kolory
  static const Color green = Color(0xFF4CAF50);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color greenVeryLight = Color(0xFFF3FFF4);
  static const Color textAlmostBlack = Color(0xFF212121);
  static const Color skin = Color(0xFFFFDBB5);
  static const Color grey = Color(0xFF9E9E9E);

  // Gradient tła
  static const Color gradientStart = Color(0xFFF3FFF4);
  static const Color gradientEnd = Color(0xFFFFFFFF);

  // Bloby
  static const double blobSize = 270.0;
  static const double blobOpacity = 0.15;
  static const double blobBlurRadius = 150.0;

  // Radius
  static const double logoRadius = 22.0;
  static const double logoSize = 88.0;
  static const double panelRadius = 26.0;
  static const double buttonRadius = 20.0;
  static const double panelHeight = 260.0;
  static const double panelMaxWidth = 420.0;

  // Spacing
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 24.0;
  static const double horizontalPadding = 28.0;
  static const double bottomPadding = 28.0;
  static const double topPadding = 28.0;
  static const double betweenButtons = 14.0;

  // Sizes
  static const double logoIconSize = 42.0;
  static const double iconSize = 22.0;
  static const double buttonHeight = 56.0;
  static const double benefitFontSize = 16.5;
  static const double titleFontSize = 30.0;
}

/// Ekran onboarding aplikacji fitness „Łatwa Forma”.
/// Ilustracja zbudowana w 100% z widgetów Flutter (Stack + Positioned + Container + ClipRRect).
/// Material 3.
class EasyFormaOnboardingScreen extends StatelessWidget {
  const EasyFormaOnboardingScreen({
    super.key,
    required this.onLogin,
    required this.onStartWithoutAccount,
    this.onEnterCode,
  });

  final VoidCallback onLogin;
  final VoidCallback onStartWithoutAccount;
  /// Gdy podane – pokazuje link „Mam już kod z maila”, żeby użytkownik mógł wpisać kod po zamknięciu okna.
  final VoidCallback? onEnterCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        flex: 2,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OnboardingTokens.horizontalPadding,
                            vertical: OnboardingTokens.topPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLogo(context),
                              const SizedBox(height: OnboardingTokens.spaceXl),
                              _buildTitle(context),
                              const SizedBox(height: OnboardingTokens.spaceXl),
                              _buildBenefitsList(context),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Center(
                            child: _buildIllustrationPanel(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBottomButtons(context),
              ],
            ),
        ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Center(
      child: Container(
        width: OnboardingTokens.logoSize,
        height: OnboardingTokens.logoSize,
        decoration: BoxDecoration(
          color: OnboardingTokens.green,
          borderRadius: BorderRadius.circular(OnboardingTokens.logoRadius),
        ),
        child: const Icon(
          Icons.fitness_center,
          color: Colors.white,
          size: OnboardingTokens.logoIconSize,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Łatwa Forma',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: OnboardingTokens.textAlmostBlack,
            fontSize: OnboardingTokens.titleFontSize,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    const items = [
      (Icons.restaurant, 'plan kalorii dopasowany do Ciebie'),
      (Icons.trending_up, 'śledzenie wagi i postępów'),
      (Icons.flag, 'prosty plan do celu'),
      (Icons.smart_toy, 'pomoc AI'),
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) ...[
            _buildBenefitRow(context, icon: item.$1, text: item.$2),
            if (item != items.last)
              const SizedBox(height: OnboardingTokens.spaceSm),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: OnboardingTokens.iconSize, color: OnboardingTokens.green),
        const SizedBox(width: OnboardingTokens.spaceSm),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: OnboardingTokens.textAlmostBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: OnboardingTokens.benefitFontSize,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(
        'assets/images/grafika2.png',
        fit: BoxFit.contain,
        height: 260,
        excludeFromSemantics: true,
        errorBuilder: (_, __, ___) => const SizedBox(height: 260),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingTokens.horizontalPadding,
        OnboardingTokens.spaceLg,
        OnboardingTokens.horizontalPadding,
        OnboardingTokens.bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: OnboardingTokens.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                // TODO: podpięcie nawigacji / logowania (np. onLogin())
                onLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTokens.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OnboardingTokens.buttonRadius),
                ),
              ),
              child: const Text('Zaloguj się lub załóż konto'),
            ),
          ),
          const SizedBox(height: OnboardingTokens.betweenButtons),
          SizedBox(
            height: OnboardingTokens.buttonHeight,
            child: OutlinedButton(
              onPressed: () {
                onStartWithoutAccount();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: OnboardingTokens.green,
                side: const BorderSide(color: OnboardingTokens.textAlmostBlack, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OnboardingTokens.buttonRadius),
                ),
              ),
              child: const Text('Zacznij bez konta'),
            ),
          ),
          if (onEnterCode != null) ...[
            const SizedBox(height: OnboardingTokens.spaceMd),
            TextButton(
              onPressed: onEnterCode,
              child: Text(
                'Mam już kod z maila – wpisz go',
                style: TextStyle(
                  color: OnboardingTokens.green,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
