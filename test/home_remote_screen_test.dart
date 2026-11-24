import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/providers/presentation/widgets/remote_craftsman_summary_card.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'remote home shows client card layout and craftsman preview without suppliers',
    (tester) async {
      final now = DateTime.utc(2026, 11, 1);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeTotalsOverride(
              const HomeTotals(
                receivedPiastres: 3_000_000,
                spentPiastres: 1_000_000,
              ),
            ),
            homeActiveProjectsOverride(const [
              ProjectListRow(
                projectId: 'p1',
                projectName: 'Remote Tower',
                clientId: 'c1',
                clientName: 'Remote Client',
                receivedPiastres: 3_000_000,
                spentPiastres: 1_000_000,
                remainingPiastres: 2_000_000,
              ),
            ]),
            homeCraftsmenProvider.overrideWith(
              () => StubHomeCraftsmenNotifier([
                HomeCraftsmanActivityRow(
                  craftsman: CraftsmenData(
                    id: 'prov1',
                    workspaceId: 'remote',
                    name: 'Craftsman Ali',
                    phone: '',
                    createdAt: now,
                    updatedAt: now,
                  ),
                  paidPiastres: 500_000,
                  lastLaborAt: now,
                  remainingPiastres: 100_000,
                  clientsCount: 2,
                ),
              ]),
            ),
            emptyHomeSupplierSpendsOverride(),
            emptyHomeSuppliersOverride(),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remote Tower'), findsOneWidget);
      expect(find.text('Remote Client'), findsOneWidget);
      expect(find.byType(RemoteCraftsmanSummaryCard), findsOneWidget);
      expect(find.text('2 linked clients'), findsOneWidget);
      expect(find.text('Craftsman Ali'), findsOneWidget);
      expect(find.text('Suppliers'), findsNothing);
      expect(find.textContaining('See all'), findsNWidgets(2));
    },
  );
}
