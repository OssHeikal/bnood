import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_form_route_canvas.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/subscription/app_subscription.dart';
import '../../core/subscription/subscription_colors.dart';
import '../../core/utils/safe_external_url.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import 'paywall_theme.dart';
import 'widgets/paywall_benefit_row.dart';
import 'widgets/paywall_billing_toggle.dart';
import 'widgets/paywall_comparison_table.dart';
import 'widgets/paywall_footer_dock.dart';
import 'widgets/paywall_offer_banner.dart';
import 'widgets/paywall_package_card.dart';
import 'widgets/paywall_legal_links.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.content});

  final AppPaywallContent content;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late String _selectedPackageSlug;
  late String _billingPeriod;

  AppPaywallV3Data get _v3 => widget.content.v3!;

  @override
  void initState() {
    super.initState();
    _selectedPackageSlug = _v3.initialPackageSlug();
    _billingPeriod = _v3.initialBillingPeriod();
  }

  AppPaywallPackage get _selectedPackage => _v3.packageBySlug(_selectedPackageSlug) ?? _v3.packages.first;

  String _resolveCta() => _selectedPackage.resolveCta(_billingPeriod);

  void _onPrimaryPressed() {
    final pkg = _selectedPackage;
    final l10n = AppLocalizations.of(context);
    if (pkg.isContact) {
      final url = pkg.contactUrl;
      if (url != null && url.trim().isNotEmpty) {
        launchAllowedUrl(url.trim());
        return;
      }
      AppToaster.show(l10n.subscriptionPaymentNotConnectedYet, kind: ToastKind.info);
      return;
    }
    AppToaster.show(l10n.subscriptionPaymentNotConnectedYet, kind: ToastKind.info);
  }

  String? _contextLine() => _v3.context?.resolvedLine();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final theme = PaywallTheme.of(context);
    final benefits = _v3.benefitItems;
    final anyYearly = _v3.packages.any((p) => p.yearlyEnabled);
    final anyMonthly = _v3.packages.any((p) => p.monthlyEnabled);
    final showBillingToggle = anyYearly && anyMonthly;

    return AppFormRouteCanvas(
      child: Scaffold(
        backgroundColor: theme.canvas,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.gradientTop, theme.canvas],
              stops: const [0, 0.45],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    PaywallTheme.edgeGutter,
                    AppSize.spaceXS,
                    PaywallTheme.edgeGutter,
                    0,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        if (navigator.canPop()) {
                          navigator.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: Icon(Icons.close, size: 20, color: theme.muted.withValues(alpha: 0.85)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      PaywallTheme.edgeGutter,
                      0,
                      PaywallTheme.edgeGutter,
                      PaywallTheme.listBottomPadding,
                    ),
                    children: [
                      Text(
                        _v3.header.title,
                        style: theme.headline,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: PaywallTheme.heroAfterSubtitle),
                      Text(
                        _v3.header.subtitle,
                        style: theme.subheadline,
                        textAlign: TextAlign.start,
                      ),
                      if (_contextLine() != null) ...[
                        const SizedBox(height: PaywallTheme.blockGap),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.card,
                              border: Border.all(color: theme.line),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                _contextLine()!,
                                style: theme.contextChip,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_v3.offerBanner != null) ...[
                        const SizedBox(height: PaywallTheme.blockGap),
                        PaywallOfferBanner(banner: _v3.offerBanner!),
                      ],
                      if (benefits.isNotEmpty) ...[
                        const SizedBox(height: PaywallTheme.blockGap),
                        for (var i = 0; i < benefits.length; i++)
                          PaywallBenefitRow(
                            text: benefits[i].text,
                            iconKey: benefits[i].icon,
                            textStyle: theme.benefit,
                            isLast: i == benefits.length - 1,
                          ),
                      ],
                      if (_v3.socialProof != null) ...[
                        const SizedBox(height: PaywallTheme.blockGap),
                        Text(
                          _v3.socialProof!.text,
                          style: theme.proof,
                          textAlign: TextAlign.start,
                        ),
                      ],
                      const SizedBox(height: PaywallTheme.beforePlans),
                      if (showBillingToggle) ...[
                        PaywallBillingToggle(
                          billing: _v3.billing,
                          selectedPeriod: _billingPeriod,
                          onPeriodChanged: (p) => setState(() => _billingPeriod = p),
                          showYearlySavingsBadge: true,
                        ),
                        const SizedBox(height: PaywallTheme.blockGap),
                      ],
                      for (var i = 0; i < _v3.packages.length; i++) ...[
                        PaywallPackageCard(
                          package: _v3.packages[i],
                          selected: _v3.packages[i].slug == _selectedPackageSlug,
                          billingPeriod: _billingPeriod,
                          localeCode: localeCode,
                          onTap: () => setState(() => _selectedPackageSlug = _v3.packages[i].slug),
                        ),
                        if (i < _v3.packages.length - 1) const SizedBox(height: PaywallTheme.betweenPlans),
                      ],
                      if (_v3.comparisonTable != null) ...[
                        const SizedBox(height: PaywallTheme.beforeComparison),
                        PaywallComparisonTable(
                          table: _v3.comparisonTable!,
                          selectedPackageSlug: _selectedPackageSlug,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    PaywallTheme.edgeGutter,
                    PaywallTheme.dockTopPadding,
                    PaywallTheme.edgeGutter,
                    PaywallTheme.dockBottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton.primary(
                        text: _resolveCta().isNotEmpty ? _resolveCta() : widget.content.subscribeCta,
                        backgroundColor: SubscriptionColors.violet,
                        size: AppButtonSize.large,
                        borderRadius: BorderRadius.circular(14),
                        textStyle: theme.footerReassure.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        onPressed: _onPrimaryPressed,
                      ),
                      const SizedBox(height: PaywallTheme.ctaFooterGap),
                      if (_v3.footer.reassurance != null || _v3.footer.restorePurchaseVisible)
                        PaywallFooterDock(
                          footer: _v3.footer,
                          onRestore: () => AppToaster.show(
                            l10n.subscriptionPaymentNotConnectedYet,
                            kind: ToastKind.info,
                          ),
                        )
                      else
                        const PaywallLegalLinks(),
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