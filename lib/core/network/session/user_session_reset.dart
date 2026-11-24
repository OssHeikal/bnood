import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/features/clients/presentation/providers/clients_list_providers.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

import 'package:bnood/features/providers/data/agreements_riverpod.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/home/data/home_repository.dart';
import 'package:bnood/features/home/data/home_riverpod.dart';
import 'package:bnood/features/home/data/home_section_counts.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import 'package:bnood/features/providers/data/providers_riverpod.dart';
import '../../shared/pagination/paging_refresh.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import 'package:bnood/features/clients/presentation/providers/client_craftsmen_list_provider.dart';
import 'package:bnood/features/clients/presentation/providers/client_detail_provider.dart';
import 'package:bnood/features/clients/presentation/providers/client_identity_provider.dart';
import 'package:bnood/features/clients/presentation/providers/client_items_stats_provider.dart';
import 'package:bnood/features/projects/data/projects_repository.dart';
import 'package:bnood/features/projects/presentation/providers/project_detail_provider.dart';
import 'package:bnood/features/projects/presentation/providers/projects_list_paging.dart';
import 'package:bnood/features/projects/presentation/providers/projects_list_providers.dart';
import 'package:bnood/features/providers/presentation/providers/client_suppliers_list_provider.dart';
import 'package:bnood/features/providers/presentation/providers/provider_detail_provider.dart';

/// Clears in-memory HTTP caches and Riverpod user data when the signed-in identity changes.
void resetUserScopedState(Ref ref) {
  _resetUserScopedState(
    invalidate: ref.invalidate,
    readHomeRepository: () => ref.read(homeRepositoryProvider),
  );
}

/// Test/container entry point (same behavior as [resetUserScopedState]).
void resetUserScopedStateFromContainer(ProviderContainer container) {
  _resetUserScopedState(
    invalidate: container.invalidate,
    readHomeRepository: () => container.read(homeRepositoryProvider),
  );
}

void _resetUserScopedState({
  required void Function(ProviderOrFamily provider) invalidate,
  required HomeRepository Function() readHomeRepository,
}) {
  try {
    readHomeRepository().invalidateDashboard();
  } catch (_) {
    // Repository may already be disposed during teardown.
  }

  invalidate(homeRepositoryProvider);
  invalidate(homeTotalsProvider);
  invalidate(homeClientBalancesProvider);
  invalidate(homeActiveProjectsProvider);
  invalidate(homeSupplierSpendsProvider);
  invalidate(homeCraftsmenProvider);
  invalidate(homeSuppliersProvider);
  invalidate(homeSectionCountsProvider);
  invalidate(clientsListProvider);

  invalidate(subscriptionProvider);

  invalidate(itemsCatalogByIdProvider);
  invalidate(itemIconsCatalogProvider);

  invalidate(clientDetailProvider);
  invalidate(clientIdentityProvider);
  invalidate(clientCraftsmenListProvider);
  invalidate(clientSuppliersListProvider);
  invalidate(clientItemsStatsProvider);

  invalidate(providerDetailProvider);
  invalidate(projectDetailProvider);

  invalidate(projectsListPageFetcherProvider);
  invalidate(projectsListSearchQueryProvider);
  invalidate(projectsListFilterProvider);
  invalidate(projectsRepositoryProvider);

  invalidate(appProvidersRepositoryProvider);
  invalidate(clientsRepositoryProvider);
  invalidate(appAgreementsRepositoryProvider);

  invalidate(pagingListRefreshEpochProvider);
}
