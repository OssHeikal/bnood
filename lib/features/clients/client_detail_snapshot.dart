import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';

class ClientCraftsmanPreviewRow {
  const ClientCraftsmanPreviewRow({
    required this.craftsmanId,
    required this.name,
    this.trade,
    required this.paidPiastres,
    this.agreedPiastres,
    this.remainingPiastres,
    required this.accentKey,
  });

  final String craftsmanId;
  final String name;
  final String? trade;
  final int paidPiastres;
  final int? agreedPiastres;
  final int? remainingPiastres;
  final String accentKey;
}

class ClientDetailItemRowData {
  const ClientDetailItemRowData({
    required this.name,
    required this.colorKey,
    required this.iconName,
    required this.breakdown,
  });

  final String name;
  final String colorKey;
  final String iconName;
  final ItemExpenseBreakdown breakdown;
}

class ClientDetailMovementLine {
  const ClientDetailMovementLine({
    required this.transaction,
    this.itemName,
    this.payeeName,
    this.payeeIsSupplier,
  });

  final Transaction transaction;
  final String? itemName;
  final String? payeeName;
  final bool? payeeIsSupplier;
}

class ClientDetailSnapshot {
  const ClientDetailSnapshot({
    required this.client,
    required this.project,
    required this.receivedPiastres,
    required this.spentPiastres,
    required this.estimatedProfitPiastres,
    required this.craftsmanPreviews,
    required this.topItems,
    required this.latestMovements,
  });

  final Client client;
  final Project project;
  final int receivedPiastres;
  final int spentPiastres;
  final int? estimatedProfitPiastres;
  final List<ClientCraftsmanPreviewRow> craftsmanPreviews;
  final List<ClientDetailItemRowData> topItems;
  final List<ClientDetailMovementLine> latestMovements;

  int get remainingPiastres => receivedPiastres - spentPiastres;
}
