import 'package:flutter/material.dart';

import '../../../core/subscription/app_subscription.dart';
import '../../../core/subscription/subscription_colors.dart';
import 'paywall_savings_badge.dart';

class PaywallPlanTile extends StatelessWidget {
  const PaywallPlanTile({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
    required this.monthlyPriceLabel,
    required this.perMonthSuffix,
    required this.periodTitle,
    this.originalMonthlyLabel,
    this.billedCaption,
    this.savingsBadge,
    this.cornerBadge,
  });

  final AppPaywallPlan plan;
  final bool selected;
  final VoidCallback onTap;
  final String monthlyPriceLabel;
  final String perMonthSuffix;
  final String periodTitle;
  final String? originalMonthlyLabel;
  final String? billedCaption;
  final String? savingsBadge;
  final PaywallSavingsBadge? cornerBadge;

  @override
  Widget build(BuildContext context) {
    final unitSuffix = perMonthSuffix;

    return Material(
      color: selected ? SubscriptionColors.violetSoft : SubscriptionColors.planIdle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? SubscriptionColors.violet : Colors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (cornerBadge != null) cornerBadge!,
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 38, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    periodTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF17141C)),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  if (originalMonthlyLabel != null) ...[
                    Text(
                      originalMonthlyLabel!.replaceAll(' EGP', '').replaceAll(' EGP', ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9B96A3),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    textDirection: TextDirection.rtl,
                    spacing: 5,
                    children: [
                      Text(
                        monthlyPriceLabel.replaceAll(' EGP', ''),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -0.03 * 28,
                          color: Color(0xFF17141C),
                        ),
                      ),
                      Text(
                        unitSuffix,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6D6676)),
                      ),
                    ],
                  ),
                  if (billedCaption != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      billedCaption!,
                      style: const TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: Color(0xFF6D6676)),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
