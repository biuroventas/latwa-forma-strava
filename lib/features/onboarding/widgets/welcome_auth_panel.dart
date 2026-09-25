import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../legal/legal_document.dart';
import '../../legal/legal_document_screen.dart';
import 'welcome_feature_line.dart';

/// Dolny panel logowania welcome. Bez własnego tła — leży na filmie.
class WelcomeAuthPanel extends StatelessWidget {
  const WelcomeAuthPanel({
    super.key,
    required this.onApple,
    required this.onGoogle,
    required this.onCreateAccount,
    required this.onStartWithoutAccount,
    this.onEnterCode,
    this.bottomPad = 8,
  });

  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onCreateAccount;
  final VoidCallback onStartWithoutAccount;
  final VoidCallback? onEnterCode;
  final double bottomPad;

  /// Koszulka mężczyzny na filmie welcome (próbka z kadru).
  static const _shirt = Color(0xFF27312D);
  static const _ink = Color(0xFF1A1A1A);
  static const _border = Color(0xFFD8D8D8);
  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.sizeOf(context);
    final scale = welcomeUiScale(context);
    final buttonH = 46 * scale;
    final gap = 6 * scale;
    final hPad = media.width * 0.03;
    final iconSize = buttonH * 0.38;
    final radius = _radius * scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8 * scale, hPad, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 14 * scale),
                  child: const WelcomeFeatureLine(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _AuthButton(
                        height: buttonH,
                        onPressed: onApple,
                        background: Colors.white,
                        foreground: _ink,
                        border: _border,
                        icon: Icon(Icons.apple, size: iconSize, color: Colors.black),
                        label: l10n.onbContinueApple,
                        radius: radius,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _AuthButton(
                        height: buttonH,
                        onPressed: onGoogle,
                        background: Colors.white,
                        foreground: _ink,
                        border: _border,
                        icon: _GoogleMark(size: iconSize),
                        label: l10n.onbContinueGoogle,
                        radius: radius,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                Row(
                  children: [
                    Expanded(
                      child: _AuthButton(
                        height: buttonH,
                        onPressed: onStartWithoutAccount,
                        background: Colors.white.withValues(alpha: 0.92),
                        foreground: _ink,
                        border: _shirt,
                        label: l10n.onbStartWithoutAccount,
                        radius: radius,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _AuthButton(
                        height: buttonH,
                        onPressed: onCreateAccount,
                        background: _shirt,
                        foreground: Colors.white,
                        icon: Icon(
                          Icons.email_outlined,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        label: l10n.onbCreateAccount,
                        radius: radius,
                        fontSize: 16,
                        emphasis: true,
                      ),
                    ),
                  ],
                ),
                if (onEnterCode != null)
                  TextButton(
                    onPressed: onEnterCode,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.88),
                      padding: const EdgeInsets.only(top: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.onbEnterCodeLink,
                      style: const TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                SizedBox(height: 6 * scale),
                const _LegalLine(),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.height,
    required this.onPressed,
    required this.background,
    required this.foreground,
    required this.label,
    required this.radius,
    required this.fontSize,
    this.icon,
    this.border,
    this.emphasis = false,
  });

  final double height;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final String label;
  final double radius;
  final double fontSize;
  final Widget? icon;
  final Color? border;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: emphasis ? 3 : 1.5,
          shadowColor: Colors.black.withValues(alpha: emphasis ? 0.28 : 0.16),
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: border == null
                ? BorderSide.none
                : BorderSide(color: border!, width: 1.1),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: fontSize * 0.35),
              ],
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLine extends StatefulWidget {
  const _LegalLine();

  @override
  State<_LegalLine> createState() => _LegalLineState();
}

class _LegalLineState extends State<_LegalLine> {
  late final TapGestureRecognizer _terms;
  late final TapGestureRecognizer _privacy;

  static const _shadow = <Shadow>[
    Shadow(color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 1)),
  ];

  TextStyle get _text => TextStyle(
    fontFamily: 'Inter',
    color: Colors.white.withValues(alpha: 0.78),
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.2,
    shadows: _shadow,
  );

  TextStyle get _link => const TextStyle(
    fontFamily: 'Inter',
    color: Color(0xF2FFFFFF),
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xB3FFFFFF),
    shadows: _shadow,
  );

  @override
  void initState() {
    super.initState();
    _terms = TapGestureRecognizer()
      ..onTap = () {
        if (!mounted) return;
        openLegalDocument(context, LegalKind.terms);
      };
    _privacy = TapGestureRecognizer()
      ..onTap = () {
        if (!mounted) return;
        openLegalDocument(context, LegalKind.privacy);
      };
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          style: _text,
          children: [
            TextSpan(text: l10n.onbLegalPrefix),
            TextSpan(text: l10n.onbTerms, style: _link, recognizer: _terms),
            TextSpan(text: l10n.onbLegalAnd),
            TextSpan(text: l10n.onbPrivacyPolicyAccusative, style: _link, recognizer: _privacy),
            TextSpan(text: l10n.onbLegalPeriod),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

class _GoogleMark extends StatefulWidget {
  const _GoogleMark({this.size = 18});

  final double size;

  @override
  State<_GoogleMark> createState() => _GoogleMarkState();
}

class _GoogleMarkState extends State<_GoogleMark> {
  bool _fallback = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      await rootBundle.load('assets/icons/google_g.svg');
      if (mounted) setState(() => _fallback = false);
    } catch (_) {
      if (mounted) setState(() => _fallback = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fallback) {
      return Icon(Icons.g_mobiledata, size: widget.size, color: const Color(0xFF4285F4));
    }
    return SvgPicture.asset(
      'assets/icons/google_g.svg',
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }
}
