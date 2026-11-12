import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/subscription/widgets/paywall_plan_tile.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('yearly tile without originalMinor does not show strikethrough', (tester) async {
    const plan = AppPaywallPlan(
      id: 'yearly',
      label: 'Premium',
      monthlyEquivalentMinor: 24917,
      totalBilledMinor: 299000,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: PaywallPlanTile(
              plan: plan,
              selected: true,
              onTap: () {},
              periodTitle: 'سنوية',
              perMonthSuffix: ' / الشهر',
              monthlyPriceLabel: '249.17',
              originalMonthlyLabel: null,
              billedCaption: 'يتحسب سنوياً 2,990 EGP',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('249.17'), findsOneWidget);
    expect(find.byWidgetPredicate(
      (w) => w is Text && w.style?.decoration == TextDecoration.lineThrough,
    ), findsNothing);
  });

  testWidgets('yearly tile with original shows strikethrough', (tester) async {
    const plan = AppPaywallPlan(
      id: 'yearly',
      label: 'Premium',
      monthlyEquivalentMinor: 17417,
      originalMonthlyEquivalentMinor: 24917,
      totalBilledMinor: 209000,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: PaywallPlanTile(
              plan: plan,
              selected: true,
              onTap: () {},
              periodTitle: 'سنوية',
              perMonthSuffix: ' / الشهر',
              monthlyPriceLabel: '174.17',
              originalMonthlyLabel: '249.17',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byWidgetPredicate(
      (w) => w is Text && w.style?.decoration == TextDecoration.lineThrough,
    ), findsOneWidget);
  });
}
