import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/formatting/display_digits.dart';
import '../../../core/subscription/paywall_money_display.dart';
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
                        Text(
                          package.name,
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: ink),
                        ),
                        if (package.isCurrentPlan)
                          _Tag(
                            label: l10n.paywallCurrentPlanChip,
                            background: isDark ? const Color(0xFF2A1D40) : SubscriptionColors.violetSoft,
                            foreground: isDark ? const Color(0xFFD8C6FF) : SubscriptionColors.violetDark,
                          )
                        else if (package.badgeLabel != null && package.badgeLabel!.isNotEmpty)
                          _Tag(
                            label: package.badgeLabel!,
                            background: _badgeBackground(package.badgeType, isDark),
                            foreground: _badgeForeground(package.badgeType, isDark),
                          ),
                        if (showYearlyOnlyHint && (package.yearlyOnlyLabel ?? '').isNotEmpty)
                          _Tag(
                            label: package.yearlyOnlyLabel!,
                            background: isDark ? const Color(0xFF3A2F4E) : const Color(0xFFECE8F2),
                            foreground: isDark ? const Color(0xFFD8C6FF) : const Color(0xFF5B21B6),
                          ),
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
                    if (!package.isContact && pricing != null && effectivePeriod == 'yearly')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _BilledYearlyLine(pricing: pricing, l10n: l10n, muted: muted),
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
                  perMonthUnit: l10n.paywallPerMonthUnit,
                  yearlyPeriod: effectivePeriod == 'yearly',
                  muted: muted,
                  ink: ink,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _badgeBackground(String? badgeType, bool isDark) {
    return switch (badgeType) {
      'recommended' || 'most_popular' => SubscriptionColors.violet,
      'for_offices' => isDark ? const Color(0xFF3A3220) : const Color(0xFFF3EEE3),
      _ => isDark ? const Color(0xFF2A2433) : const Color(0xFFECE8F2),
    };
  }

  static Color _badgeForeground(String? badgeType, bool isDark) {
    return switch (badgeType) {
      'recommended' || 'most_popular' => Colors.white,
      'for_offices' => isDark ? const Color(0xFFE6C98A) : const Color(0xFF7A5A1E),
      _ => isDark ? const Color(0xFFD8C6FF) : SubscriptionColors.violetDark,
    };
  }
}

class _BilledYearlyLine extends StatelessWidget {
  const _BilledYearlyLine({
    required this.pricing,
    required this.l10n,
    required this.muted,
  });

  final AppPaywallPeriodPricing pricing;
  final AppLocalizations l10n;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final billed = pricing.resolvedBilledYearlyMajor();
    if (billed == null) return const SizedBox.shrink();
    final billedText = DisplayDigits.toWesternDigits(
      PaywallMoneyDisplay.formatMajorAmount(billed, arabic: arabic),
    );
    final originalBilled = pricing.resolvedOriginalBilledYearlyMajor();
    final baseStyle = TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: muted, height: 1.3);

    if (originalBilled != null && originalBilled > billed) {
      final originalText = DisplayDigits.toWesternDigits(
        PaywallMoneyDisplay.formatMajorAmount(originalBilled, arabic: arabic),
      );
      return Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: '${l10n.paywallBilledYearlyIntro} '),
            TextSpan(
              text: originalText,
              style: baseStyle.copyWith(
                decoration: TextDecoration.lineThrough,
                color: const Color(0xFF9B96A3),
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: billedText),
            TextSpan(text: ' ${l10n.paywallBilledYearlySuffix}'),
          ],
        ),
      );
    }

    return Text(
      l10n.paywallBilledYearlyAt(billedText),
      style: baseStyle,
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.pricing,
    required this.perMonthUnit,
    required this.yearlyPeriod,
    required this.muted,
    required this.ink,
  });

  final AppPaywallPeriodPricing pricing;
  final String perMonthUnit;
  final bool yearlyPeriod;
  final Color muted;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final perMonthMajor = pricing.resolvedPerMonthMajor(arabic: arabic);
    final originalPerMonth = pricing.resolvedOriginalPerMonthMajor(yearlyPeriod: yearlyPeriod);
    final perMonthDigits = DisplayDigits.formatInteger(perMonthMajor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (originalPerMonth != null && originalPerMonth > perMonthMajor)
          Text(
            DisplayDigits.formatInteger(originalPerMonth),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9B96A3),
              decoration: TextDecoration.lineThrough,
              height: 1.1,
            ),
          ),
        Text(
          perMonthDigits,
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 16,
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}