import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../agreements/agreements_riverpod.dart';
import '../clients/clients_providers.dart';
import '../home/home_repository.dart';
import '../home/home_riverpod.dart';
import '../home/home_section_counts.dart';
import '../items/items_providers.dart';
import '../providers/dashboard_providers.dart';
import '../providers_api/providers_riverpod.dart';
import '../shared/pagination/paging_refresh.dart';
import '../subscription/subscription_riverpod.dart';
import '../../features/clients/client_craftsmen_list_provider.dart';
import '../../features/clients/client_detail_provider.dart';
import '../../features/clients/client_items_stats_provider.dart';
import '../../features/clients/client_suppliers_list_provider.dart';
import '../../features/suppliers/craftsman_detail_provider.dart';
import '../../features/suppliers/directory_providers.dart';
import '../../features/suppliers/supplier_detail_provider.dart';
import '../../features/providers/provider_detail_provider.dart';

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
  invalidate(activeClientsProvider);

  invalidate(subscriptionProvider);

  invalidate(itemsCatalogByIdProvider);
  invalidate(itemIconsCatalogProvider);

  invalidate(directorySuppliersProvider);
  invalidate(directoryCraftsmenProvider);

  invalidate(clientDetailProvider);
  invalidate(clientCraftsmenListProvider);
  invalidate(clientSuppliersListProvider);
  invalidate(clientItemsStatsProvider);

  invalidate(providerDetailProvider);
  invalidate(supplierDetailProvider);
  invalidate(craftsmanDetailProvider);

  invalidate(appProvidersRepositoryProvider);
  invalidate(clientsRepositoryProvider);
  invalidate(appAgreementsRepositoryProvider);

  invalidate(pagingListRefreshEpochProvider);
}
