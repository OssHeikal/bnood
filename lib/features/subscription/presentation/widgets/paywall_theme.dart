import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';

/// Paywall-specific colors and text roles aligned with docs/paywall-v3/index.html.
class PaywallTheme {
  const PaywallTheme._({
    required this.ink,
    required this.muted,
    required this.legal,
    required this.card,
    required this.line,
    required this.canvas,
    required this.gradientTop,
    required this.headline,
    required this.subheadline,
    required this.contextChip,
    required this.benefit,
    required this.proof,
    required this.planName,
    required this.planMeta,
    required this.planBenefit,
    required this.planBilled,
    required this.priceAmount,
    required this.priceStrike,
    required this.priceUnit,
    required this.contactPrice,
    required this.compareHeader,
    required this.compareRow,
    required this.compareCell,
    required this.compareCheck,
    required this.compareCheckSelected,
    required this.footerReassure,
    required this.footerLegal,
    required this.offerBanner,
  });

  final Color ink;
  final Color muted;
  final Color legal;
  final Color card;
  final Color line;
  final Color canvas;
  final Color gradientTop;

  final TextStyle headline;
  final TextStyle subheadline;
  final TextStyle contextChip;
  final TextStyle benefit;
  final TextStyle proof;
  final TextStyle planName;
  final TextStyle planMeta;
  final TextStyle planBenefit;
  final TextStyle planBilled;
  final TextStyle priceAmount;
  final TextStyle priceStrike;
  final TextStyle priceUnit;
  final TextStyle contactPrice;
  final TextStyle compareHeader;
  final TextStyle compareRow;
  final TextStyle compareCell;

  /// Checkmarks in non-selected plan columns (brand teal).
  final Color compareCheck;

  /// Checkmarks in the selected plan column (brand purple).
  final Color compareCheckSelected;
  final TextStyle footerReassure;
  final TextStyle footerLegal;
  final TextStyle offerBanner;

  static PaywallTheme of(BuildContext context) {
    final text = context.text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? const Color(0xFFF3EEF8) : const Color(0xFF1C1722);
    final muted = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);
    final legal = isDark ? const Color(0xFF8F8798) : const Color(0xFF8E8896);

    return PaywallTheme._(
      ink: ink,
      muted: muted,
      legal: legal,
      card: isDark ? const Color(0xFF221C2B) : Colors.white,
      line: isDark ? const Color(0xFF322B3C) : const Color(0xFFE7E2EE),
      canvas: isDark
          ? const Color(0xFF16121C)
          : SubscriptionColors.paywallCanvas,
      gradientTop: isDark
          ? const Color(0xFF221833)
          : SubscriptionColors.paywallGradientTop,
      headline: text.pageTitle.copyWith(
        fontSize: 24,
        height: 1.28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 24,
        color: ink,
      ),
      subheadline: text.supporting.copyWith(
        fontSize: 13.5,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      contextChip: text.caption.copyWith(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: muted,
      ),
      benefit: text.bodyEmphasis.copyWith(
        fontSize: 13.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      proof: text.caption.copyWith(
        fontSize: 11.5,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      planName: text.cardTitle.copyWith(
        fontSize: 16.5,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 16.5,
        color: ink,
      ),
      planMeta: text.caption.copyWith(
        fontSize: 11.5,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      planBenefit: text.caption.copyWith(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      planBilled: text.caption.copyWith(
        fontSize: 10.5,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      priceAmount: text.moneyMd.copyWith(
        fontSize: 22,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 22,
        color: ink,
      ),
      priceStrike: text.caption.copyWith(
        fontSize: 10.5,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF9B96A3),
        decoration: TextDecoration.lineThrough,
      ),
      priceUnit: text.caption.copyWith(
        fontSize: 10,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      contactPrice: text.cardTitle.copyWith(
        fontSize: 12.5,
        height: 1.3,
        fontWeight: FontWeight.w800,
        color: isDark ? const Color(0xFFC4A6FF) : SubscriptionColors.violet,
      ),
      compareHeader: text.caption.copyWith(
        fontSize: 10.5,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      compareRow: text.groupTitle.copyWith(
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: muted,
      ),
      compareCell: text.caption.copyWith(
        fontSize: 10.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      compareCheck: isDark ? const Color(0xFF3ED9C6) : const Color(0xFF0F9D8E),
      compareCheckSelected: isDark
          ? const Color(0xFFE4D4FF)
          : SubscriptionColors.violetDark,
      footerReassure: text.caption.copyWith(
        fontSize: 11,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      footerLegal: text.caption.copyWith(
        fontSize: 11,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: legal,
      ),
      offerBanner: text.bodyEmphasis.copyWith(
        fontSize: 12.5,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }

  /// Scroll / section rhythm (8pt grid).
  static const edgeGutter = 18.0;
  static const sectionGap = AppSize.spaceMD;
  static const blockGap = AppSize.spaceSM;
  static const heroAfterSubtitle = AppSize.spaceXS;
  static const betweenPlans = AppSize.spaceLG;
  static const planCardPadding = EdgeInsets.symmetric(
    horizontal: AppSize.spaceLG,
    vertical: 14,
  );
  static const beforePlans = sectionGap;
  static const beforeComparison = sectionGap;
  static const dockTopPadding = AppSize.spaceSM;
  static const dockBottomPadding = AppSize.spaceLG;
  static const listBottomPadding = AppSize.spaceMD;
  static const ctaFooterGap = AppSize.spaceSM;
}
