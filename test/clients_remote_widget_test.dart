import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/app_pressable.dart';
import 'package:bnood/features/clients/client_detail_provider.dart';
import 'package:bnood/features/clients/client_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/clients/clients_list_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  testWidgets('null balances show em dash on list', (tester) async {
    final now = DateTime.utc(2026, 11, 9);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWithValue(true),
          clientsListBalancesOverride([
            HomeClientBalanceRow(
              client: Client(
                id: 'c1',
                workspaceId: 'remote',
                name: 'Remote Client',
                createdAt: now,
                updatedAt: now,
              ),
              remainingPiastres: null,
              receivedPiastres: null,
              spentPiastres: null,
            ),
          ]),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ClientsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Remote Client'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('EGP'), findsNothing);
  });

  testWidgets('archived client detail disables edit affordance', (tester) async {
    final now = DateTime.utc(2026, 11, 9);
    final snapshot = ClientDetailSnapshot(
      client: Client(
        id: 'c-arch',
        workspaceId: 'remote',
        name: 'Archived',
        archivedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
      project: Project(
        id: 'p1',
        workspaceId: 'remote',
        clientId: 'c-arch',
        name: 'Archived',
        status: 'archived',
        createdAt: now,
        updatedAt: now,
      ),
      receivedPiastres: null,
      spentPiastres: null,
      estimatedProfitPiastres: null,
      craftsmanPreviews: const [],
      topItems: const [],
      latestMovements: const [],
      onlineIdentityOnly: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteClientsEnabledProvider.overrideWithValue(true),
          clientDetailProvider.overrideWith(() => _StaticDetailNotifier(snapshot)),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ClientDetailScreen(clientId: 'c-arch'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pressable = tester.widget<AppPressable>(
      find.ancestor(of: find.byKey(const Key('client_detail_edit')), matching: find.byType(AppPressable)),
    );
    expect(pressable.enabled, isFalse);
    expect(find.text('Archived'), findsWidgets);
  });
}

class _StaticDetailNotifier extends ClientDetailNotifier {
  _StaticDetailNotifier(this.snapshot);

  final ClientDetailSnapshot snapshot;

  @override
  Future<ClientDetailSnapshot> build(String arg) async => snapshot;
}
