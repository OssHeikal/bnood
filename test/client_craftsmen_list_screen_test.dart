import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/clients/client_craftsmen_list_provider.dart';
import 'package:bnood/features/clients/client_craftsmen_list_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('client craftsmen list shows zero paid assignment', (tester) async {
    final snap = ClientCraftsmenListSnapshot(
      projectId: 'p1',
      rows: [
        ClientCraftsmanPreviewRow(
          craftsmanId: 'cr1',
          name: 'Ahmed',
          trade: 'Plumbing',
          paidPiastres: 0,
          agreedPiastres: 1000_00,
          remainingPiastres: 1000_00,
          accentKey: 'teal',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [clientCraftsmenListProvider.overrideWith(() => _StubListNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientCraftsmenListScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.textContaining('0 EGP'), findsWidgets);
    expect(find.text('Remaining'), findsOneWidget);
  });

  testWidgets('client craftsmen empty state has assign CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientCraftsmenListProvider.overrideWith(
            () => _StubListNotifier(const ClientCraftsmenListSnapshot(projectId: 'p1', rows: [])),
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientCraftsmenListScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Assign craftsmen'), findsWidgets);
  });

  test('integration includes zero-paid linked agreements', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Idle');
    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id, initialAmountPiastres: 0);
    final agreements = await repo.agreementsForProject(project.id);
    final tx = await repo.transactionsForProject(project.id);
    final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: craftsman.id);
    expect(paid, 0);
    expect(agreements.single.initialAmountPiastres, 0);
  });
}

class _StubListNotifier extends ClientCraftsmenListNotifier {
  _StubListNotifier(this.value);
  final ClientCraftsmenListSnapshot value;
  @override
  Future<ClientCraftsmenListSnapshot> build(String arg) async => value;
}
