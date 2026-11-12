import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/clients_providers.dart';
import '../../core/items/items_providers.dart';
import '../../core/providers_api/providers_riverpod.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import 'voucher_draft.dart';

Future<VoucherDraft> enrichVoucherDraftRemote(ProviderContainer container, VoucherDraft draft) async {
  var next = draft;

  if (next.clientLabel == null && next.clientId != null) {
    final client = await container.read(clientsRepositoryProvider).getClient(next.clientId!);
    next = next.copyWith(
      clientLabel: client.client.name,
      projectId: client.project.id,
    );
  }

  if (next.editingTransactionId != null) {
    final voucher = await container.read(vouchersRepositoryProvider).getVoucher(next.editingTransactionId!);
    final hasLinkedProvider = voucher.isSpend &&
        (voucher.supplierId != null || voucher.craftsmanId != null);
    next = next.copyWith(
      clientLabel: voucher.clientName ?? next.clientLabel,
      itemLabel: voucher.itemName ?? next.itemLabel,
      supplierLabel:
          voucher.expenseClassification == 'materials' ? voucher.providerName ?? next.supplierLabel : next.supplierLabel,
      craftsmanLabel:
          voucher.expenseClassification == 'labor' ? voucher.providerName ?? next.craftsmanLabel : next.craftsmanLabel,
      providerLinkedToClient: hasLinkedProvider ? true : next.providerLinkedToClient,
    );
  }

  if (next.itemLabel == null && next.itemId != null) {
    try {
      final item = await container.read(itemsRepositoryProvider).getItem(next.itemId!);
      next = next.copyWith(itemLabel: item.name);
    } catch (_) {}
  }

  if (next.supplierLabel == null && next.supplierId != null) {
    try {
      final provider = await container.read(appProvidersRepositoryProvider).getProvider(next.supplierId!);
      next = next.copyWith(supplierLabel: provider.name);
    } catch (_) {}
  }

  if (next.craftsmanLabel == null && next.craftsmanId != null) {
    try {
      final provider = await container.read(appProvidersRepositoryProvider).getProvider(next.craftsmanId!);
      next = next.copyWith(craftsmanLabel: provider.name);
    } catch (_) {}
  }

  return next;
}
