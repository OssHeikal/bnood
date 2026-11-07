import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_card.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/home/widgets/home_person_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('accent stripe is inside clipped AppCard bounds', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: HomeFoundationScope(
          child: Scaffold(
            body: HomePersonCard(
              name: 'Osama',
              meta: null,
              amountPiastres: 100000,
              accentKey: 'teal',
              localeCode: 'ar',
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardFinder = find.byType(AppCard);
    final stripeFinder = find.descendant(of: cardFinder, matching: find.byType(ColoredBox));
    expect(stripeFinder, findsOneWidget);

    final card = tester.getRect(cardFinder);
    final stripe = tester.getRect(stripeFinder);
    expect(stripe.left, greaterThanOrEqualTo(card.left - 0.5));
    expect(stripe.right, lessThanOrEqualTo(card.right + 0.5));
    expect(stripe.top, greaterThanOrEqualTo(card.top - 0.5));
    expect(stripe.bottom, lessThanOrEqualTo(card.bottom + 0.5));
  });
}
