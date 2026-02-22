import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../screens/easy_forma_onboarding.dart' show OnboardingTokens;

const String _consentKey = 'privacy_cookie_consent_accepted';

/// Pasek zgody na politykę prywatności / cookies przy pierwszej wizycie.
/// Pokazuje się na dole ekranu do momentu kliknięcia „Akceptuję”.
class PrivacyConsentBanner extends StatefulWidget {
  const PrivacyConsentBanner({super.key});

  @override
  State<PrivacyConsentBanner> createState() => _PrivacyConsentBannerState();
}

class _PrivacyConsentBannerState extends State<PrivacyConsentBanner> {
  bool _accepted = true;
  bool _loaded = false;
  /// Użytkownik kliknął „Odrzuć” – chowamy baner na tę sesję, bez zapisywania zgody (przy następnej wizycie baner znów się pokaże).
  bool _dismissedReject = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_consentKey) ?? false;
    if (mounted) {
      setState(() {
        _accepted = accepted;
        _loaded = true;
      });
    }
  }

  Future<void> _onAccept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    if (mounted) setState(() => _accepted = true);
  }

  void _onReject() {
    setState(() => _dismissedReject = true);
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _accepted || _dismissedReject) {
      return const SizedBox.shrink();
    }
    final compactStyle = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      minimumSize: WidgetStateProperty.all(const Size(0, 36)),
      visualDensity: VisualDensity.compact,
    );
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Przetwarzamy dane osobowe zgodnie z naszą polityką prywatności. '
                'Korzystając z aplikacji, akceptujesz jej warunki.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  TextButton(
                    style: compactStyle,
                    onPressed: _openPrivacyPolicy,
                    child: const Text('Polityka prywatności'),
                  ),
                  OutlinedButton(
                    style: compactStyle,
                    onPressed: _onReject,
                    child: const Text('Odrzuć'),
                  ),
                  FilledButton(
                    style: compactStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(OnboardingTokens.green),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    onPressed: _onAccept,
                    child: const Text('Akceptuję'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
