import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/presentation/providers/client_detail_provider.dart';
import 'package:bnood/features/clients/presentation/providers/client_items_stats_provider.dart';
import 'package:bnood/features/providers/presentation/providers/provider_detail_provider.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

/// Silent refresh after voucher edit/delete (no pull-to-refresh).
void refreshAfterTransactionMutation(
  WidgetRef ref, {
  String? clientId,
  String? supplierId,
  String? craftsmanId,
}) {
  refreshHomeDashboard(ref);
  ref.read(homeCraftsmenProvider.notifier).refreshSilently();
  if (clientId != null) {
    refreshClientDetail(ref, clientId);
    ref.read(clientItemsStatsProvider(clientId).notifier).refreshSilently();
  }
  final providerId = supplierId ?? craftsmanId;
  if (providerId != null) {
    ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
  }
}
