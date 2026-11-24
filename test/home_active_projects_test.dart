import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  testWidgets('home shows active project rows with client subtitle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const rows = [
      ProjectListRow(
        projectId: 'p1',
        projectName: 'Tower A',
        clientId: 'c1',
        clientName: 'Nile Co',
        receivedPiastres: 100_000,
        spentPiastres: 40_000,
        remainingPiastres: 60_000,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsOverride(
            const HomeTotals(receivedPiastres: 100_000, spentPiastres: 40_000),
          ),
          homeActiveProjectsOverride(rows),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          emptyHomeSuppliersOverride(),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مشاريع نشطة'), findsOneWidget);
    expect(find.text('Tower A'), findsOneWidget);
    expect(find.text('Nile Co'), findsOneWidget);
    expect(find.text('عملاء نشطون'), findsNothing);
  });
}