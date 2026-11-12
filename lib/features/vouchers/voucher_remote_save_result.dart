import '../../core/vouchers/app_voucher_record.dart';
import 'voucher_sheet_receipt.dart';

class RemoteVoucherSaveResult {
  const RemoteVoucherSaveResult({
    required this.voucherSaved,
    this.voucher,
    this.receipts = const [],
    this.failedReceiptUploads = 0,
    this.failedReceiptDeletes = 0,
    this.failedDeleteReceiptIds = const [],
    this.deletedReceiptIds = const [],
    this.lastReceiptError,
  });

  final bool voucherSaved;
  final AppVoucher? voucher;
  final List<VoucherSheetReceipt> receipts;
  final int failedReceiptUploads;
  final int failedReceiptDeletes;
  final List<String> failedDeleteReceiptIds;
  final List<String> deletedReceiptIds;
  final Object? lastReceiptError;

  bool get canCloseSheet =>
      voucherSaved && failedReceiptUploads == 0 && failedReceiptDeletes == 0;
}
