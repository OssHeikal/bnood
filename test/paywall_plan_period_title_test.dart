import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/features/subscription/paywall_plan_period_title.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const yearlyFromPackage = AppPaywallPlan(
    id: 'yearly',
    label: 'Premium',
    monthlyEquivalentMinor: 24917,
    totalBilledMinor: 299000,
  );
  const monthlyFromPackage = AppPaywallPlan(
    id: 'monthly',
    label: 'Premium',
    monthlyEquivalentMinor: 29900,
  );

  testWidgets('AR period titles for expanded package plans', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return Column(
              children: [
                Text(paywallPlanPeriodTitle(yearlyFromPackage, l10n)),
                Text(paywallPlanPeriodTitle(monthlyFromPackage, l10n)),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('سنوية'), findsOneWidget);
    expect(find.text('شهرية'), findsOneWidget);
    expect(find.text('Premium'), findsNothing);
    expect(find.text('بريميوم'), findsNothing);
  });

  testWidgets('EN period titles', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return Text(paywallPlanPeriodTitle(yearlyFromPackage, l10n));
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Yearly'), findsOneWidget);
  });
}
