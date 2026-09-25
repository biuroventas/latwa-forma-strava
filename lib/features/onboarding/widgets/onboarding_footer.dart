import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../legal/legal_document_screen.dart';
import '../screens/easy_forma_onboarding.dart';

/// Stopka z linkami i social – na webie używana w shellu (pełna szerokość ekranu).
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            l10n.onbCopyrightFull(
              company: AppConstants.companyName,
              nip: AppConstants.companyNip,
              address: AppConstants.companyAddress,
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
}
