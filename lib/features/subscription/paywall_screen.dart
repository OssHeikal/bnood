import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/subscription/app_subscription.dart';
import '../../core/subscription/subscription_colors.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import 'paywall_plan_period_title.dart';
import 'widgets/paywall_benefit_row.dart';
import 'widgets/paywall_legal_links.dart';
import 'widgets/paywall_plan_tile.dart';
import 'widgets/paywall_savings_badge.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.content});

  final AppPaywallContent content;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late String _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.content.planById('yearly') != null ? 'yearly' : widget.content.plans.first.id;
  }

  String _moneyLabel(int minor, String localeCode) {
    final locale = localeCode == 'ar' ? 'ar_EG' : 'en_US';
    return RemoteMoneyFormat.formatMinor(minor, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final content = widget.content;
    final yearly = content.planById('yearly');
    final monthly = content.planById('monthly');
    final hasOffer = content.offer != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SubscriptionColors.paywallCanvas,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [SubscriptionColors.paywallGradientTop, SubscriptionColors.paywallCanvas],
              stops: [0, 0.32],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceMD, AppSize.spaceSM, AppSize.spaceMD, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 22),
                      color: const Color(0xFF17141C),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      Text(
                        content.title,
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17141C),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6D6676),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      if (hasOffer) ...[
                        const SizedBox(height: 16),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: SubscriptionColors.violetDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Column(
                              children: [
                                Text(
                                  content.offer!.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (content.offer!.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    content.offer!.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFECE7F1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.paywallBenefitsHeading,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.08 * 11,
                                  color: Color(0xFF6D6676),
                                ),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 11),
                              for (final benefit in content.benefits) PaywallBenefitRow(text: benefit),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          if (yearly != null)
                            Expanded(
                              child: PaywallPlanTile(
                                plan: yearly,
                                selected: _selectedPlanId == yearly.id,
                                onTap: () => setState(() => _selectedPlanId = yearly.id),
                                periodTitle: paywallPlanPeriodTitle(yearly, l10n),
                                perMonthSuffix: l10n.paywallPerMonthSuffix,
                                monthlyPriceLabel: _moneyLabel(yearly.monthlyEquivalentMinor, localeCode),
                                originalMonthlyLabel: yearly.originalMonthlyEquivalentMinor == null
                                    ? null
                                    : _moneyLabel(yearly.originalMonthlyEquivalentMinor!, localeCode),
                                billedCaption: yearly.billedCaption ??
                                    (yearly.totalBilledMinor != null
                                        ? l10n.paywallBilledYearly(
                                            _moneyLabel(yearly.totalBilledMinor!, localeCode),
                                          )
                                        : null),
                                savingsBadge: hasOffer
                                    ? (content.offer!.yearlySavingsBadge ?? yearly.savingsBadge)
                                    : yearly.savingsBadge,
                                cornerBadge: PaywallSavingsBadge(
                                  label: hasOffer
                                      ? (content.offer!.yearlySavingsBadge ?? yearly.savingsBadge ?? '')
                                      : (yearly.savingsBadge ?? ''),
                                  visible: (hasOffer && (content.offer!.yearlySavingsBadge ?? '').isNotEmpty) ||
                                      (!hasOffer && (yearly.savingsBadge ?? '').isNotEmpty),
                                ),
                              ),
                            ),
                          if (yearly != null && monthly != null) const SizedBox(width: 10),
                          if (monthly != null)
                            Expanded(
                              child: PaywallPlanTile(
                                plan: monthly,
                                selected: _selectedPlanId == monthly.id,
                                onTap: () => setState(() => _selectedPlanId = monthly.id),
                                periodTitle: paywallPlanPeriodTitle(monthly, l10n),
                                perMonthSuffix: l10n.paywallPerMonthSuffix,
                                monthlyPriceLabel: _moneyLabel(monthly.monthlyEquivalentMinor, localeCode),
                                originalMonthlyLabel: monthly.originalMonthlyEquivalentMinor == null
                                    ? null
                                    : _moneyLabel(monthly.originalMonthlyEquivalentMinor!, localeCode),
                                billedCaption: monthly.billedCaption ?? l10n.paywallBilledMonthly,
                                savingsBadge: null,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (content.legal.isNotEmpty) ...[
                        Text(
                          content.legal,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.65,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9A95A0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                      const PaywallLegalLinks(),
                      AppSize.spaceMD.gap,
                      AppButton.primary(
                        text: content.subscribeCta.isNotEmpty ? content.subscribeCta : l10n.paywallSubscribeCta,
                        backgroundColor: SubscriptionColors.violet,
                        onPressed: () {
                          AppToaster.show(l10n.subscriptionPaymentNotConnectedYet, kind: ToastKind.info);
                        },
                      ),
                      AppSize.spaceSM.gap,
                      AppPressable(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            content.continueFreeCta.isNotEmpty
                                ? content.continueFreeCta
                                : l10n.paywallContinueFree,
                            style: const TextStyle(
                              color: Color(0xFF17141C),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
