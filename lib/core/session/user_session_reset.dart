import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/providers/data/agreements_riverpod.dart';
import '../../features/clients/data/clients_providers.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/home/data/home_riverpod.dart';
import '../../features/home/data/home_section_counts.dart';
import '../../features/items/data/items_providers.dart';
import 'package:bnood/core/app_state/dashboard_providers.dart';
import '../../features/providers/data/providers_riverpod.dart';
import '../shared/pagination/paging_refresh.dart';
import '../../features/subscription/data/subscription_riverpod.dart';
import '../../features/clients/presentation/client_craftsmen_list_provider.dart';
import '../../features/clients/presentation/client_detail_provider.dart';
import '../../features/clients/presentation/client_items_stats_provider.dart';
import '../../features/clients/presentation/client_suppliers_list_provider.dart';
import '../../features/providers/presentation/provider_detail_provider.dart';

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
  invalidate(homeSupplierSpendsProvider);
  invalidate(homeCraftsmenProvider);
  invalidate(homeSuppliersProvider);
  invalidate(homeSectionCountsProvider);
  invalidate(clientsListProvider);

  invalidate(subscriptionProvider);

  invalidate(itemsCatalogByIdProvider);
  invalidate(itemIconsCatalogProvider);

  invalidate(clientDetailProvider);
  invalidate(clientCraftsmenListProvider);
  invalidate(clientSuppliersListProvider);
  invalidate(clientItemsStatsProvider);

  invalidate(providerDetailProvider);

  invalidate(appProvidersRepositoryProvider);
  invalidate(clientsRepositoryProvider);
  invalidate(appAgreementsRepositoryProvider);

  invalidate(pagingListRefreshEpochProvider);
}