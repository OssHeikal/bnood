import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/utils/safe_external_url.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../content/content_page_screen.dart';
import '../../../core/content/content_page_record.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final legal = isDark ? const Color(0xFF8F8798) : const Color(0xFF8E8896);
    final muted = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (footer.reassurance != null && footer.reassurance!.isNotEmpty)
          Text(
            footer.reassurance!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted, height: 1.35),
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: legal),
                  ),
                ),
              ),
            if (footer.restorePurchaseVisible) Text('·', style: TextStyle(color: legal, fontWeight: FontWeight.w600)),
            _FooterLink(
              label: l10n.settingsContentTerms,
              onTap: () => _openLegal(context, footer.termsUrl, ContentSlugs.terms),
              color: legal,
            ),
            Text('·', style: TextStyle(color: legal, fontWeight: FontWeight.w600)),
            _FooterLink(
              label: l10n.settingsContentPrivacy,
              onTap: () => _openLegal(context, footer.privacyUrl, ContentSlugs.privacy),
              color: legal,
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
  const _FooterLink({required this.label, required this.onTap, required this.color});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      enableHaptics: false,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}