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
    this.agreementId,
    this.onlineAgreementsOnly = false,
    this.usesRemoteMoney = false,
  });

  final String craftsmanId;
  final String name;
  final String? trade;
  final int paidPiastres;
  final int? agreedPiastres;
  final int? remainingPiastres;
  final String accentKey;
  final String? agreementId;
  final bool onlineAgreementsOnly;
  final bool usesRemoteMoney;
}

class ClientDetailItemRowData {
  const ClientDetailItemRowData({
    this.itemId,
    required this.name,
    required this.colorKey,
    required this.iconName,
    required this.breakdown,
  });

  final String? itemId;
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
    this.usesRemoteMinorUnits = false,
  });

  final Transaction transaction;
  final String? itemName;
  final String? payeeName;
  final bool? payeeIsSupplier;
  final bool usesRemoteMinorUnits;
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
    this.onlineIdentityOnly = false,
    this.usesRemoteMoney = false,
    this.remainingFromServer,
  });

  final Client client;
  final Project project;
  final int? receivedPiastres;
  final int? spentPiastres;
  final int? estimatedProfitPiastres;
  final List<ClientCraftsmanPreviewRow> craftsmanPreviews;
  final List<ClientDetailItemRowData> topItems;
  final List<ClientDetailMovementLine> latestMovements;
  final bool onlineIdentityOnly;

  /// Online voucher/client balances use minor units per EGP × 100.
  final bool usesRemoteMoney;

  final int? remainingFromServer;

  bool get hasBalances => receivedPiastres != null && spentPiastres != null;

  int? get remainingPiastres {
    if (remainingFromServer != null) return remainingFromServer;
    if (!hasBalances) return null;
    return receivedPiastres! - spentPiastres!;
  }
}
