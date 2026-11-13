import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart' show AppFoundationTheme;
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_period_controls.dart';
import 'package:bnood/features/statements/statement_period_logic.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('statement custom from-date opens app date sheet and commits', (tester) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  PeriodBounds? changedBounds;
  StatementPeriodPreset? changedPreset;
  final initial = PeriodBounds(start: DateTime(2025, 6, 1), end: DateTime(2025, 6, 30));

  await tester.pumpWidget(
    MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeFoundationScope(
        child: Scaffold(
          backgroundColor: AppColors.light.canvas,
          body: StatementPeriodControls(
            bounds: initial,
            preset: StatementPeriodPreset.custom,
            sinceLastExportAvailable: false,
            lastExport: null,
            onChanged: (bounds, preset) {
              changedBounds = bounds;
              changedPreset = preset;
            },
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('From'));
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey('voucher-date-confirm')), findsOneWidget);
  expect(find.text('OK'), findsNothing);

  await tester.tap(find.byKey(const ValueKey('voucher-day-2025-6-15')));
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('voucher-date-confirm')));
  await tester.pumpAndSettle();

  expect(changedPreset, StatementPeriodPreset.custom);
  expect(changedBounds?.start, DateTime(2025, 6, 15));
  expect(changedBounds?.end, DateTime(2025, 6, 30));
  });
}
