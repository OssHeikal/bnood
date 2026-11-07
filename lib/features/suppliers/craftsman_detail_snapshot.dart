import '../../core/database/database.dart';
import '../clients/client_detail_snapshot.dart';

class CraftsmanDetailJobRow {
  const CraftsmanDetailJobRow({
    required this.projectId,
    required this.clientId,
    required this.clientName,
    required this.paidPiastres,
    this.agreedPiastres,
    this.remainingPiastres,
  });

  final String projectId;
  final String clientId;
  final String clientName;
  final int paidPiastres;
  final int? agreedPiastres;
  final int? remainingPiastres;
}

class CraftsmanDetailHistoryEntry {
  const CraftsmanDetailHistoryEntry({
    required this.line,
    required this.clientId,
    required this.clientName,
  });

  final ClientDetailMovementLine line;
  final String clientId;
  final String clientName;
}

class CraftsmanDetailSnapshot {
  const CraftsmanDetailSnapshot({
    required this.craftsman,
    required this.totalLaborPaidPiastres,
    required this.linkedProjectCount,
    required this.jobs,
    required this.history,
  });

  final CraftsmenData craftsman;
  final int totalLaborPaidPiastres;
  final int linkedProjectCount;
  final List<CraftsmanDetailJobRow> jobs;
  final List<CraftsmanDetailHistoryEntry> history;
}

class CraftsmanDetailNotFound implements Exception {
  const CraftsmanDetailNotFound();
}
