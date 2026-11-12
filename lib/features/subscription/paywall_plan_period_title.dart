import 'package:bnood/l10n/app_localizations.dart';

import '../../core/subscription/app_subscription.dart';

/// Paywall tile title is billing period, not package name (`Premium` / بريميوم).
String paywallPlanPeriodTitle(AppPaywallPlan plan, AppLocalizations l10n) {
  return switch (plan.id) {
    'yearly' => l10n.paywallPlanYearly,
    'monthly' => l10n.paywallPlanMonthly,
    _ => plan.label,
  };
}
