import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

// --- FAQ: pytania i odpowiedzi (stopka) ---
const List<({String q, String a})> _footerFaqEntries = [
  (q: 'Czy aplikacja jest darmowa?', a: 'Tak. Łatwa Forma jest darmowa do codziennego użytku: śledzenie kalorii, posiłków, wagi, wody i aktywności. Część funkcji (np. analiza AI ze zdjęcia, rozbudowane statystyki) jest dostępna w planie Premium.'),
  (q: 'Jak działa licznik kalorii ze zdjęcia?', a: 'W ekranie dodawania posiłku wybierz „Analiza AI”. Zrób zdjęcie dania lub wybierz je z galerii. Aplikacja wysyła zdjęcie do modelu AI (wizja), który rozpoznaje potrawę i szacuje kalorie oraz makroskładniki (białko, tłuszcze, węglowodany). Możesz je potem poprawić i zapisać. Funkcja wymaga Premium.'),
  (q: 'Jak aplikacja liczy mój dzienny limit kalorii?', a: 'Na podstawie profilu (wiek, płeć, waga, wzrost, poziom aktywności) obliczamy BMR (wzór Harrisa-Benedicta), a potem TDEE. W zależności od celu (schudnięcie, utrzymanie, przytycie) dostosowujemy limit kalorii i makra.'),
  (q: 'Co to jest „Zacznij bez konta”?', a: 'Możesz korzystać z aplikacji bez logowania. Dane są zapisywane lokalnie. Później możesz połączyć je z kontem (Google lub e-mail), aby mieć backup i synchronizację między urządzeniami.'),
  (q: 'Czy mogę połączyć Strava lub Garmin?', a: 'Tak. W ustawieniach (Profil) możesz połączyć konto ze Strava lub Garmin Connect. Importowane aktywności są uwzględniane w bilansie kalorii (spalone kcal).'),
  (q: 'Co daje Premium?', a: 'M.in. analiza posiłku ze zdjęcia (AI), rozbudowane statystyki, eksport danych, wyższy limit porad AI. Subskrypcja jest obsługiwana przez Stripe; płatność i dane karty są po stronie Stripe.'),
  (q: 'Jak zmienić cel (schudnięcie / utrzymanie / przytycie)?', a: 'W Profilu ustaw wagę docelową. Aplikacja na tej podstawie proponuje cel i dzienny limit; makra można też dostosować ręcznie w ustawieniach profilu.'),
  (q: 'Jak dodać posiłek?', a: 'Z ekranu głównego lub zakładki „Posiłki” wybierz „Dodaj posiłek”. Możesz wpisać dane ręcznie, zeskanować kod kreskowy (Open Food Facts) lub użyć Analizy AI ze zdjęcia (Premium).'),
  (q: 'Gdzie są zapisane moje dane?', a: 'Dane są przechowywane na serwerach w Europie (Supabase). Przy „Zacznij bez konta” dane są lokalne do momentu połączenia z kontem.'),
  (q: 'Jak usunąć konto i dane?', a: 'W aplikacji: Profil → Usuń konto. Po zatwierdzeniu konto i powiązane dane są usuwane. W razie problemów napisz na contact@latwaforma.pl.'),
];

// --- Theme / design tokens ---
abstract final class OnboardingTokens {
  // Kolory (green = tło logo: R66 G148 B69)
  static const Color green = Color(0xFF429445);
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
  static const double logoRadius = 63.0; // +10%
  static const double logoSize = 246.0; // 224 * 1.1
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
                    child: wide
                        ? _buildWideLayout(context)
                        : _buildNarrowLayout(context),
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
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(context),
            const SizedBox(height: OnboardingTokens.spaceXl),
                _buildBenefitsList(context),
                const SizedBox(height: 0),
                Transform.translate(
                  offset: const Offset(0, -14),
                  child: Center(child: _buildIllustrationPanel(context)),
                ),
                const SizedBox(height: 0),
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: _buildBottomButtons(context),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(context),
            const SizedBox(height: OnboardingTokens.spaceXl),
            _buildBenefitsList(context),
            const SizedBox(height: 0),
            Transform.translate(
              offset: const Offset(0, -14),
              child: Center(child: _buildIllustrationPanel(context)),
            ),
                const SizedBox(height: 0),
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: _buildBottomButtons(context),
                ),
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
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/images/logo400x400.png',
          width: OnboardingTokens.logoSize,
          height: OnboardingTokens.logoSize,
          fit: BoxFit.contain,
        ),
      ),
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
                  fontWeight: FontWeight.normal,
                  fontSize: OnboardingTokens.benefitFontSize,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationPanel(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/grafika2.svg',
      fit: BoxFit.contain,
      height: OnboardingTokens.panelHeight,
      excludeFromSemantics: true,
      placeholderBuilder: (_) => const SizedBox(height: OnboardingTokens.panelHeight),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
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
                  onPressed: () => onLogin(),
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
                  onPressed: () => onStartWithoutAccount(),
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
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final bool narrow = MediaQuery.sizeOf(context).width < 560;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: OnboardingTokens.horizontalPadding,
        vertical: 28,
      ),
      decoration: const BoxDecoration(
        color: OnboardingTokens.greenVeryLight,
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
            '© 2026 Łatwa Forma | VENTAS NORBERT WRÓBLEWSKI. Wszelkie prawa zastrzeżone.',
            style: TextStyle(
              fontSize: 12,
              color: OnboardingTokens.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Jedna linia linków: Regulamin · Polityka · Kontakt (bez osobnych bloków brand).
  Widget _footerLinkRow(BuildContext context, {required bool wrap}) {
    final sep = Text(
      ' · ',
      style: TextStyle(fontSize: 13, color: OnboardingTokens.grey),
    );
    final links = [
      _footerLink(context, 'Regulamin', AppConstants.termsUrl),
      sep,
      _footerLink(context, 'Polityka prywatności', AppConstants.privacyPolicyUrl),
      sep,
      _footerLink(context, 'Kontakt', 'mailto:${AppConstants.contactEmail}'),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'FAQ – najczęściej zadawane pytania',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: OnboardingTokens.textAlmostBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _FaqExpandableList(entries: _footerFaqEntries, initialCount: 5),
      ],
    );
  }

  /// Sekcja FAQ nad stopką – wąski layout (pod główną treścią).
  Widget _buildFaqSection(BuildContext context) {
    return Container(
      width: double.infinity,
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

  Widget _buildFooterSocial(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Śledź nas: ',
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
    return Tooltip(
      message: url != null ? tooltip : '$tooltip – wkrótce',
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
        onTap: () => _openUrl(url),
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
                _expanded ? 'Pokaż mniej' : 'Zobacz więcej pytań (${widget.entries.length - widget.initialCount})',
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
