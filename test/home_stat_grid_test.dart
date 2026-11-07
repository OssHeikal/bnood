import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/home/widgets/home_stat_grid.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpGrid(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
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
              body: HomeStatGrid(
                localeCode: locale.languageCode,
                totals: const HomeTotals(receivedPiastres: 100000, spentPiastres: 0),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Arabic stat labels share card with amounts without layout error', (tester) async {
    await pumpGrid(tester, locale: const Locale('ar'));
    expect(find.text('وارد'), findsOneWidget);
    expect(find.text('صادر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English at 1.2 text scale lays out without overflow', (tester) async {
    await pumpGrid(
      tester,
      locale: const Locale('en'),
      textScaler: TextScaler.linear(1.2),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Received'), findsOneWidget);
  });
}
