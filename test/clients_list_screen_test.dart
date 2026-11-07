import 'dart:async';

import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_shape.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/clients_list_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  testWidgets('Clients list shows skeleton on first load', (tester) async {
    final gate = Completer<List<HomeClientBalanceRow>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsListBalancesProvider.overrideWith(
            () => _PendingClientsNotifier(gate.future),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ClientsListScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsWidgets);
  });

  testWidgets('Clients list renders balance cards EN', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsListBalancesOverride([
            HomeClientBalanceRow(
              client: Client(
                id: 'c1',
                workspaceId: 'w',
                name: 'Tower A',
                phone: '010',
                createdAt: now,
                updatedAt: now,
              ),
              remainingPiastres: 120000,
              receivedPiastres: 200000,
              spentPiastres: 80000,
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

    expect(find.text('Tower A'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
  });

  testWidgets('silent refresh retains list content', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final notifier = SequencedClientsListBalancesNotifier([
      HomeClientBalanceRow(
        client: Client(
          id: 'c1',
          workspaceId: 'w',
          name: 'Alpha',
          createdAt: now,
          updatedAt: now,
        ),
        remainingPiastres: 100,
        receivedPiastres: 100,
        spentPiastres: 0,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsListBalancesProvider.overrideWith(() => notifier),
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
    expect(find.text('Alpha'), findsOneWidget);

    final refresh = notifier.refreshSilently();
    await tester.pump();
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.byType(Skeleton), findsNothing);
    await refresh;
    await tester.pumpAndSettle();
  });

  testWidgets('app bar add uses teal tint superellipse and opens sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clientsListBalancesOverride([])],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final material = tester.widget<Material>(find.byKey(const Key('clients_app_bar_add')));
    expect(material.color, AppColors.light.accentTeal.tint);
    expect(material.shape, AppShape.superellipse(radius: 8));
    expect(tester.getSize(find.byKey(const Key('clients_app_bar_add'))), const Size(48, 48));

    await tester.tap(find.byKey(const Key('clients_app_bar_add')));
    await tester.pumpAndSettle();
    expect(find.text('Add client'), findsWidgets);
  });
}

class _PendingClientsNotifier extends ClientsListBalancesNotifier {
  _PendingClientsNotifier(this._future);

  final Future<List<HomeClientBalanceRow>> _future;

  @override
  Future<List<HomeClientBalanceRow>> fetch() => _future;
}

class SequencedClientsListBalancesNotifier extends ClientsListBalancesNotifier {
  SequencedClientsListBalancesNotifier(this._rows);

  final List<HomeClientBalanceRow> _rows;

  @override
  Future<List<HomeClientBalanceRow>> fetch() async => _rows;
}
