import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/app_form_route_canvas.dart';
import '../../../../core/config/theme/app_size.dart';
import 'package:bnood/features/subscription/data/app_subscription.dart';
import 'package:bnood/features/subscription/data/paywall_contact.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';
import '../../../../core/widgets/app_toaster.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_theme.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_billing_toggle.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_comparison_sheet.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_footer_dock.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_offer_banner.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_package_card.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_legal_links.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, required this.content});

  final AppPaywallContent content;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  late String _selectedPackageSlug;
  late String _billingPeriod;

  AppPaywallV3Data get _v3 => widget.content.v3!;

  @override
  void initState() {
    super.initState();
    _selectedPackageSlug = _v3.initialPackageSlug();
    _billingPeriod = _v3.initialBillingPeriod();
  }

  AppPaywallPackage get _selectedPackage =>
      _v3.packageBySlug(_selectedPackageSlug) ?? _v3.packages.first;

  String _resolveCta() => _selectedPackage.resolveCta(_billingPeriod);

  void _onBillingPeriodChanged(String period) {
    setState(() {
      _billingPeriod = period;
      if (period == 'monthly') {
        final current = _v3.packageBySlug(_selectedPackageSlug);
        if (current == null || !current.selectableForBillingPeriod('monthly')) {
          final next = _v3.firstSelectablePackageSlugForPeriod('monthly');
          if (next != null) {
            _selectedPackageSlug = next;
          }
        }
      }
    });
  }

  void _onPackageTap(AppPaywallPackage package) {
    if (_billingPeriod == 'monthly' &&
        !package.selectableForBillingPeriod('monthly')) {
      AppToaster.show(
        AppLocalizations.of(context).paywallYearlyOnlyHint,
        kind: ToastKind.info,
      );
      return;
    }
    setState(() => _selectedPackageSlug = package.slug);
  }

  void _onPrimaryPressed() {
    final pkg = _selectedPackage;
    final l10n = AppLocalizations.of(context);
    if (pkg.isContact) {
      final periodLabel = _billingPeriod == 'yearly'
          ? l10n.paywallPlanYearly
          : l10n.paywallPlanMonthly;
      final user = ref.read(authControllerProvider).user;
      launchPaywallContact(
        contact: pkg.contact,
        legacyContactUrl: pkg.contactUrl,
        planName: pkg.name,
        periodLabel: periodLabel,
        userName: user?.name,
        userPhone: user?.phone,
      ).then((opened) {
        if (!opened && context.mounted) {
          AppToaster.show(
            l10n.subscriptionPaymentNotConnectedYet,
            kind: ToastKind.info,
          );
        }
      });
      return;
    }
    AppToaster.show(
      l10n.subscriptionPaymentNotConnectedYet,
      kind: ToastKind.info,
    );
  }

  String? _contextLine() => _v3.context?.resolvedLine();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final theme = PaywallTheme.of(context);
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
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        if (navigator.canPop()) {
                          navigator.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: theme.muted.withValues(alpha: 0.85),
                      ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
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
                          onPeriodChanged: _onBillingPeriodChanged,
                          showYearlySavingsBadge: true,
                        ),
                        const SizedBox(height: PaywallTheme.blockGap),
                      ],
                      for (var i = 0; i < _v3.packages.length; i++) ...[
                        PaywallPackageCard(
                          package: _v3.packages[i],
                          selected:
                              _v3.packages[i].slug == _selectedPackageSlug,
                          billingPeriod: _billingPeriod,
                          localeCode: localeCode,
                          onTap: () => _onPackageTap(_v3.packages[i]),
                        ),
                        if (i < _v3.packages.length - 1)
                          const SizedBox(height: PaywallTheme.betweenPlans),
                      ],
                      if (_v3.comparisonTable != null) ...[
                        const SizedBox(height: PaywallTheme.blockGap),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: AppButton(
                            text: l10n.paywallComparePlans,
                            style: AppButtonStyle.text,
                            icon: Icons.table_rows_rounded,
                            size: AppButtonSize.small,
                            isExpanded: false,
                            foregroundColor: SubscriptionColors.violet,
                            textStyle: theme.subheadline.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: SubscriptionColors.violet,
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              6,
                              AppSize.spaceSM,
                              6,
                            ),
                            onPressed: () => PaywallComparisonSheet.show(
                              context,
                              table: _v3.comparisonTable!,
                              selectedPackageSlug: _selectedPackageSlug,
                            ),
                          ),
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
                        text: _resolveCta().isNotEmpty
                            ? _resolveCta()
                            : widget.content.subscribeCta,
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
                      if (_v3.footer.reassurance != null ||
                          _v3.footer.restorePurchaseVisible)
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
