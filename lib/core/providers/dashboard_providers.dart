import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bnood_repository.dart';
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

final homeSupplierSpendsProvider =
    AsyncNotifierProvider<HomeSupplierSpendsNotifier, List<HomeSupplierSpendRow>>(
  HomeSupplierSpendsNotifier.new,
);

void refreshHomeDashboard(WidgetRef ref) {
  ref.read(homeTotalsProvider.notifier).refreshSilently();
  ref.read(homeClientBalancesProvider.notifier).refreshSilently();
  ref.read(homeSupplierSpendsProvider.notifier).refreshSilently();
}

class HomeTotalsNotifier extends SilentAsyncNotifier<HomeTotals> {
  @override
  Future<HomeTotals> fetch() => ref.read(repositoryProvider).homeTotals();
}

class HomeClientBalancesNotifier extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    final repo = ref.read(repositoryProvider);
    final clients = await repo.watchActiveClients();
    final rows = <HomeClientBalanceRow>[];
    for (final client in clients) {
      final project = await repo.primaryActiveProject(client.id);
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
}

class HomeSupplierSpendsNotifier extends SilentAsyncNotifier<List<HomeSupplierSpendRow>> {
  @override
  Future<List<HomeSupplierSpendRow>> fetch() =>
      ref.read(repositoryProvider).homeSupplierSpendsForActiveClients();
}
