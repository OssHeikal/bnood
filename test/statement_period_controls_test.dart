import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart' show AppFoundationTheme;
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/features/statements/statement_period_controls.dart';
import 'package:bnood/features/statements/statement_period_logic.dart';
import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('statement period controls show presets and custom range', (tester) async {
    final initial = PeriodBounds(start: DateTime(2025, 6, 1), end: DateTime(2025, 6, 30));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
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
              onChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('تخصيص الفترة'), findsOneWidget);
    expect(find.text('من آخر تصدير'), findsOneWidget);
    expect(find.text('كل الفترة'), findsOneWidget);
  });
}
