import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/features/content/data/content_page_record.dart';
import 'package:bnood/features/subscription/data/app_subscription.dart';
import 'package:bnood/features/content/data/content_page_provider.dart';
import 'package:bnood/features/content/presentation/screens/content_page_screen.dart';
import 'package:bnood/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final content = AppPaywallContent(
    title: 'Premium',
    subtitle: '',
    benefits: const [],
    subscribeCta: 'Subscribe',
    continueFreeCta: 'Continue',
    legal: 'By subscribing you agree to the terms.',
    plans: const [
      AppPaywallPlan(
        id: 'yearly',
        label: 'Yearly',
        monthlyEquivalentMinor: 1000,
      ),
    ],
    v3: AppPaywallV3Data(
      trigger: 'default',
      header: const AppPaywallHeader(title: 'Premium', subtitle: ''),
      benefitItems: const [],
      billing: const AppPaywallBilling(
        monthlyLabel: 'Monthly',
        yearlyLabel: 'Yearly',
      ),
      packages: [
        AppPaywallPackage(
          slug: 'pro',
          name: 'Pro',
          purchaseMode: 'checkout',
          pricing: const AppPaywallPackagePricing(),
          ctaLabels: const AppPaywallPackageCtaLabels(yearly: 'Subscribe'),
        ),
      ],
      footer: const AppPaywallFooter(),
    ),
  );

  testWidgets('paywall shows terms, privacy, and cancellation links', (
    tester,
  ) async {
    await tester.pumpWidget(_paywallApp(content));
    await tester.pump();

    expect(find.text('Terms of use'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Cancellation policy'), findsOneWidget);
  });

  testWidgets('terms link opens the terms page over the paywall', (
    tester,
  ) async {
    await tester.pumpWidget(_paywallApp(content));
    await tester.pump();

    await tester.tap(find.text('Terms of use'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ContentPageScreen), findsOneWidget);
    expect(find.text('terms'), findsWidgets);
  });
}

Widget _paywallApp(AppPaywallContent content) {
  return ProviderScope(
    overrides: [
      contentPageProvider.overrideWith((ref, slug) async {
        return ContentPage(
          slug: slug,
          locale: 'en',
          title: slug,
          body: 'Body',
          format: 'html',
          updatedAt: DateTime.utc(2026, 1, 1),
        );
      }),
    ],
    child: MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PaywallScreen(content: content),
    ),
  );
}
