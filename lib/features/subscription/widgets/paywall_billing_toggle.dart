import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';

class PaywallBillingToggle extends StatelessWidget {
  const PaywallBillingToggle({
    super.key,
    required this.billing,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.showYearlySavingsBadge,
  });

  final AppPaywallBilling billing;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final bool showYearlySavingsBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark ? const Color(0xFF2A2433) : const Color(0xFFE7E1EF);
    final l10n = AppLocalizations.of(context);
    final savingsPercent = billing.yearlySavingsPercent;

    return DecoratedBox(
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(child: _Option(
              label: billing.monthlyLabel,
              selected: selectedPeriod == 'monthly',
              onTap: () => onPeriodChanged('monthly'),
            )),
            Expanded(
              child: _Option(
                label: billing.yearlyLabel,
                selected: selectedPeriod == 'yearly',
                onTap: () => onPeriodChanged('yearly'),
                suffix: showYearlySavingsBadge && savingsPercent != null && savingsPercent > 0
                    ? l10n.paywallSavingsPercent(savingsPercent)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
    this.suffix,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onColor = isDark ? const Color(0xFFF3EEF8) : const Color(0xFF1C1722);
    final offColor = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);
    final card = isDark ? const Color(0xFF221C2B) : Colors.white;

    return Material(
      color: selected ? card : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      elevation: selected ? 0.5 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? onColor : offColor,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: SubscriptionColors.violet,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      suffix!,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}