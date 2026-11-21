import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/providers/presentation/models/provider_detail_snapshot.dart';

ClientDetailMovementLine providerVoucherMovementLine(
  ProviderDetailVoucherRow row,
) {
  final voucher = row.voucher;
  return ClientDetailMovementLine(
    transaction: voucher.toLedgerTransaction(
      projectId: voucher.projectId ?? '',
    ),
    itemName: voucher.itemName,
    usesRemoteMinorUnits: true,
  );
}
