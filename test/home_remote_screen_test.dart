import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/ledger/ledger_entities.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/home/home_row_models.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/features/providers/widgets/remote_craftsman_summary_card.dart';
import 'package:bnood/features/home/widgets/home_person_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('remote home shows client card layout and craftsman preview without suppliers', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsOverride(const HomeTotals(receivedPiastres: 3_000_000, spentPiastres: 1_000_000)),
          homeClientBalancesOverride([
            HomeClientBalanceRow(
              client: Client(
                id: 'c1',
                workspaceId: 'remote',
                name: 'Remote Client',
                phone: '',
                createdAt: now,
                updatedAt: now,
              ),
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

    expect(find.byType(HomePersonCard), findsOneWidget);
    expect(find.text('Remote Client'), findsOneWidget);
    expect(find.byType(RemoteCraftsmanSummaryCard), findsOneWidget);
    expect(find.text('2 linked clients'), findsOneWidget);
    expect(find.text('Craftsman Ali'), findsOneWidget);
    expect(find.text('Suppliers'), findsNothing);
    expect(find.textContaining('See all'), findsNWidgets(2));
  });
}
