import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/clients_providers.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import 'client_detail_snapshot.dart';
import 'client_voucher_movement_lines.dart';

const clientMovementsPageSize = 20;

class ClientMovementsQuery {
  const ClientMovementsQuery({required this.clientId, this.itemId});

  final String clientId;
  final String? itemId;

  @override
  bool operator ==(Object other) {
    return other is ClientMovementsQuery && other.clientId == clientId && other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(clientId, itemId);
}

final clientMovementsPageFetcherProvider =
    Provider.family<PagedFetchCallback<ClientDetailMovementLine>, ClientMovementsQuery>((ref, query) {
  return ({required int page, required int pageSize}) async {
    final vouchers = await ref.read(vouchersRepositoryProvider).listClientVouchers(
          clientId: query.clientId,
          itemId: query.itemId,
          page: page,
          perPage: pageSize,
        );
    final record = await ref.read(clientsRepositoryProvider).getClient(query.clientId);
    final lines = movementLinesFromVouchers(vouchers.items, projectId: record.project.id);
    return PagedFetchPage(items: lines, hasMore: vouchers.hasMore);
  };
});
