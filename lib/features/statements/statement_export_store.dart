import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Client vs supplier PDF export cursor — never shared.
enum StatementEntityKind { client, supplier }

/// Metadata from the last **successful PDF generation** (not share delivery).
class StatementExportRecord {
  const StatementExportRecord({
    required this.exportedAt,
    required this.periodEndInclusive,
  });

  final DateTime exportedAt;
  final DateTime periodEndInclusive;

  Map<String, dynamic> toJson() => {
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'periodEndY': periodEndInclusive.year,
        'periodEndM': periodEndInclusive.month,
        'periodEndD': periodEndInclusive.day,
      };

  factory StatementExportRecord.fromJson(Map<String, dynamic> json) {
    final exportedAt = DateTime.parse(json['exportedAt'] as String).toLocal();
    final y = json['periodEndY'] as int;
    final m = json['periodEndM'] as int;
    final d = json['periodEndD'] as int;
    return StatementExportRecord(
      exportedAt: exportedAt,
      periodEndInclusive: DateTime(y, m, d),
    );
  }
}

/// Persists last successful statement PDF export per workspace + entity.
class StatementExportStore {
  StatementExportStore(this._prefs);

  final SharedPreferences _prefs;

  static const _keyPrefix = 'stmt_pdf_v1';

  static String storageKey({
    required String workspaceId,
    required StatementEntityKind kind,
    required String entityId,
  }) =>
      '${_keyPrefix}_${workspaceId}_${kind.name}_$entityId';

  StatementExportRecord? read({
    required String workspaceId,
    required StatementEntityKind kind,
    required String entityId,
  }) {
    final raw = _prefs.getString(storageKey(workspaceId: workspaceId, kind: kind, entityId: entityId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return StatementExportRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordSuccessfulExport({
    required String workspaceId,
    required StatementEntityKind kind,
    required String entityId,
    required DateTime exportedAt,
    required DateTime periodEndInclusive,
  }) async {
    final end = DateTime(
      periodEndInclusive.year,
      periodEndInclusive.month,
      periodEndInclusive.day,
    );
    final record = StatementExportRecord(exportedAt: exportedAt, periodEndInclusive: end);
    await _prefs.setString(
      storageKey(workspaceId: workspaceId, kind: kind, entityId: entityId),
      jsonEncode(record.toJson()),
    );
  }
}
