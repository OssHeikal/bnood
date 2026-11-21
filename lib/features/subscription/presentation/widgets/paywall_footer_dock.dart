import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../data/paywall_v3_models.dart';
import '../paywall_theme.dart';
import '../../../../core/utils/safe_external_url.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../content/presentation/content_page_screen.dart';
import '../../../content/data/content_page_record.dart';

class PaywallFooterDock extends StatelessWidget {
  const PaywallFooterDock({
    super.key,
    required this.footer,
    required this.onRestore,
  });

  final AppPaywallFooter footer;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = PaywallTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (footer.reassurance != null && footer.reassurance!.isNotEmpty)
          Text(
            footer.reassurance!,
            textAlign: TextAlign.center,
            style: theme.footerReassure,
          ),
        const SizedBox(height: 3),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: [
            if (footer.restorePurchaseVisible)
              AppPressable(
                enableHaptics: false,
                onPressed: onRestore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Text(
                    l10n.paywallRestorePurchase,
                    style: theme.footerLegal.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            if (footer.restorePurchaseVisible)
              Text('·', style: theme.footerLegal.copyWith(decoration: null)),
            _FooterLink(
              label: l10n.settingsContentTerms,
              onTap: () => _openLegal(context, footer.termsUrl, ContentSlugs.terms),
              style: theme.footerLegal.copyWith(fontWeight: FontWeight.w700),
            ),
            Text('·', style: theme.footerLegal.copyWith(decoration: null)),
            _FooterLink(
              label: l10n.settingsContentPrivacy,
              onTap: () => _openLegal(context, footer.privacyUrl, ContentSlugs.privacy),
              style: theme.footerLegal.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openLegal(BuildContext context, String? url, String slug) async {
    if (url != null && url.trim().isNotEmpty) {
      final opened = await launchAllowedUrl(url.trim());
      if (opened) return;
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(builder: (_) => ContentPageScreen(slug: slug)),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap, required this.style});

  final String label;
  final VoidCallback onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      enableHaptics: false,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: style.color,
          ),
        ),
      ),
    );
  }
}