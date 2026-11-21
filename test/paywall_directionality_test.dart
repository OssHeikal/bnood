import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/features/subscription/data/paywall_v3_models.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_comparison_table.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_package_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const comparisonTable = AppPaywallComparisonTable(
    columns: [
      AppPaywallComparisonColumn(slug: 'pro', name: 'Pro'),
      AppPaywallComparisonColumn(slug: 'business', name: 'Business'),
      AppPaywallComparisonColumn(slug: 'enterprise', name: 'Enterprise'),
    ],
    rows: [
      AppPaywallComparisonRow(key: 'active_projects', label: 'مشاريع نشطة'),
      AppPaywallComparisonRow(key: 'pdf_export', label: 'كشوف PDF'),
    ],
    cells: {
      'pro': {'active_projects': '4', 'pdf_export': '✓'},
      'business': {'active_projects': '10', 'pdf_export': '✓'},
      'enterprise': {'active_projects': '∞', 'pdf_export': '✓'},
    },
  );

  final packageWithChip = AppPaywallPackage(
    slug: 'pro',
    name: 'Pro',
    isCurrentPlan: true,
    purchaseMode: 'checkout',
    monthlyEnabled: true,
    yearlyEnabled: true,
    pricing: AppPaywallPackagePricing(
      yearly: AppPaywallPeriodPricing(
        originalMinor: 300_000,
        discountedMinor: 250_000,
        perMonthEquivalentMinor: 20_833,
        billedTotalMinor: 250_000,
        displayPerMonthMajor: 99,
      ),
    ),
    ctaLabels: const AppPaywallPackageCtaLabels(yearly: 'Subscribe'),
  );

  Widget wrap({
    required Widget child,
    required TextDirection textDirection,
    required Locale locale,
    double width = 390,
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
          child: Scaffold(
            body: Center(
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('RTL comparison row label sits at layout start (right)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallComparisonTable(
          table: comparisonTable,
          selectedPackageSlug: 'pro',
        ),
        textDirection: TextDirection.rtl,
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();

    final label = tester.getRect(find.text('مشاريع نشطة'));
    final pro = tester.getRect(find.text('Pro'));
    expect(label.center.dx, greaterThan(pro.center.dx));
  });

  testWidgets('LTR comparison row label sits at layout start (left)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallComparisonTable(
          table: comparisonTable,
          selectedPackageSlug: 'pro',
        ),
        textDirection: TextDirection.ltr,
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    final label = tester.getRect(find.text('مشاريع نشطة'));
    final pro = tester.getRect(find.text('Pro'));
    expect(label.center.dx, lessThan(pro.center.dx));
  });

  testWidgets('RTL plan chip follows plan name in reading order', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallPackageCard(
          package: packageWithChip,
          selected: true,
          billingPeriod: 'yearly',
          localeCode: 'ar',
          onTap: () {},
        ),
        textDirection: TextDirection.rtl,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    final name = tester.getRect(find.text('Pro'));
    final chip = tester.getRect(find.text('باقتك الحالية'));
    expect(name.center.dx, greaterThan(chip.center.dx));
  });

  testWidgets('LTR plan chip follows plan name in reading order', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: PaywallPackageCard(
          package: packageWithChip,
          selected: true,
          billingPeriod: 'yearly',
          localeCode: 'en',
          onTap: () {},
        ),
        textDirection: TextDirection.ltr,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    final name = tester.getRect(find.text('Pro'));
    final chip = tester.getRect(find.text('Current plan'));
    expect(name.center.dx, lessThan(chip.center.dx));
  });
}
