import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/features/home/data/home_dashboard_mapping.dart';
import 'package:bnood/features/home/data/home_riverpod.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/data/home_section_counts.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/features/projects/data/projects_repository.dart';
import '../../../../core/app_state/silent_async_notifier.dart';
import '../../../../core/shared/pagination/paging_refresh.dart';

final homeTotalsProvider =
    AsyncNotifierProvider<HomeTotalsNotifier, HomeTotals>(
      HomeTotalsNotifier.new,
    );

final homeClientBalancesProvider =
    AsyncNotifierProvider<
      HomeClientBalancesNotifier,
      List<HomeClientBalanceRow>
    >(HomeClientBalancesNotifier.new);

final homeActiveProjectsProvider =
    AsyncNotifierProvider<HomeActiveProjectsNotifier, List<ProjectListRow>>(
      HomeActiveProjectsNotifier.new,
    );

final homeSupplierSpendsProvider =
    AsyncNotifierProvider<
      HomeSupplierSpendsNotifier,
      List<HomeSupplierSpendRow>
    >(HomeSupplierSpendsNotifier.new);

final homeCraftsmenProvider =
    AsyncNotifierProvider<
      HomeCraftsmenNotifier,
      List<HomeCraftsmanActivityRow>
    >(HomeCraftsmenNotifier.new);

final homeSuppliersProvider =
    AsyncNotifierProvider<
      HomeSuppliersNotifier,
      List<HomeCraftsmanActivityRow>
    >(HomeSuppliersNotifier.new);

Future<void> refreshHomeDashboard(WidgetRef ref) {
  ref.read(homeRepositoryProvider).invalidateDashboard();
  final pending = Future.wait([
    ref.read(homeTotalsProvider.notifier).refreshSilently(),
    ref.read(homeClientBalancesProvider.notifier).refreshSilently(),
    ref.read(homeActiveProjectsProvider.notifier).refreshSilently(),
    ref.read(homeSupplierSpendsProvider.notifier).refreshSilently(),
    ref.read(homeCraftsmenProvider.notifier).refreshSilently(),
    ref.read(homeSuppliersProvider.notifier).refreshSilently(),
  ]);
  bumpPagingListRefresh(ref, PagingListIds.clients);
  bumpPagingListRefresh(ref, PagingListIds.projects);
  return pending;
}

class HomeTotalsNotifier extends SilentAsyncNotifier<HomeTotals> {
  @override
  Future<HomeTotals> fetch() async {
    final remote = await ref.read(homeRepositoryProvider).getHomeTotals();
    return HomeTotals(
      receivedPiastres: remote.receivedMinor,
      spentPiastres: remote.spentMinor,
      remainingPiastresOverride: remote.remainingMinor,
    );
  }
}

class HomeClientBalancesNotifier
    extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    return dashboard.clients.map(homeClientBalanceRowFromPreview).toList();
  }
}

class HomeActiveProjectsNotifier extends SilentAsyncNotifier<List<ProjectListRow>> {
  static const _previewLimit = 8;

  @override
  Future<List<ProjectListRow>> fetch() async {
    final repo = ref.read(projectsRepositoryProvider);
    final result = await repo.listProjects(
      status: ClientListArchiveFilter.active,
      page: 1,
      perPage: 50,
      sort: 'updated_at',
      order: 'desc',
    );
    final items = result.items.take(_previewLimit).toList();
    ref.read(homeSectionCountsProvider.notifier).state =
        ref.read(homeSectionCountsProvider).copyWith(projectsCount: result.total);
    return items;
  }
}

class HomeSupplierSpendsNotifier
    extends SilentAsyncNotifier<List<HomeSupplierSpendRow>> {
  @override
  Future<List<HomeSupplierSpendRow>> fetch() async => const [];
}

class HomeCraftsmenNotifier
    extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    ref.read(homeSectionCountsProvider.notifier).state = HomeSectionCounts(
      clientsCount: dashboard.clientsCount ?? dashboard.clients.length,
      craftsmenCount: dashboard.craftsmenCount ?? dashboard.craftsmen.length,
      suppliersCount: dashboard.suppliersCount ?? dashboard.suppliers.length,
    );
    return dashboard.craftsmen.map(homeCraftsmanRowFromPreview).toList();
  }
}

class HomeSuppliersNotifier
    extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    return dashboard.suppliers.map(homeCraftsmanRowFromPreview).toList();
  }
}
