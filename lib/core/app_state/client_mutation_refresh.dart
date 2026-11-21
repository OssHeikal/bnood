import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clients/presentation/client_craftsmen_list_provider.dart';
import '../../features/clients/presentation/client_detail_provider.dart';
import '../../features/clients/presentation/client_items_stats_provider.dart';
import '../../features/home/data/home_riverpod.dart';
import '../../features/home/presentation/providers/home_dashboard_providers.dart';
import '../../features/providers/presentation/client_suppliers_list_provider.dart';
import '../../features/providers/presentation/provider_detail_provider.dart';
import '../../features/subscription/data/subscription_riverpod.dart';
import '../shared/pagination/paging_refresh.dart';

void refreshAfterProviderClientAssignments(
  WidgetRef ref, {
  required String providerId,
  required Iterable<String> affectedClientIds,
}) {
  ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
  for (final clientId in affectedClientIds.toSet()) {
    refreshAfterClientMutation(ref, clientId: clientId);
    ref.invalidate(clientCraftsmenListProvider(clientId));
    ref.invalidate(clientSuppliersListProvider(clientId));
  }
}

void refreshAfterClientMutation(WidgetRef ref, {String? clientId, String? priorClientId}) {
  ref.read(homeRepositoryProvider).invalidateDashboard();
  bumpPagingListRefresh(ref, PagingListIds.clients);
  ref.read(homeTotalsProvider.notifier).refreshSilently();
  ref.read(homeClientBalancesProvider.notifier).refreshSilently();
  ref.read(homeCraftsmenProvider.notifier).refreshSilently();
  ref.read(subscriptionProvider.notifier).refreshSilently();
  final ids = <String>{};
  if (clientId != null) ids.add(clientId);
  if (priorClientId != null) ids.add(priorClientId);
  for (final id in ids) {
    refreshClientDetail(ref, id);
    ref.read(clientItemsStatsProvider(id).notifier).refreshSilently();
  }
}