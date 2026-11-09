import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/clients/client_detail_provider.dart';
import 'package:bnood/features/clients/client_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ClientDetailSnapshot snap({required bool archived}) {
    final now = DateTime.utc(2026, 11, 1);
    return ClientDetailSnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'Archived Tower',
        phone: '01012345678',
        archivedAt: archived ? now : null,
        createdAt: now,
        updatedAt: now,
      ),
      project: Project(
        id: 'p1',
        workspaceId: 'w',
        clientId: 'c1',
        name: 'Project',
        status: archived ? 'archived' : 'active',
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: 100000,
      spentPiastres: 0,
      estimatedProfitPiastres: null,
      craftsmanPreviews: const [],
      topItems: const [],
      latestMovements: const [],
    );
  }

  Future<void> pumpDetail(WidgetTester tester, ClientDetailSnapshot snapshot) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientDetailProvider.overrideWith(() => _Stub(snapshot)),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientDetailScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('archived detail disables mutations', (tester) async {
    await pumpDetail(tester, snap(archived: true));

    expect(find.byKey(const Key('client_detail_action_archive')), findsNothing);

    await tester.tap(find.byKey(const Key('client_detail_action_receive')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.byKey(const Key('client_detail_edit')));
    await tester.pumpAndSettle();
    expect(find.text('Archived Tower'), findsWidgets);
  });

  testWidgets('archive confirm cancel leaves detail', (tester) async {
    await pumpDetail(tester, snap(archived: false));

    await tester.tap(find.byKey(const Key('client_detail_action_archive')));
    await tester.pumpAndSettle();
    expect(find.text('Archive client?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Archived Tower'), findsWidgets);
    expect(find.byKey(const Key('client_detail_action_receive')), findsOneWidget);
  });
}

class _Stub extends ClientDetailNotifier {
  _Stub(this.snapshot);

  final ClientDetailSnapshot snapshot;

  @override
  Future<ClientDetailSnapshot> build(String arg) async => snapshot;
}
