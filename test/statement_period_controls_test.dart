import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/features/statements/statement_period_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('statement period controls show selected local date range', (tester) async {
    final initial = PeriodBounds(
      start: DateTime(2025, 6, 1),
      end: DateTime(2025, 6, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatementPeriodControls(
            bounds: initial,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('من'), findsOneWidget);
    expect(find.text('إلى'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
