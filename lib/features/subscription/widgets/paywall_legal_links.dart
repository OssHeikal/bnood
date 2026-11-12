import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/content/content_page_record.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../content/content_page_screen.dart';

/// Terms, privacy, and cancellation links under the paywall purchase actions.
class PaywallLegalLinks extends StatelessWidget {
  const PaywallLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          _PaywallLegalLink(label: l10n.settingsContentTerms, slug: ContentSlugs.terms),
          const _PaywallLegalDot(),
          _PaywallLegalLink(label: l10n.settingsContentPrivacy, slug: ContentSlugs.privacy),
          const _PaywallLegalDot(),
          _PaywallLegalLink(label: l10n.settingsContentCancellation, slug: ContentSlugs.cancellation),
        ],
      ),
    );
  }
}

class _PaywallLegalDot extends StatelessWidget {
  const _PaywallLegalDot();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '·',
      style: TextStyle(color: Color(0xFF9A95A0), fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

class _PaywallLegalLink extends StatelessWidget {
  const _PaywallLegalLink({required this.label, required this.slug});

  final String label;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      enableHaptics: false,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(builder: (_) => ContentPageScreen(slug: slug)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6D6676),
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF6D6676),
          ),
        ),
      ),
    );
  }
}
