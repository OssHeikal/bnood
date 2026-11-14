import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_export_store.dart';
import 'package:bnood/features/statements/statement_period_controls.dart';
import 'package:bnood/features/statements/statement_period_logic.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('remote client statement enables chip after export cursor is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = StatementExportStore(prefs);
    const clientId = '01JCEXAMPLECLIENT0000000000';
    const ws = 'workspace-test';

    expect(store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: clientId), isNull);

    final periodEnd = StatementPeriodLogic.cairoTodayDate().subtract(const Duration(days: 2));
    await store.recordSuccessfulExport(
      workspaceId: ws,
      kind: StatementEntityKind.client,
      entityId: clientId,
      exportedAt: DateTime.now(),
      periodEndInclusive: periodEnd,
    );

    final record = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: clientId);
    expect(record, isNotNull);
    expect(StatementPeriodLogic.sinceLastExportBounds(record), isNotNull);
  });

  testWidgets('period chip is tappable when export cursor exists', (tester) async {
    final record = StatementExportRecord(
      exportedAt: DateTime(2025, 3, 2, 14),
      periodEndInclusive: DateTime(2025, 3, 1),
    );
    final bounds = StatementPeriodLogic.sinceLastExportBounds(record)!;
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: StatementPeriodControls(
              bounds: bounds,
              preset: StatementPeriodPreset.all,
              lastExport: record,
              sinceLastExportAvailable: true,
              onChanged: (_, preset) {
                if (preset == StatementPeriodPreset.sinceLastExport) tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Since last export'),
    );
    expect(chip.onSelected, isNotNull);

    await tester.tap(find.text('Since last export'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
