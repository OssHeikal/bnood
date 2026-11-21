import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/money/remote_money_format.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';

class PaywallPackageCard extends StatelessWidget {
  const PaywallPackageCard({
    super.key,
    required this.package,
    required this.selected,
    required this.billingPeriod,
    required this.onTap,
    required this.localeCode,
  });

  final AppPaywallPackage package;
  final bool selected;
  final String billingPeriod;
  final VoidCallback onTap;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idleFill = isDark ? const Color(0xFF221C2B) : Colors.white;
    final selectedFill = isDark ? const Color(0xFF2A1D40) : SubscriptionColors.violetSoft;
    final line = isDark ? const Color(0xFF322B3C) : const Color(0xFFE7E2EE);
    final ink = isDark ? const Color(0xFFF3EEF8) : const Color(0xFF1C1722);
    final muted = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);
    final l10n = AppLocalizations.of(context);
    final locale = localeCode == 'ar' ? 'ar_EG' : 'en_US';

    final effectivePeriod = package.effectivePeriodWhen(billingPeriod);
    final showYearlyOnlyHint = billingPeriod == 'monthly' && package.yearlyOnly;
    final pricing = effectivePeriod == 'yearly' ? package.pricing.yearly : package.pricing.monthly;

    return Material(
      color: selected ? selectedFill : idleFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? SubscriptionColors.violet : line,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: package.name,
                                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: ink),
                              ),
                              if (package.slugShort != null && package.slugShort!.isNotEmpty)
                                TextSpan(
                                  text: ' ${package.slugShort}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: muted,
                                    letterSpacing: 0.04 * 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (package.isRecommended && package.badgeType == 'recommended')
                          _Tag(label: package.badgeLabel ?? '', style: _TagStyle.recommended),
                        if (package.isCurrentPlan)
                          _Tag(label: package.badgeLabel ?? 'Current', style: _TagStyle.current, isDark: isDark),
                        if (showYearlyOnlyHint)
                          _Tag(label: package.yearlyOnlyLabel ?? '', style: _TagStyle.yearlyOnly, isDark: isDark),
                      ],
                    ),
                    if (package.tagline != null && package.tagline!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        package.tagline!,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: muted, height: 1.25),
                        textAlign: TextAlign.start,
                      ),
                    ],
                    if (!package.isContact && pricing != null && effectivePeriod == 'yearly' && pricing.billedTotalMinor != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _billedYearlyCaption(l10n, pricing, locale),
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: muted, height: 1.3),
                        ),
                      )
                    else if (!package.isContact && effectivePeriod == 'monthly')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.paywallBilledMonthly,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: muted),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (package.isContact)
                Text(
                  package.contactCtaText ?? package.name,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFC4A6FF) : SubscriptionColors.violet,
                    height: 1.3,
                  ),
                )
              else if (pricing != null)
                _PriceColumn(
                  pricing: pricing,
                  locale: locale,
                  perMonthUnit: l10n.paywallPerMonthUnit,
                  muted: muted,
                  ink: ink,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _billedYearlyCaption(AppLocalizations l10n, AppPaywallPeriodPricing pricing, String locale) {
    final amount = RemoteMoneyFormat.formatMinor(pricing.billedTotalMinor ?? pricing.discountedMinor, locale: locale);
    final display = pricing.hasDiscount && pricing.originalMinor > pricing.discountedMinor
        ? '${RemoteMoneyFormat.formatMinor(pricing.originalMinor, locale: locale)} → $amount'
        : amount;
    return l10n.paywallBilledYearly(display);
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.pricing,
    required this.locale,
    required this.perMonthUnit,
    required this.muted,
    required this.ink,
  });

  final AppPaywallPeriodPricing pricing;
  final String locale;
  final String perMonthUnit;
  final Color muted;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final perMonth = RemoteMoneyFormat.withoutCurrencySuffix(
      RemoteMoneyFormat.formatMinor(pricing.perMonthEquivalentMinor, locale: locale),
    );
    final original = pricing.hasDiscount
        ? RemoteMoneyFormat.withoutCurrencySuffix(
            RemoteMoneyFormat.formatMinor(
              (pricing.originalMinor / 12).round(),
              locale: locale,
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (original != null)
          Text(
            original,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9B96A3),
              decoration: TextDecoration.lineThrough,
              height: 1.1,
            ),
          ),
        Text(
          perMonth,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.03 * 18, color: ink, height: 1),
        ),
        Text(
          perMonthUnit,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: muted),
        ),
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? SubscriptionColors.violet : const Color(0xFFB9B3C3), width: selected ? 5 : 1.5),
      ),
    );
  }
}

enum _TagStyle { recommended, current, yearlyOnly }

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.style, this.isDark = false});

  final String label;
  final _TagStyle style;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    final colors = switch (style) {
      _TagStyle.recommended => (SubscriptionColors.violet, Colors.white),
      _TagStyle.current => isDark ? (const Color(0xFFF3EEF8), const Color(0xFF16121C)) : (const Color(0xFF1C1722), const Color(0xFFF6F3F9)),
      _TagStyle.yearlyOnly => isDark ? (const Color(0xFF3A2F4E), const Color(0xFFD8C6FF)) : (const Color(0xFFECE8F2), const Color(0xFF5B21B6)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.$1, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 16,
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: colors.$2),
            ),
          ),
        ),
      ),
    );
  }
}