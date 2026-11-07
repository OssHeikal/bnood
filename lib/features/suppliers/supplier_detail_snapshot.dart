import '../../core/database/database.dart';
import '../clients/client_detail_snapshot.dart';

class SupplierDetailHistoryEntry {
  const SupplierDetailHistoryEntry({
    required this.line,
    required this.clientId,
    required this.clientName,
  });

  final ClientDetailMovementLine line;
  final String clientId;
  final String clientName;
}

class SupplierDetailSnapshot {
  const SupplierDetailSnapshot({
    required this.supplier,
    required this.totalPaidPiastres,
    required this.history,
  });

  final Supplier supplier;
  final int totalPaidPiastres;
  final List<SupplierDetailHistoryEntry> history;
}

class SupplierDetailNotFound implements Exception {
  const SupplierDetailNotFound();
}
