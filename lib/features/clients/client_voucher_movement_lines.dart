import '../../core/vouchers/app_voucher_record.dart';
import 'client_detail_snapshot.dart';

List<ClientDetailMovementLine> movementLinesFromVouchers(
  List<AppVoucher> vouchers, {
  required String projectId,
}) {
  return vouchers
      .map(
        (v) => ClientDetailMovementLine(
          transaction: v.toLedgerTransaction(projectId: v.projectId ?? projectId),
          itemName: v.itemName,
          payeeName: v.providerName,
          payeeIsSupplier: v.expenseClassification == 'materials',
          usesRemoteMinorUnits: true,
        ),
      )
      .toList();
}
