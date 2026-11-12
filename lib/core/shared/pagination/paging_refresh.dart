import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stable id for a paginated list (e.g. `clients`, `suppliers`).
typedef PagingListId = String;

/// Bumped when an external mutation should refresh a list without filter/search changes.
final pagingListRefreshEpochProvider = StateProvider.family<int, PagingListId>((ref, id) => 0);

void bumpPagingListRefresh(WidgetRef ref, PagingListId id) {
  ref.read(pagingListRefreshEpochProvider(id).notifier).state++;
}

void bumpPagingListRefreshFromContainer(ProviderContainer container, PagingListId id) {
  container.read(pagingListRefreshEpochProvider(id).notifier).state++;
}

/// Well-known list ids — extend as new screens adopt shared pagination.
abstract final class PagingListIds {
  static const clients = 'clients';
  static const items = 'items';
  static const providers = 'providers';

  static String clientMovements(String clientId) => 'client-movements:$clientId';
}

void bindPagingListRefreshEpoch(WidgetRef ref, PagingListId id, VoidCallback refresh) {
  ref.listen(pagingListRefreshEpochProvider(id), (previous, next) {
    if (previous != next) refresh();
  });
}
