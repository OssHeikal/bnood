import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../repositories/bnood_repository.dart';
import '../../features/clients/client_detail_provider.dart';
import '../../features/clients/client_items_stats_provider.dart';
import 'app_providers.dart';
import 'silent_async_notifier.dart';

final homeTotalsProvider = AsyncNotifierProvider<HomeTotalsNotifier, HomeTotals>(HomeTotalsNotifier.new);

final activeClientsProvider = FutureProvider((ref) {
  return ref.watch(repositoryProvider).watchActiveClients();
});

final homeClientBalancesProvider =
    AsyncNotifierProvider<HomeClientBalancesNotifier, List<HomeClientBalanceRow>>(
  HomeClientBalancesNotifier.new,
);

final clientsListFilterProvider =
    StateProvider<ClientListArchiveFilter>((ref) => ClientListArchiveFilter.active);

final clientsListBalancesProvider =
    AsyncNotifierProvider<ClientsListBalancesNotifier, List<HomeClientBalanceRow>>(
  ClientsListBalancesNotifier.new,
);

final homeSupplierSpendsProvider =
    AsyncNotifierProvider<HomeSupplierSpendsNotifier, List<HomeSupplierSpendRow>>(
  HomeSupplierSpendsNotifier.new,
);

void refreshHomeDashboard(WidgetRef ref) {
  ref.read(homeTotalsProvider.notifier).refreshSilently();
  ref.read(homeClientBalancesProvider.notifier).refreshSilently();
  ref.read(homeSupplierSpendsProvider.notifier).refreshSilently();
  ref.read(clientsListBalancesProvider.notifier).refreshSilently();
}

/// After client create/update/archive — keeps Home, Clients list, and optional detail in sync (silent).
void refreshAfterClientMutation(WidgetRef ref, {String? clientId, String? priorClientId}) {
  refreshHomeDashboard(ref);
  final ids = <String>{};
  if (clientId != null) ids.add(clientId);
  if (priorClientId != null) ids.add(priorClientId);
  for (final id in ids) {
    refreshClientDetail(ref, id);
    ref.read(clientItemsStatsProvider(id).notifier).refreshSilently();
  }
}

class HomeTotalsNotifier extends SilentAsyncNotifier<HomeTotals> {
  @override
  Future<HomeTotals> fetch() => ref.read(repositoryProvider).homeTotals();
}

Future<List<HomeClientBalanceRow>> homeClientBalanceRows(
  BnoodRepository repo,
  List<Client> clients, {
  required bool activeProjectsOnly,
}) async {
  final rows = <HomeClientBalanceRow>[];
  for (final client in clients) {
    final project = activeProjectsOnly
        ? await repo.primaryActiveProject(client.id)
        : await repo.primaryProjectForClient(client.id);
    if (project == null) {
      rows.add(
        HomeClientBalanceRow(
          client: client,
          remainingPiastres: 0,
          receivedPiastres: 0,
          spentPiastres: 0,
        ),
      );
      continue;
    }
    final balance = await repo.projectBalance(project.id);
    rows.add(
      HomeClientBalanceRow(
        client: client,
        remainingPiastres: balance.balancePiastres,
        receivedPiastres: balance.receivedPiastres,
        spentPiastres: balance.spentPiastres,
      ),
    );
  }
  return rows;
}

class HomeClientBalancesNotifier extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    final repo = ref.read(repositoryProvider);
    final clients = await repo.watchActiveClients();
    return homeClientBalanceRows(repo, clients, activeProjectsOnly: true);
  }
}

class ClientsListBalancesNotifier extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    final repo = ref.read(repositoryProvider);
    final filter = ref.read(clientsListFilterProvider);
    final clients = await repo.listClients(filter);
    return homeClientBalanceRows(repo, clients, activeProjectsOnly: false);
  }
}

class HomeSupplierSpendsNotifier extends SilentAsyncNotifier<List<HomeSupplierSpendRow>> {
  @override
  Future<List<HomeSupplierSpendRow>> fetch() =>
      ref.read(repositoryProvider).homeSupplierSpendsForActiveClients();
}
