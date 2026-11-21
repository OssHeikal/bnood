import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/subscription/paywall_money_display.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../paywall_theme.dart';
import 'paywall_benefit_row.dart';

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

    final monthlyBlocked = billingPeriod == 'monthly' && !package.selectableForBillingPeriod('monthly');
    final showYearlyOnlyTrailing = monthlyBlocked &&
        !package.isContact &&
        package.yearlyEnabled &&
        (package.yearlyOnlyLabel ?? '').isNotEmpty;
    final effectiveSelected = selected && !monthlyBlocked;
    final effectivePeriod = package.effectivePeriodWhen(billingPeriod);
    final pricing = effectivePeriod == 'yearly' ? package.pricing.yearly : package.pricing.monthly;
    final showPriceTrailing = !showYearlyOnlyTrailing && pricing != null && !package.isContact;
    final tagline = package.tagline?.trim() ?? '';
    final cardBenefits = package.highlightBenefits
        .where((b) => tagline.isEmpty || b.text.trim() != tagline)
        .toList();

    return Opacity(
      opacity: monthlyBlocked ? 0.45 : 1,
      child: Material(
        color: effectiveSelected ? selectedFill : idleFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: effectiveSelected ? SubscriptionColors.violet : theme.line,
            width: effectiveSelected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: monthlyBlocked ? null : onTap,
          child: Padding(
            padding: PaywallTheme.planCardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: _RadioDot(selected: effectiveSelected, enabled: !monthlyBlocked),
                ),
              const SizedBox(width: AppSize.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlanTitleRow(
                      package: package,
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
                    if (!monthlyBlocked && !package.isContact && effectivePeriod == 'monthly')
                      Padding(
                        padding: const EdgeInsets.only(top: AppSize.spaceXS),
                        child: Text(
                          l10n.paywallBilledMonthly,
                          style: theme.planBilled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (cardBenefits.isNotEmpty) ...[
                      const SizedBox(height: AppSize.spaceSM),
                      for (var i = 0; i < cardBenefits.length; i++)
                        PaywallBenefitRow(
                          text: cardBenefits[i].text,
                          iconKey: cardBenefits[i].icon,
                          textStyle: theme.planBenefit,
                          dense: true,
                          isLast: i == cardBenefits.length - 1,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSize.spaceMD),
              if (package.isContact)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    package.contactCtaText ?? package.name,
                    textAlign: TextAlign.end,
                    style: monthlyBlocked
                        ? theme.contactPrice.copyWith(color: theme.muted)
                        : theme.contactPrice,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else if (showYearlyOnlyTrailing)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _YearlyOnlyTrailingBadge(
                    label: package.yearlyOnlyLabel!,
                    isDark: isDark,
                  ),
                )
              else if (showPriceTrailing && pricing != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 84, maxWidth: 152),
                  child: _PriceBlock(
                    pricing: pricing,
                    unitLabel: effectivePeriod == 'yearly' ? l10n.paywallPerYearUnit : l10n.paywallPerMonthUnit,
                    yearlyPeriod: effectivePeriod == 'yearly',
                    theme: theme,
                  ),
                ),
            ],
          ),
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
    required this.isDark,
    required this.planNameStyle,
    required this.currentPlanLabel,
  });

  final AppPaywallPackage package;
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

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            package.name,
            style: planNameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
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

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.pricing,
    required this.unitLabel,
    required this.yearlyPeriod,
    required this.theme,
  });

  final AppPaywallPeriodPricing pricing;
  final String unitLabel;
  final bool yearlyPeriod;
  final PaywallTheme theme;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final yearlyMajor = pricing.resolvedBilledYearlyMajor() ??
        PaywallMoneyDisplay.wholeMajorFromMinor(pricing.discountedMinor);
    final originalYearly = pricing.resolvedOriginalBilledYearlyMajor();
    final perMonthMajor = pricing.resolvedPerMonthMajor(arabic: arabic);
    final originalPerMonth = pricing.resolvedOriginalPerMonthMajor(yearlyPeriod: false);

    final amountMajor = yearlyPeriod ? yearlyMajor : perMonthMajor;
    final strikeMajor = yearlyPeriod
        ? (originalYearly != null && originalYearly > yearlyMajor ? originalYearly : null)
        : originalPerMonth;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (strikeMajor != null && strikeMajor > amountMajor)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  DisplayDigits.formatInteger(strikeMajor),
                  style: theme.priceStrike,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    DisplayDigits.formatInteger(amountMajor),
                    style: theme.priceAmount,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unitLabel,
                    style: theme.priceUnit,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, this.enabled = true});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idleBorder = enabled
        ? const Color(0xFFB9B3C3)
        : (isDark ? const Color(0xFF4A4355) : const Color(0xFFD8D2DC));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected && enabled ? SubscriptionColors.violet : idleBorder,
          width: selected && enabled ? 5 : 1.5,
        ),
      ),
    );
  }
}

class _YearlyOnlyTrailingBadge extends StatelessWidget {
  const _YearlyOnlyTrailingBadge({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _Tag(
      label: label,
      background: isDark ? const Color(0xFF3A2F4E) : const Color(0xFFECE8F2),
      foreground: isDark ? const Color(0xFFD8C6FF) : const Color(0xFF5B21B6),
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