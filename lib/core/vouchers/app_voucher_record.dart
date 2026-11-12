import '../clients/client_api_record.dart';
import '../database/database.dart';
import 'app_voucher_receipt.dart';

class AppVoucher {
  const AppVoucher({
    required this.id,
    required this.clientId,
    required this.type,
    required this.amountMinor,
    required this.voucherDate,
    required this.method,
    this.description,
    this.itemId,
    this.providerId,
    this.expenseClassification,
    this.clientName,
    this.itemName,
    this.providerName,
    this.projectId,
    this.receipts = const [],
  });

  final String id;
  final String clientId;
  final String type;
  final int amountMinor;
  final DateTime voucherDate;
  final String method;
  final String? description;
  final String? itemId;
  final String? providerId;
  final String? expenseClassification;
  final String? clientName;
  final String? itemName;
  final String? providerName;
  final String? projectId;
  final List<AppVoucherReceipt> receipts;

  bool get isReceive => type == 'receive';
  bool get isSpend => type == 'spend';

  String? get supplierId =>
      isSpend && expenseClassification == 'materials' ? providerId : null;

  String? get craftsmanId => isSpend && expenseClassification == 'labor' ? providerId : null;

  String? get expenseType => expenseClassification;

  static AppVoucher fromDataJson(Map<String, dynamic> json) {
    final client = json['client'];
    String? clientName;
  String? projectId;
    if (client is Map<String, dynamic>) {
      clientName = client['name'] as String?;
      final project = client['project'];
      if (project is Map<String, dynamic>) {
        projectId = project['id'] as String?;
      }
    }

    String? itemName;
    final item = json['item'];
    if (item is Map<String, dynamic>) {
      itemName = item['name'] as String?;
    }

    String? providerName;
    final provider = json['provider'];
    if (provider is Map<String, dynamic>) {
      providerName = provider['name'] as String?;
    }

    final dateRaw = (json['date'] ?? json['voucher_date']) as String;
    final parts = dateRaw.split('-');
    final voucherDate = DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final paymentMethod = (json['payment_method'] ?? json['method']) as String;

    final receiptsRaw = json['receipts'];
    final receipts = receiptsRaw is List
        ? receiptsRaw
            .map((e) => AppVoucherReceipt.fromDataJson(e as Map<String, dynamic>))
            .toList()
        : const <AppVoucherReceipt>[];

    return AppVoucher(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      type: json['type'] as String,
      amountMinor: (json['amount'] as num).toInt(),
      voucherDate: voucherDate,
      method: paymentMethod,
      description: json['description'] as String?,
      itemId: json['item_id'] as String?,
      providerId: json['provider_id'] as String?,
      expenseClassification: json['expense_classification'] as String?,
      clientName: clientName,
      itemName: itemName,
      providerName: providerName,
      projectId: projectId,
      receipts: receipts,
    );
  }

  Transaction toLedgerTransaction({required String projectId}) {
    final now = DateTime.now().toUtc();
    return Transaction(
      id: id,
      workspaceId: remoteWorkspaceMarker,
      projectId: projectId,
      kind: type,
      amountPiastres: amountMinor,
      date: voucherDate,
      method: method,
      description: description,
      receiptImagePath: null,
      itemId: itemId,
      expenseType: expenseClassification,
      supplierId: supplierId,
      craftsmanId: craftsmanId,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class VouchersListPage {
  const VouchersListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<AppVoucher> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}
