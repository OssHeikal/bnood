import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/features/clients/clients_list_paging.dart';
import 'package:bnood/features/clients/clients_list_screen.dart';
import 'package:bnood/features/clients/widgets/clients_list_filter_chips.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap({required Locale locale, required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ClientsListScreen(),
      ),
    );
  }

  List<HomeClientBalanceRow> twoClients(DateTime now) => [
        HomeClientBalanceRow(
          client: Client(id: 'c-active', workspaceId: 'w', name: 'Active Client', createdAt: now, updatedAt: now),
          remainingPiastres: 100,
          receivedPiastres: 100,
          spentPiastres: 0,
        ),
        HomeClientBalanceRow(
          client: Client(
            id: 'c-arch',
            workspaceId: 'w',
            name: 'Archived Client',
            archivedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          remainingPiastres: 50,
          receivedPiastres: 50,
          spentPiastres: 0,
        ),
      ];

  testWidgets('default Active filter chip selected EN', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    await tester.pumpWidget(
      wrap(
        locale: const Locale('en'),
        overrides: [
          clientsListBalancesOverride([twoClients(now).first]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
    expect(find.text('Active Client'), findsOneWidget);
    expect(find.text('Archived Client'), findsNothing);
  });

  testWidgets('All filter shows both clients', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final rows = twoClients(now);
    await tester.pumpWidget(
      wrap(
        locale: const Locale('en'),
        overrides: [
          clientsListPageFetcherProvider.overrideWith(
            (ref) => ({required int page, required int pageSize}) async {
              if (page > 1) return const PagedFetchPage(items: [], hasMore: false);
              final filter = ref.read(clientsListFilterProvider);
              final list = switch (filter) {
                ClientListArchiveFilter.active => [rows.first],
                ClientListArchiveFilter.archived => [rows.last],
                ClientListArchiveFilter.all => rows,
              };
              return PagedFetchPage(items: list, hasMore: false);
            },
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clients_filter_all')));
    await tester.pumpAndSettle();

    expect(find.text('Active Client'), findsOneWidget);
    expect(find.text('Archived Client'), findsOneWidget);
  });

  testWidgets('AR chip labels at narrow width', (tester) async {
    tester.view.physicalSize = const Size(440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(locale: const Locale('ar'), overrides: [clientsListBalancesOverride([])]));
    await tester.pumpAndSettle();

    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('نشط'), findsOneWidget);
    expect(find.text('مؤرشف'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter chips hug their labels', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.utc(2026, 11, 1);
    await tester.pumpWidget(
      wrap(
        locale: const Locale('en'),
        overrides: [clientsListBalancesOverride([twoClients(now).first])],
      ),
    );
    await tester.pumpAndSettle();

    final all = tester.getSize(find.byKey(const Key('clients_filter_all')));
    final active = tester.getSize(find.byKey(const Key('clients_filter_active')));
    final archived = tester.getSize(find.byKey(const Key('clients_filter_archived')));
    final row = tester.getSize(find.byType(ClientsListFilterChips));

    expect(all.width, lessThan(archived.width));
    expect(all.width + active.width + archived.width, lessThan(row.width));
  });
}
