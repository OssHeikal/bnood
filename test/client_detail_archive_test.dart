import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/features/clients/presentation/providers/client_identity_provider.dart';
import 'package:bnood/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:bnood/features/clients/presentation/models/client_identity_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ClientIdentitySnapshot snap({required bool archived}) {
    final now = DateTime.utc(2026, 11, 1);
    return ClientIdentitySnapshot(
      client: Client(
        id: 'c1',
        workspaceId: 'w',
        name: 'Archived Tower',
        phone: '01012345678',
        archivedAt: archived ? now : null,
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: 100000,
      spentPiastres: 0,
      remainingPiastres: 100000,
      projects: const [
        ClientProjectPreviewRow(projectId: 'p1', projectName: 'Project'),
      ],
    );
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    ClientIdentitySnapshot snapshot,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientIdentityProvider.overrideWith(() => _Stub(snapshot)),
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

  testWidgets('archived client detail disables edit', (tester) async {
    await pumpDetail(tester, snap(archived: true));

    await tester.tap(find.byKey(const Key('client_detail_overflow')));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Archived Tower'), findsWidgets);
  });
}

class _Stub extends ClientIdentityNotifier {
  _Stub(this.snapshot);

  final ClientIdentitySnapshot snapshot;

  @override
  Future<ClientIdentitySnapshot> build(String arg) async => snapshot;
}