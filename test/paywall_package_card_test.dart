import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/subscription/paywall_v3_models.dart';
import 'package:bnood/features/subscription/widgets/paywall_billing_toggle.dart';
import 'package:bnood/features/subscription/widgets/paywall_package_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const businessYearlyOnly = AppPaywallPackage(
    slug: 'business',
    name: 'Business',
    purchaseMode: 'checkout',
    monthlyEnabled: false,
    yearlyEnabled: true,
    yearlyOnlyLabel: 'Yearly only',
    pricing: AppPaywallPackagePricing(
      yearly: AppPaywallPeriodPricing(
        originalMinor: 700_000,
        discountedMinor: 700_000,
        perMonthEquivalentMinor: 58_333,
        displayPerMonthMajor: 583,
      ),
    ),
    ctaLabels: AppPaywallPackageCtaLabels(yearly: 'Go'),
    highlightBenefits: const [
      AppPaywallBenefitItem(icon: 'projects_grid', text: '10 active projects'),
    ],
  );

  const enterpriseContact = AppPaywallPackage(
    slug: 'enterprise',
    name: 'Enterprise',
    tagline: 'For larger offices, unlimited projects',
    purchaseMode: 'contact',
    contactCtaText: 'Contact us',
    monthlyEnabled: false,
    yearlyEnabled: false,
    pricing: AppPaywallPackagePricing(),
    ctaLabels: AppPaywallPackageCtaLabels(contact: 'Contact us'),
  );

  Widget wrap({
    required Widget child,
    Locale locale = const Locale('en'),
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 840)),
        child: Directionality(
          textDirection: textDirection,
          child: Scaffold(body: Center(child: SizedBox(width: 360, child: child))),
        ),
      ),
    );
  }

  test('contact package is not selectable on monthly billing period', () {
    expect(enterpriseContact.selectableForBillingPeriod('monthly'), isFalse);
    expect(enterpriseContact.selectableForBillingPeriod('yearly'), isTrue);
  });

  testWidgets('monthly tab ghosts Enterprise and shows tagline', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallPackageCard(
          package: enterpriseContact,
          selected: false,
          billingPeriod: 'monthly',
          localeCode: 'en',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('For larger offices, unlimited projects'), findsOneWidget);
    expect(find.text('Contact us'), findsOneWidget);

    final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Enterprise'), matching: find.byType(Opacity)));
    expect(opacity.opacity, 0.45);
  });

  testWidgets('Business monthly shows yearly-only badge trailing, hides price', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallPackageCard(
          package: businessYearlyOnly,
          selected: false,
          billingPeriod: 'monthly',
          localeCode: 'en',
          onTap: () {},
        ),
        textDirection: TextDirection.rtl,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yearly only'), findsOneWidget);
    expect(find.text('583'), findsNothing);
    expect(find.text('10 active projects'), findsOneWidget);
    final business = tester.getRect(find.text('Business'));
    final badge = tester.getRect(find.text('Yearly only'));
    expect(business.center.dx, greaterThan(badge.center.dx));
  });

  testWidgets('billing toggle yearly savings chip has breathable horizontal padding', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallBillingToggle(
          billing: const AppPaywallBilling(
            monthlyLabel: 'Monthly',
            yearlyLabel: 'Yearly',
            yearlySavingsPercent: 16,
          ),
          selectedPeriod: 'yearly',
          onPeriodChanged: (_) {},
          showYearlySavingsBadge: true,
        ),
        locale: const Locale('en'),
        textDirection: TextDirection.ltr,
      ),
    );
    await tester.pumpAndSettle();

    final pill = tester.getSize(find.text('Save 16%'));
    expect(pill.width, greaterThan(52));

    final yearly = tester.getRect(find.text('Yearly'));
    final chip = tester.getRect(find.text('Save 16%'));
    expect(chip.left - yearly.right, greaterThan(8));
  });
}