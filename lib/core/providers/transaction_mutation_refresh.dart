import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clients/client_detail_provider.dart';
import '../../features/clients/client_items_stats_provider.dart';
import '../../features/suppliers/craftsman_detail_provider.dart';
import '../../features/suppliers/directory_providers.dart';
import '../../features/suppliers/supplier_detail_provider.dart';
import 'dashboard_providers.dart';

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
  if (supplierId != null) {
    ref.read(supplierDetailProvider(supplierId).notifier).refreshSilently();
  }
  if (craftsmanId != null) {
    ref.read(craftsmanDetailProvider(craftsmanId).notifier).refreshSilently();
  }
  ref.invalidate(directorySuppliersProvider);
  ref.invalidate(directoryCraftsmenProvider);
}
