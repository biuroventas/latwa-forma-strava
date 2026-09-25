import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../legal/legal_document_screen.dart';
import '../../../shared/widgets/language_switch.dart';
import '../widgets/welcome_feature_line.dart';
import '../widgets/welcome_video_background.dart';
import '../widgets/welcome_auth_panel.dart';

/// Ikona Google „G” – SVG z fallbackiem na Material icon gdy asset się nie załaduje.
class _GoogleGIcon extends StatefulWidget {
  const _GoogleGIcon({this.size = 22, this.color, this.originalColors = false});

  final double size;
  final Color? color;
  final bool originalColors;

  @override
  State<_GoogleGIcon> createState() => _GoogleGIconState();
}

class _GoogleGIconState extends State<_GoogleGIcon> {
  /// Na starcie pokazujemy fallback; po załadowaniu assetu przełączamy na SVG.
  bool _useFallback = true;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    try {
      await rootBundle.load('assets/icons/google_g.svg');
      if (mounted) setState(() => _useFallback = false);
    } catch (_) {
      if (mounted) setState(() => _useFallback = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return Icon(
        Icons.g_mobiledata,
        size: widget.size,
        color: widget.originalColors ? const Color(0xFF4285F4) : (widget.color ?? Colors.white),
      );
    }
    if (widget.originalColors) {
      return SvgPicture.asset(
        'assets/icons/google_g.svg',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.g_mobiledata,
          size: widget.size,
          color: const Color(0xFF4285F4),
        ),
      );
    }
    final color = widget.color ?? Colors.white;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: SvgPicture.asset(
        'assets/icons/google_g.svg',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.g_mobiledata,
          size: widget.size,
          color: color,
        ),
      ),
    );
  }
}

// --- FAQ: pytania i odpowiedzi (stopka) ---
List<({String q, String a})> _footerFaqEntries(AppLocalizations l10n) => [
      (q: l10n.onbFaqFreeQ, a: l10n.onbFaqFreeA),
      (q: l10n.onbFaqPhotoQ, a: l10n.onbFaqPhotoA),
      (q: l10n.onbFaqLimitQ, a: l10n.onbFaqLimitA),
      (q: l10n.onbFaqNoAccountQ, a: l10n.onbFaqNoAccountA),
      (q: l10n.onbFaqStravaQ, a: l10n.onbFaqStravaA),
      (q: l10n.onbFaqPremiumQ, a: l10n.onbFaqPremiumA),
      (q: l10n.onbFaqGoalQ, a: l10n.onbFaqGoalA),
      (q: l10n.onbFaqAddMealQ, a: l10n.onbFaqAddMealA),
      (q: l10n.onbFaqDataQ, a: l10n.onbFaqDataA),
      (q: l10n.onbFaqDeleteQ, a: l10n.onbFaqDeleteA),
      (q: l10n.onbFaqMedicalQ, a: l10n.onbFaqMedicalA),
    ];

// --- Theme / design tokens ---
abstract final class OnboardingTokens {
  // Kolory (green = tło logo: R66 G148 B69)
  static const Color green = Color(0xFF429445);
  static const Color googleOrange = Color(0xFFFF9800);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color greenVeryLight = Color(0xFFF3FFF4);
  /// Dolna zieleń kadru wideo — do płynnego przejścia w FAQ.
  static const Color foliage = Color(0xFF3A4F18);
  static const Color afterVideo = Color(0xFFE9F1D8);
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
  static const double logoRadius = 24.0;
  static const double logoSize = 108.0;
  /// Scena welcome ma proporcje wideo 9:16 — skaluje się w całości, bez ucinania.
  static const double stageWidth = 390.0;
  static const double stageHeight = stageWidth * 16 / 9;
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
  static const double benefitFontSize = 18.5;
  static const double titleFontSize = 30.0;
}

/// Ekran onboarding aplikacji fitness „Łatwa Forma”.
/// Ilustracja zbudowana w 100% z widgetów Flutter (Stack + Positioned + Container + ClipRRect).
/// Material 3.
class EasyFormaOnboardingScreen extends StatelessWidget {
  const EasyFormaOnboardingScreen({
    super.key,
    required this.onApple,
    required this.onGoogle,
    required this.onCreateAccount,
    required this.onStartWithoutAccount,
    this.onEnterCode,
  });

  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onCreateAccount;
  final VoidCallback onStartWithoutAccount;
  /// Gdy podane – pokazuje link „Mam już kod z maila”, żeby użytkownik mógł wpisać kod po zamknięciu okna.
  final VoidCallback? onEnterCode;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildWebPage(context);
    return _buildMobilePage(context);
  }

  Widget _buildMobilePage(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.foliage,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screen = Size(constraints.maxWidth, constraints.maxHeight);
          final fitted = applyBoxFit(BoxFit.contain, const Size(9, 16), screen);
          final dest = fitted.destination;
          final videoLeft = (screen.width - dest.width) / 2;
          final videoTop = (screen.height - dest.height) / 2;
          final videoRect = Rect.fromLTWH(videoLeft, videoTop, dest.width, dest.height);
          final safeBottom = MediaQuery.paddingOf(context).bottom;

          return Stack(
            fit: StackFit.expand,
            children: [
              const WelcomeVideoBackground(),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 6 * welcomeUiScale(context),
                          right: 14 * welcomeUiScale(context),
                        ),
                        child: const LanguageSwitch(onVideo: true),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * welcomeUiScale(context),
                          MediaQuery.sizeOf(context).height * 0.038 +
                              28 * welcomeUiScale(context),
                          16 * welcomeUiScale(context),
                          0,
                        ),
                        child: _buildLogo(context),
                      ),
                    ),
                  ),
                  Positioned(
                    left: videoRect.left,
                    width: videoRect.width,
                    bottom: safeBottom,
                    child: WelcomeAuthPanel(
                      onApple: onApple,
                      onGoogle: onGoogle,
                      onCreateAccount: onCreateAccount,
                      onStartWithoutAccount: onStartWithoutAccount,
                      onEnterCode: onEnterCode,
                      bottomPad: dest.height * 0.012,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  /// Wygląd sprzed wideo: jasna strona, lista korzyści, ilustracja SVG, dwa przyciski.
  Widget _buildWebPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 720;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 24 : OnboardingTokens.horizontalPadding,
                      vertical: wide ? 24 : OnboardingTokens.topPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildWebLogo(),
                            const SizedBox(height: OnboardingTokens.spaceXl),
                            _buildBenefitsList(context),
                            Transform.translate(
                              offset: const Offset(0, -14),
                              child: Center(child: _buildIllustrationPanel()),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -25),
                              child: _buildWebButtons(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqSection(context),
                  _buildFooter(context),
                ],
              ),
            );
          },
        ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 8, right: 16),
                child: LanguageSwitch(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLogo() {
    return Center(
      child: Opacity(
        opacity: 0.82,
        child: Image.asset(
          'assets/images/logotrans.png',
          width: OnboardingTokens.logoSize,
          height: OnboardingTokens.logoSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.restaurant, l10n.onbBenefitCalories),
      (Icons.trending_up, l10n.onbBenefitWeight),
      (Icons.flag, l10n.onbBenefitPlan),
      (Icons.smart_toy, l10n.onbBenefitAi),
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$1, size: OnboardingTokens.iconSize, color: OnboardingTokens.green),
                const SizedBox(width: OnboardingTokens.spaceSm),
                Flexible(
                  child: Text(
                    item.$2,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: OnboardingTokens.textAlmostBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: OnboardingTokens.benefitFontSize,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: OnboardingTokens.spaceSm),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustrationPanel() {
    return SvgPicture.asset(
      'assets/images/grafika2.svg',
      fit: BoxFit.contain,
      height: OnboardingTokens.panelHeight,
      excludeFromSemantics: true,
      placeholderBuilder: (_) => const SizedBox(height: OnboardingTokens.panelHeight),
    );
  }

  Widget _buildWebButtons(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingTokens.horizontalPadding,
        0,
        OnboardingTokens.horizontalPadding,
        OnboardingTokens.bottomPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: OnboardingTokens.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => _showWebLoginSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OnboardingTokens.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OnboardingTokens.buttonRadius),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _GoogleGIcon(size: 22, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(l10n.onbLoginOrRegister),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: OnboardingTokens.betweenButtons),
              SizedBox(
                height: OnboardingTokens.buttonHeight,
                child: OutlinedButton(
                  onPressed: onStartWithoutAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OnboardingTokens.green,
                    side: const BorderSide(color: OnboardingTokens.textAlmostBlack, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OnboardingTokens.buttonRadius),
                    ),
                  ),
                  child: Text(l10n.onbStartWithoutAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWebLoginSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.onbLoginOrCreateShort,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onbLoginSheetBody,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onApple();
                  },
                  icon: const Icon(Icons.apple, size: 20),
                  label: Text(l10n.onbContinueApple),
                  style: FilledButton.styleFrom(
                    backgroundColor: OnboardingTokens.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onGoogle();
                  },
                  icon: const _GoogleGIcon(size: 20, originalColors: true),
                  label: Text(l10n.onbContinueGoogle),
                  style: FilledButton.styleFrom(
                    backgroundColor: OnboardingTokens.googleOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onCreateAccount();
                  },
                  icon: const Icon(Icons.email_outlined, size: 20),
                  label: Text(l10n.onbCreateAccountEmail),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OnboardingTokens.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
    final scale = welcomeUiScale(context);
    final size = 156 * scale;
    return Center(
      child: Opacity(
        opacity: 0.78,
        child: Image.asset(
          'assets/images/logotrans.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = context.l10n;
    final bool narrow = MediaQuery.sizeOf(context).width < 560;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: OnboardingTokens.horizontalPadding,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: kIsWeb ? OnboardingTokens.greenVeryLight : OnboardingTokens.afterVideo,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (narrow)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _footerLinkRow(context, wrap: true),
                const SizedBox(height: 16),
                _buildFooterSocial(context),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerLinkRow(context, wrap: false),
                const SizedBox(width: 24),
                _buildFooterSocial(context),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: double.infinity,
            color: OnboardingTokens.greenLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onbCopyrightShort(
              company: AppConstants.companyName,
              nip: AppConstants.companyNip,
            ),
            style: TextStyle(
              fontSize: 12,
              color: OnboardingTokens.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Jedna linia linków: Regulamin · Polityka · Kontakt (bez osobnych bloków brand).
  Widget _footerLinkRow(BuildContext context, {required bool wrap}) {
    final l10n = context.l10n;
    final sep = Text(
      ' · ',
      style: TextStyle(fontSize: 13, color: OnboardingTokens.grey),
    );
    final links = [
      _footerLink(context, l10n.onbTerms, AppConstants.termsUrl),
      sep,
      _footerLink(context, l10n.onbPrivacyPolicy, AppConstants.privacyPolicyUrl),
      sep,
      _footerLink(context, l10n.onbContact, 'mailto:${AppConstants.contactEmail}'),
    ];
    if (wrap) {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: links,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: links,
    );
  }

  /// Treść sekcji FAQ (wyśrodkowana).
  Widget _buildFaqSectionContent(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.onbFaqTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: OnboardingTokens.textAlmostBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _FaqExpandableList(entries: _footerFaqEntries(l10n), initialCount: 5),
      ],
    );
  }

  /// Sekcja FAQ nad stopką – wąski layout (pod główną treścią).
  Widget _buildFaqSection(BuildContext context) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingTokens.horizontalPadding,
          vertical: OnboardingTokens.spaceXl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _buildFaqSectionContent(context),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 64,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                OnboardingTokens.foliage,
                Color(0xFF6A8234),
                OnboardingTokens.afterVideo,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: OnboardingTokens.afterVideo,
          padding: const EdgeInsets.fromLTRB(
            OnboardingTokens.horizontalPadding,
            8,
            OnboardingTokens.horizontalPadding,
            OnboardingTokens.spaceXl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _buildFaqSectionContent(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSocial(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.onbFollowUs,
          style: TextStyle(
            fontSize: 13,
            color: OnboardingTokens.grey,
          ),
        ),
        _socialIcon(context, Icons.facebook_rounded, 'Facebook', AppConstants.socialFacebookUrl),
        const SizedBox(width: 4),
        _socialIcon(context, Icons.camera_alt, 'Instagram', AppConstants.socialInstagramUrl),
      ],
    );
  }

  Widget _socialIcon(BuildContext context, IconData icon, String tooltip, String? url) {
    final l10n = context.l10n;
    return Tooltip(
      message: url != null ? tooltip : l10n.onbSocialComingSoon(name: tooltip),
      child: IconButton(
        onPressed: url != null
            ? () => _openUrl(url)
            : null,
        icon: Icon(icon, size: 22, color: OnboardingTokens.grey),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
        ),
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => openLegalOrExternal(context, url),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: OnboardingTokens.green,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Lista FAQ z możliwością rozwijania: najpierw [initialCount] pytań, potem „Zobacz więcej”.
class _FaqExpandableList extends StatefulWidget {
  const _FaqExpandableList({
    required this.entries,
    this.initialCount = 3,
  });

  final List<({String q, String a})> entries;
  final int initialCount;

  @override
  State<_FaqExpandableList> createState() => _FaqExpandableListState();
}

class _FaqExpandableListState extends State<_FaqExpandableList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = _expanded ? widget.entries.length : widget.initialCount.clamp(0, widget.entries.length);
    final visible = widget.entries.take(count).toList();
    final hasMore = widget.entries.length > widget.initialCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in visible)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(vertical: 4),
              childrenPadding: const EdgeInsets.only(left: 20, bottom: 12, top: 2),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(
                entry.q,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OnboardingTokens.textAlmostBlack,
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    entry.a,
                    style: TextStyle(
                      fontSize: 13,
                      color: OnboardingTokens.grey,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: OnboardingTokens.green,
              ),
              label: Text(
                _expanded
                    ? l10n.onbFaqShowLess
                    : l10n.onbFaqShowMore(count: widget.entries.length - widget.initialCount),
                style: const TextStyle(
                  color: OnboardingTokens.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
