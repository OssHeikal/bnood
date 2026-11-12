import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/vouchers/app_voucher_receipt.dart';
import '../../core/vouchers/vouchers_repository.dart';
import 'receipt_image_compress.dart';
import 'voucher_sheet_receipt.dart';

String _extensionForMime(String mime) {
  if (mime.contains('png')) return '.png';
  if (mime.contains('webp')) return '.webp';
  return '.jpg';
}

Future<String> writeReceiptBytesToCache({
  required String receiptId,
  required String mime,
  required List<int> bytes,
}) async {
  final dir = await getTemporaryDirectory();
  final folder = Directory(p.join(dir.path, 'voucher_receipts'));
  if (!await folder.exists()) await folder.create(recursive: true);
  final file = File(p.join(folder.path, '$receiptId${_extensionForMime(mime)}'));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<List<VoucherSheetReceipt>> downloadRemoteReceipts({
  required VouchersRepository repo,
  required List<AppVoucherReceipt> metadata,
}) async {
  final rows = <VoucherSheetReceipt>[];
  for (final receipt in metadata) {
    final bytes = await repo.downloadReceiptBytes(receipt.id);
    final path = await writeReceiptBytesToCache(
      receiptId: receipt.id,
      mime: receipt.mime,
      bytes: bytes,
    );
    rows.add(VoucherSheetReceipt(localPath: path, serverId: receipt.id));
  }
  return rows;
}

Future<AppVoucherReceipt> _uploadCompressedReceipt({
  required VouchersRepository repo,
  required String voucherId,
  required VoucherSheetReceipt row,
}) async {
  ReceiptPreparedUpload? prepared;
  try {
    prepared = await prepareReceiptImageForUpload(row.localPath);
    return await repo.uploadVoucherReceipt(
      voucherId: voucherId,
      filePath: prepared.path,
      filename: p.basename(prepared.path),
    );
  } finally {
    await prepared?.dispose();
  }
}

Future<List<VoucherSheetReceipt>> uploadPendingReceipts({
  required VouchersRepository repo,
  required String voucherId,
  required List<VoucherSheetReceipt> receipts,
}) async {
  final next = <VoucherSheetReceipt>[];
  for (final row in receipts) {
    if (!row.isPendingUpload) {
      next.add(row);
      continue;
    }
    try {
      final uploaded = await _uploadCompressedReceipt(
        repo: repo,
        voucherId: voucherId,
        row: row,
      );
      next.add(VoucherSheetReceipt(localPath: row.localPath, serverId: uploaded.id));
    } on AuthApiException {
      next.add(row);
      rethrow;
    } on ReceiptImageCompressionException {
      next.add(row);
      rethrow;
    }
  }
  return next;
}

/// Upload each pending receipt; failed rows stay pending. Does not rethrow.
Future<
    ({
      List<VoucherSheetReceipt> receipts,
      int failedCount,
      Object? lastError,
    })> uploadPendingReceiptsBestEffort({
  required VouchersRepository repo,
  required String voucherId,
  required List<VoucherSheetReceipt> receipts,
}) async {
  var failed = 0;
  Object? lastError;
  final next = <VoucherSheetReceipt>[];
  for (final row in receipts) {
    if (!row.isPendingUpload) {
      next.add(row);
      continue;
    }
    try {
      final uploaded = await _uploadCompressedReceipt(
        repo: repo,
        voucherId: voucherId,
        row: row,
      );
      next.add(VoucherSheetReceipt(localPath: row.localPath, serverId: uploaded.id));
    } on AuthApiException catch (e) {
      failed++;
      lastError = e;
      next.add(row);
    } on ReceiptImageCompressionException catch (e) {
      failed++;
      lastError = e;
      next.add(row);
    } catch (e) {
      failed++;
      lastError = e;
      next.add(row);
    }
  }
  return (receipts: next, failedCount: failed, lastError: lastError);
}

Future<void> deleteRemoteReceipt({
  required VouchersRepository repo,
  required String receiptId,
}) =>
    repo.deleteReceipt(receiptId);

/// Deletes staged receipt ids; failed ids are returned for retry. Does not rethrow.
Future<({int failedCount, List<String> failedIds, List<String> deletedIds})>
    deletePendingReceiptsBestEffort({
  required VouchersRepository repo,
  required List<String> receiptIds,
}) async {
  if (receiptIds.isEmpty) {
    return (failedCount: 0, failedIds: const <String>[], deletedIds: const <String>[]);
  }
  var failed = 0;
  final failedIds = <String>[];
  final deletedIds = <String>[];
  for (final id in receiptIds) {
    try {
      await repo.deleteReceipt(id);
      deletedIds.add(id);
    } on AuthApiException {
      failed++;
      failedIds.add(id);
    } catch (_) {
      failed++;
      failedIds.add(id);
    }
  }
  return (failedCount: failed, failedIds: failedIds, deletedIds: deletedIds);
}

/// On save: delete staged server receipts first, then upload pending local files.
Future<
    ({
      List<VoucherSheetReceipt> receipts,
      int failedUploadCount,
      int failedDeleteCount,
      List<String> failedDeleteIds,
      List<String> deletedReceiptIds,
      Object? lastReceiptError,
    })> syncVoucherReceiptsOnSave({
  required VouchersRepository repo,
  required String voucherId,
  required List<String> receiptIdsToDelete,
  required List<VoucherSheetReceipt> receipts,
}) async {
  final delete = await deletePendingReceiptsBestEffort(
    repo: repo,
    receiptIds: receiptIdsToDelete,
  );
  if (delete.failedCount > 0) {
    return (
      receipts: receipts,
      failedUploadCount: 0,
      failedDeleteCount: delete.failedCount,
      failedDeleteIds: delete.failedIds,
      deletedReceiptIds: delete.deletedIds,
      lastReceiptError: null,
    );
  }
  final upload = await uploadPendingReceiptsBestEffort(
    repo: repo,
    voucherId: voucherId,
    receipts: receipts,
  );
  return (
    receipts: upload.receipts,
    failedUploadCount: upload.failedCount,
    failedDeleteCount: 0,
    failedDeleteIds: const <String>[],
    deletedReceiptIds: delete.deletedIds,
    lastReceiptError: upload.lastError,
  );
}
