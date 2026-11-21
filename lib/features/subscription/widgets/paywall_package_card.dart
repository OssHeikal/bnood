import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/subscription/paywall_money_display.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../paywall_theme.dart';

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
    final theme = PaywallTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idleFill = isDark ? const Color(0xFF221C2B) : Colors.white;
    final selectedFill = isDark ? const Color(0xFF2A1D40) : SubscriptionColors.violetSoft;
    final l10n = AppLocalizations.of(context);

    final effectivePeriod = package.effectivePeriodWhen(billingPeriod);
    final showYearlyOnlyHint = billingPeriod == 'monthly' && package.yearlyOnly;
    final pricing = effectivePeriod == 'yearly' ? package.pricing.yearly : package.pricing.monthly;

    return Material(
      color: selected ? selectedFill : idleFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? SubscriptionColors.violet : theme.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: PaywallTheme.planCardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _RadioDot(selected: selected),
              ),
              const SizedBox(width: AppSize.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlanTitleRow(
                      package: package,
                      showYearlyOnlyHint: showYearlyOnlyHint,
                      isDark: isDark,
                      planNameStyle: theme.planName,
                      currentPlanLabel: l10n.paywallCurrentPlanChip,
                    ),
                    if (package.tagline != null && package.tagline!.isNotEmpty) ...[
                      const SizedBox(height: AppSize.spaceXS),
                      Text(
                        package.tagline!,
                        style: theme.planMeta,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!package.isContact && pricing != null && effectivePeriod == 'yearly')
                      Padding(
                        padding: const EdgeInsets.only(top: AppSize.spaceXS),
                        child: _BilledYearlyLine(pricing: pricing, l10n: l10n, billedStyle: theme.planBilled),
                      )
                    else if (!package.isContact && effectivePeriod == 'monthly')
                      Padding(
                        padding: const EdgeInsets.only(top: AppSize.spaceXS),
                        child: Text(
                          l10n.paywallBilledMonthly,
                          style: theme.planBilled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSize.spaceMD),
              if (package.isContact)
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      package.contactCtaText ?? package.name,
                      textAlign: TextAlign.end,
                      style: theme.contactPrice,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else if (pricing != null)
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 84, maxWidth: 132),
                    child: _PriceBlock(
                      pricing: pricing,
                      perMonthUnit: l10n.paywallPerMonthUnit,
                      yearlyPeriod: effectivePeriod == 'yearly',
                      theme: theme,
                    ),
                  ),
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

class _PlanTitleRow extends StatelessWidget {
  const _PlanTitleRow({
    required this.package,
    required this.showYearlyOnlyHint,
    required this.isDark,
    required this.planNameStyle,
    required this.currentPlanLabel,
  });

  final AppPaywallPackage package;
  final bool showYearlyOnlyHint;
  final bool isDark;
  final TextStyle planNameStyle;
  final String currentPlanLabel;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (package.isCurrentPlan) {
      chips.add(
        _Tag(
          label: currentPlanLabel,
          background: isDark ? const Color(0xFF2A1D40) : SubscriptionColors.violetSoft,
          foreground: isDark ? const Color(0xFFD8C6FF) : SubscriptionColors.violetDark,
        ),
      );
    } else if (package.badgeLabel != null && package.badgeLabel!.isNotEmpty) {
      chips.add(
        _Tag(
          label: package.badgeLabel!,
          background: PaywallPackageCard._badgeBackground(package.badgeType, isDark),
          foreground: PaywallPackageCard._badgeForeground(package.badgeType, isDark),
        ),
      );
    }

    if (showYearlyOnlyHint && (package.yearlyOnlyLabel ?? '').isNotEmpty) {
      chips.add(
        _Tag(
          label: package.yearlyOnlyLabel!,
          background: isDark ? const Color(0xFF3A2F4E) : const Color(0xFFECE8F2),
          foreground: isDark ? const Color(0xFFD8C6FF) : const Color(0xFF5B21B6),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            package.name,
            style: planNameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(width: AppSize.spaceSM),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                chips[i],
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _BilledYearlyLine extends StatelessWidget {
  const _BilledYearlyLine({
    required this.pricing,
    required this.l10n,
    required this.billedStyle,
  });

  final AppPaywallPeriodPricing pricing;
  final AppLocalizations l10n;
  final TextStyle billedStyle;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final billed = pricing.resolvedBilledYearlyMajor();
    if (billed == null) return const SizedBox.shrink();
    final billedText = DisplayDigits.toWesternDigits(
      PaywallMoneyDisplay.formatMajorAmount(billed, arabic: arabic),
    );
    final originalBilled = pricing.resolvedOriginalBilledYearlyMajor();
    final strikeStyle = billedStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      color: const Color(0xFF9B96A3),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    if (originalBilled != null && originalBilled > billed) {
      final originalText = DisplayDigits.toWesternDigits(
        PaywallMoneyDisplay.formatMajorAmount(originalBilled, arabic: arabic),
      );
      return Text.rich(
        TextSpan(
          style: billedStyle,
          children: [
            TextSpan(text: '${l10n.paywallBilledYearlyIntro} '),
            TextSpan(text: originalText, style: strikeStyle),
            const TextSpan(text: ' '),
            TextSpan(text: billedText),
            TextSpan(text: ' ${l10n.paywallBilledYearlySuffix}'),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      l10n.paywallBilledYearlyAt(billedText),
      style: billedStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.pricing,
    required this.perMonthUnit,
    required this.yearlyPeriod,
    required this.theme,
  });

  final AppPaywallPeriodPricing pricing;
  final String perMonthUnit;
  final bool yearlyPeriod;
  final PaywallTheme theme;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final perMonthMajor = pricing.resolvedPerMonthMajor(arabic: arabic);
    final originalPerMonth = pricing.resolvedOriginalPerMonthMajor(yearlyPeriod: yearlyPeriod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (originalPerMonth != null && originalPerMonth > perMonthMajor)
          Text(
            DisplayDigits.formatInteger(originalPerMonth),
            style: theme.priceStrike,
            maxLines: 1,
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              DisplayDigits.formatInteger(perMonthMajor),
              style: theme.priceAmount,
              maxLines: 1,
            ),
            const SizedBox(width: 3),
            Text(
              perMonthUnit,
              style: theme.priceUnit,
              maxLines: 1,
              softWrap: false,
            ),
          ],
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
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? SubscriptionColors.violet : const Color(0xFFB9B3C3),
          width: selected ? 5 : 1.5,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: foreground, height: 1.1),
        ),
      ),
    );
  }
}