import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/clients_providers.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import 'client_detail_snapshot.dart';
import 'client_movements_filters.dart';
import 'client_voucher_movement_lines.dart';

const clientMovementsPageSize = 20;

class ClientMovementsQuery {
  const ClientMovementsQuery({
    required this.clientId,
    required this.filters,
  });

  final String clientId;
  final ClientMovementsFilters filters;

  @override
  bool operator ==(Object other) {
    return other is ClientMovementsQuery &&
        other.clientId == clientId &&
        other.filters.searchQuery == filters.searchQuery &&
        other.filters.itemId == filters.itemId &&
        other.filters.sort == filters.sort &&
        other.filters.from == filters.from &&
        other.filters.to == filters.to;
  }

  @override
  int get hashCode => Object.hash(
        clientId,
        filters.searchQuery,
        filters.itemId,
        filters.sort,
        filters.from,
        filters.to,
      );
}

final clientMovementsPageFetcherProvider =
    Provider.family<PagedFetchCallback<ClientDetailMovementLine>, ClientMovementsQuery>((ref, query) {
  return ({required int page, required int pageSize}) async {
    final f = query.filters;
    final vouchers = await ref.read(vouchersRepositoryProvider).listClientVouchers(
          clientId: query.clientId,
          q: f.searchQuery.trim().isEmpty ? null : f.searchQuery.trim(),
          itemId: f.itemId,
          from: ClientMovementsFilters.formatApiDate(f.from),
          to: ClientMovementsFilters.formatApiDate(f.to),
          sort: f.sort.apiValue,
          page: page,
          perPage: pageSize,
        );
    final record = await ref.read(clientsRepositoryProvider).getClient(query.clientId);
    final lines = movementLinesFromVouchers(vouchers.items, projectId: record.project.id);
    return PagedFetchPage(items: lines, hasMore: vouchers.hasMore);
  };
});
