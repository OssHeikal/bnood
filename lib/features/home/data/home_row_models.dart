import 'package:bnood/core/ledger/ledger_entities.dart';

class HomeTotals {
  const HomeTotals({
    required this.receivedPiastres,
    required this.spentPiastres,
    this.remainingPiastresOverride,
  });

  final int receivedPiastres;
  final int spentPiastres;
  final int? remainingPiastresOverride;

  int get remainingPiastres => remainingPiastresOverride ?? receivedPiastres - spentPiastres;
}

class HomeSupplierSpendRow {
  const HomeSupplierSpendRow({required this.supplier, required this.spentPiastres});
  final Supplier supplier;
  final int spentPiastres;
}

class HomeCraftsmanActivityRow {
  const HomeCraftsmanActivityRow({
    required this.craftsman,
    required this.paidPiastres,
    required this.lastLaborAt,
    required this.remainingPiastres,
    this.clientsCount,
  });

  final CraftsmenData craftsman;
  final int paidPiastres;
  final DateTime lastLaborAt;
  final int? remainingPiastres;
  final int? clientsCount;
}

class HomeClientBalanceRow {
  const HomeClientBalanceRow({
    required this.client,
    required this.remainingPiastres,
    required this.receivedPiastres,
    required this.spentPiastres,
    this.project,
  });

  final Client client;
  final int? remainingPiastres;
  final int? receivedPiastres;
  final int? spentPiastres;
  final Project? project;

  bool get hasBalances =>
      remainingPiastres != null && receivedPiastres != null && spentPiastres != null;
}