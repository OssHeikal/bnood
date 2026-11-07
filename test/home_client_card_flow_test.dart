import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/widgets/app_card.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/home/widgets/home_person_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required Locale locale,
    required int received,
    required int spent,
    required int remaining,
    TextScaler textScaler = TextScaler.noScaling,
    Size surface = const Size(390, 220),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: HomeFoundationScope(
            child: Scaffold(
              body: HomePersonCard(
                name: 'Osama Client',
                receivedPiastres: received,
                spentPiastres: spent,
                amountPiastres: remaining,
                accentKey: 'teal',
                localeCode: locale.languageCode,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectTrailingInOutColumn(WidgetTester tester, {required Locale locale, required String name}) {
    final icons = find.byType(ShellNavIcon);
    expect(icons, findsNWidgets(2));

    final receiveIcon = tester.getRect(icons.at(0));
    final spendIcon = tester.getRect(icons.at(1));
    expect(spendIcon.center.dy - receiveIcon.center.dy, greaterThan(AppSize.spaceXS));

    final nameRect = tester.getRect(find.text(name));
    final remainingLabel = find.text(locale.languageCode == 'ar' ? 'المتبقي' : 'Remaining');
    expect(remainingLabel, findsOneWidget);
    final remainingRect = tester.getRect(remainingLabel);
    expect(remainingRect.top, greaterThan(nameRect.bottom - 2));

    final card = tester.getRect(find.byType(AppCard));
    if (locale.languageCode == 'en') {
      expect(receiveIcon.center.dx, greaterThan(nameRect.center.dx));
      expect(receiveIcon.right, greaterThan(nameRect.right - 8));
    } else {
      expect(receiveIcon.center.dx, lessThan(nameRect.center.dx));
      expect(receiveIcon.left, lessThan(nameRect.left + 8));
    }

    final amounts = find.descendant(of: find.byType(HomePersonCard), matching: find.byType(AppAmount));
    expect(amounts, findsNWidgets(3));
  }

  testWidgets('client card: remaining under name, in/out in trailing column EN', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), received: 100000, spent: 25000, remaining: 75000);

    expect(find.textContaining(AppAmount.format(piastres: 100000, localeCode: 'en')), findsOneWidget);
    expect(find.textContaining(AppAmount.format(piastres: 25000, localeCode: 'en')), findsOneWidget);
    expectTrailingInOutColumn(tester, locale: const Locale('en'), name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('trailing column for zero in/out amounts', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), received: 0, spent: 0, remaining: 0);
    expectTrailingInOutColumn(tester, locale: const Locale('en'), name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic at 1.2 text scale without overflow', (tester) async {
    await pumpCard(
      tester,
      locale: const Locale('ar'),
      received: 99999999,
      spent: 12345678,
      remaining: 87654321,
      textScaler: TextScaler.linear(1.2),
    );
    expectTrailingInOutColumn(tester, locale: const Locale('ar'), name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('English narrow 320 keeps layout', (tester) async {
    await pumpCard(
      tester,
      locale: const Locale('en'),
      received: 88888888,
      spent: 77777777,
      remaining: 11111111,
      textScaler: TextScaler.linear(1.2),
      surface: const Size(320, 220),
    );
    expectTrailingInOutColumn(tester, locale: const Locale('en'), name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('negative remaining keeps minus under name', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), received: 10000, spent: 50000, remaining: -40000);
    expect(find.textContaining('−'), findsWidgets);
    final amounts = find.byType(AppAmount);
    expect(amounts, findsNWidgets(3));
  });

  testWidgets('supplier meta mode keeps amount in trailing not in/out column', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: HomePersonCard(
              name: 'Supplier X',
              meta: 'Total spend',
              amountPiastres: 120000,
              amountRole: AppAmountRole.spend,
              accentKey: 'blue',
              localeCode: 'en',
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShellNavIcon), findsNothing);
    expect(find.text('Total spend'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.byType(AppAmount), findsOneWidget);
  });
}
