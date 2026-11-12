import '../clients/client_detail_snapshot.dart';
import 'provider_detail_snapshot.dart';

ClientDetailMovementLine providerVoucherMovementLine(ProviderDetailVoucherRow row) {
  final voucher = row.voucher;
  return ClientDetailMovementLine(
    transaction: voucher.toLedgerTransaction(projectId: voucher.projectId ?? ''),
    itemName: voucher.itemName,
    usesRemoteMinorUnits: true,
  );
}
