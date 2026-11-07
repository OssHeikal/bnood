import 'dart:math' as math;

import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/core/config/theme/app_size.dart';
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
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 220));
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
                amountPiastres: received - spent,
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

  void expectCompactInOutRow(WidgetTester tester, {required String name}) {
    final icons = find.byType(ShellNavIcon);
    expect(icons, findsNWidgets(2));
    final firstIcon = tester.getRect(icons.at(0));
    final secondIcon = tester.getRect(icons.at(1));
    expect((firstIcon.center.dy - secondIcon.center.dy).abs(), lessThan(6));

    final amounts = find.descendant(of: find.byType(HomePersonCard), matching: find.byType(AppAmount));
    final receiveAmount = tester.getRect(amounts.at(0));
    final spendAmount = tester.getRect(amounts.at(1));

    final receivePairGap = math.min(
      (receiveAmount.left - firstIcon.right).abs(),
      (firstIcon.left - receiveAmount.right).abs(),
    );
    final spendPairGap = math.min(
      (spendAmount.left - secondIcon.right).abs(),
      (secondIcon.left - spendAmount.right).abs(),
    );
    expect(receivePairGap, lessThanOrEqualTo(AppSize.spaceXS + 4));
    expect(spendPairGap, lessThanOrEqualTo(AppSize.spaceXS + 4));

    final groupOneEnd = math.max(firstIcon.right, receiveAmount.right);
    final groupTwoStart = math.min(secondIcon.left, spendAmount.left);
    final groupOneStart = math.min(firstIcon.left, receiveAmount.left);
    final groupTwoEnd = math.max(secondIcon.right, spendAmount.right);
    final between = math.min(
      (groupTwoStart - groupOneEnd).abs(),
      (groupOneStart - groupTwoEnd).abs(),
    );
    expect(between, closeTo(AppSize.spaceSM, 20));

    final nameRect = tester.getRect(find.text(name));
    final subtitleStart = [firstIcon.left, receiveAmount.left, secondIcon.left, spendAmount.left].reduce(math.min);
    expect(subtitleStart, closeTo(nameRect.left, 6));
  }

  testWidgets('receive and spend share one horizontal subtitle row', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), received: 100000, spent: 25000);

    expect(find.byType(AppAmount), findsNWidgets(3));
    expect(find.textContaining(AppAmount.format(piastres: 100000, localeCode: 'en')), findsOneWidget);
    expect(find.textContaining(AppAmount.format(piastres: 25000, localeCode: 'en')), findsOneWidget);
    expectCompactInOutRow(tester, name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact in-out row for zero amounts', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), received: 0, spent: 0);
    expectCompactInOutRow(tester, name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic at 1.2 text scale keeps in-out row without overflow', (tester) async {
    await pumpCard(
      tester,
      locale: const Locale('ar'),
      received: 99999999,
      spent: 12345678,
      textScaler: TextScaler.linear(1.2),
    );
    expectCompactInOutRow(tester, name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });

  testWidgets('English narrow width keeps in-out row without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpCard(
      tester,
      locale: const Locale('en'),
      received: 88888888,
      spent: 77777777,
      textScaler: TextScaler.linear(1.2),
    );
    expectCompactInOutRow(tester, name: 'Osama Client');
    expect(tester.takeException(), isNull);
  });
}
