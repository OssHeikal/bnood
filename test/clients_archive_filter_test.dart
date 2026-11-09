import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/features/clients/clients_list_paging.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('listClients filters by archivedAt not balance', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final active = await repo.createClient(name: 'Active One');
    final archived = await repo.createClient(name: 'Archived One');
    await repo.archiveClient(archived.id);

    final activeRows = await repo.listClients(ClientListArchiveFilter.active);
    final archivedRows = await repo.listClients(ClientListArchiveFilter.archived);
    final allRows = await repo.listClients(ClientListArchiveFilter.all);

    expect(activeRows.map((c) => c.id), contains(active.id));
    expect(activeRows.map((c) => c.id), isNot(contains(archived.id)));
    expect(archivedRows.map((c) => c.id), contains(archived.id));
    expect(allRows.length, 2);
  });

  test('unarchiveClient restores project and list filters', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Restore Me');
    await repo.archiveClient(client.id);

    expect((await repo.listClients(ClientListArchiveFilter.active)).length, 0);
    expect((await repo.listClients(ClientListArchiveFilter.archived)).length, 1);

    await repo.unarchiveClient(client.id);
    final restored = await repo.getClient(client.id);
    expect(restored.archivedAt, isNull);
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);
    expect(project!.status, 'active');

    expect((await repo.listClients(ClientListArchiveFilter.active)).length, 1);
    expect((await repo.listClients(ClientListArchiveFilter.archived)).length, 0);
  });

  test('clients list provider respects filter and silent home refresh', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final a = await repo.createClient(name: 'Alpha');
    final b = await repo.createClient(name: 'Beta');
    await repo.archiveClient(b.id);

    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    expect(container.read(clientsListFilterProvider), ClientListArchiveFilter.active);
    final fetch = container.read(clientsListPageFetcherProvider);
    var page = await fetch(page: 1, pageSize: 50);
    expect(page.items.length, 1);
    expect(page.items.first.client.id, a.id);

    container.read(clientsListFilterProvider.notifier).state = ClientListArchiveFilter.all;
    page = await fetch(page: 1, pageSize: 50);
    expect(page.items.length, 2);

    await repo.unarchiveClient(b.id);
    await container.read(homeClientBalancesProvider.notifier).refreshSilently();
    final homeRows = await container.read(homeClientBalancesProvider.future);
    expect(homeRows.length, 2);
  });
}
