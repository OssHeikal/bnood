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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? const Color(0xFFF3EEF8) : const Color(0xFF1C1722);
    final muted = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);
    final card = isDark ? const Color(0xFF221C2B) : Colors.white;
    final line = isDark ? const Color(0xFF322B3C) : const Color(0xFFE7E2EE);
    final canvas = isDark ? const Color(0xFF16121C) : SubscriptionColors.paywallCanvas;
    final gradientTop = isDark ? const Color(0xFF221833) : SubscriptionColors.paywallGradientTop;

    final benefits = _v3.benefitItems;
    final anyYearly = _v3.packages.any((p) => p.yearlyEnabled);
    final anyMonthly = _v3.packages.any((p) => p.monthlyEnabled);
    final showBillingToggle = anyYearly && anyMonthly;

    return AppFormRouteCanvas(
      child: Scaffold(
        backgroundColor: canvas,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientTop, canvas],
              stops: const [0, 0.45],
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
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        if (navigator.canPop()) {
                          navigator.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: Icon(Icons.close, size: 22, color: muted.withValues(alpha: 0.85)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                    children: [
                      Text(
                        _v3.header.title,
                        style: TextStyle(fontSize: 24, height: 1.28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.03 * 24),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _v3.header.subtitle,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: muted, height: 1.5),
                        textAlign: TextAlign.start,
                      ),
                      if (_contextLine() != null) ...[
                        const SizedBox(height: 10),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: card,
                            border: Border.all(color: line),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text(
                              _contextLine()!,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: muted),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ],
                      if (_v3.offerBanner != null) ...[
                        const SizedBox(height: 10),
                        PaywallOfferBanner(banner: _v3.offerBanner!),
                      ],
                      const SizedBox(height: 10),
                      for (final item in benefits)
                        PaywallBenefitRow(text: item.text, iconKey: item.icon),
                      if (_v3.socialProof != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _v3.socialProof!.text,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: muted),
                          textAlign: TextAlign.start,
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (showBillingToggle) ...[
                        PaywallBillingToggle(
                          billing: _v3.billing,
                          selectedPeriod: _billingPeriod,
                          onPeriodChanged: (p) => setState(() => _billingPeriod = p),
                          showYearlySavingsBadge: true,
                        ),
                        const SizedBox(height: 10),
                      ],
                      for (final pkg in _v3.packages) ...[
                        PaywallPackageCard(
                          package: pkg,
                          selected: pkg.slug == _selectedPackageSlug,
                          billingPeriod: _billingPeriod,
                          localeCode: localeCode,
                          onTap: () => setState(() => _selectedPackageSlug = pkg.slug),
                        ),
                        const SizedBox(height: 7),
                      ],
                      if (_v3.comparisonTable != null) ...[
                        PaywallComparisonTable(
                          table: _v3.comparisonTable!,
                          selectedPackageSlug: _selectedPackageSlug,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton.primary(
                        text: _resolveCta().isNotEmpty ? _resolveCta() : widget.content.subscribeCta,
                        backgroundColor: SubscriptionColors.violet,
                        onPressed: _onPrimaryPressed,
                      ),
                      const SizedBox(height: 6),
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