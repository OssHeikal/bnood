import '../api/vouchers_api.dart';
import 'app_voucher_receipt.dart';
import 'app_voucher_record.dart';

class VouchersRepository {
  VouchersRepository(this._api);

  final VouchersApi _api;

  Future<VouchersListPage> listVouchers({
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listVouchers(q: q, page: page, perPage: perPage);

  Future<VouchersListPage> listClientVouchers({
    required String clientId,
    String? q,
    String? itemId,
    String? from,
    String? to,
    String sort = 'date_desc',
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listClientVouchers(
        clientId: clientId,
        q: q,
        itemId: itemId,
        from: from,
        to: to,
        sort: sort,
        page: page,
        perPage: perPage,
      );

  Future<VouchersListPage> listProviderVouchers({
    required String providerId,
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listProviderVouchers(providerId: providerId, q: q, page: page, perPage: perPage);

  Future<List<AppVoucher>> listAllClientVouchers(String clientId) =>
      _listAll((page) => listClientVouchers(clientId: clientId, page: page));

  Future<List<AppVoucher>> listAllProviderVouchers(String providerId) =>
      _listAll((page) => listProviderVouchers(providerId: providerId, page: page));

  Future<AppVoucher> getVoucher(String id) => _api.getVoucher(id);

  Future<AppVoucher> createVoucher({
    required String clientId,
    required String type,
    required int amountMinor,
    required String voucherDate,
    required String method,
    String? description,
    String? itemId,
    String? providerId,
    String? expenseClassification,
  }) =>
      _api.createVoucher(
        clientId: clientId,
        type: type,
        amountMinor: amountMinor,
        voucherDate: voucherDate,
        method: method,
        description: description,
        itemId: itemId,
        providerId: providerId,
        expenseClassification: expenseClassification,
      );

  Future<AppVoucher> patchVoucher({
    required String id,
    int? amountMinor,
    String? voucherDate,
    String? method,
    String? description,
    bool clearDescription = false,
    String? itemId,
    String? providerId,
    String? expenseClassification,
    bool clearProvider = false,
  }) =>
      _api.patchVoucher(
        id: id,
        amountMinor: amountMinor,
        voucherDate: voucherDate,
        method: method,
        description: description,
        clearDescription: clearDescription,
        itemId: itemId,
        providerId: providerId,
        expenseClassification: expenseClassification,
        clearProvider: clearProvider,
      );

  Future<void> deleteVoucher(String id) => _api.deleteVoucher(id);

  Future<List<AppVoucherReceipt>> listVoucherReceipts(String voucherId) =>
      _api.listVoucherReceipts(voucherId);

  Future<AppVoucherReceipt> uploadVoucherReceipt({
    required String voucherId,
    required String filePath,
    required String filename,
  }) =>
      _api.uploadVoucherReceipt(voucherId: voucherId, filePath: filePath, filename: filename);

  Future<List<int>> downloadReceiptBytes(String receiptId) => _api.downloadReceiptBytes(receiptId);

  Future<void> deleteReceipt(String receiptId) => _api.deleteReceipt(receiptId);

  Future<List<AppVoucher>> _listAll(
    Future<VouchersListPage> Function(int page) fetch,
  ) async {
    final all = <AppVoucher>[];
    var page = 1;
    while (true) {
      final result = await fetch(page);
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    return all;
  }
}
