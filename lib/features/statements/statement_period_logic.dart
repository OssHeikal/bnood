import '../../core/database/database.dart';
import '../../core/money/period_bounds.dart';
import 'statement_export_store.dart';

enum StatementPeriodPreset { today, month, all, sinceLastExport, custom }

/// Inclusive local-calendar period presets for statements.
abstract final class StatementPeriodLogic {
  static PeriodBounds todayBounds() {
    final now = DateTime.now();
    return PeriodBounds.normalize(start: now, end: now);
  }

  static PeriodBounds monthBounds() {
    final now = DateTime.now();
    return PeriodBounds.normalize(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  static PeriodBounds allTimeBounds(Iterable<Transaction> rows) {
    final now = DateTime.now();
    if (rows.isEmpty) {
      return PeriodBounds.normalize(start: now, end: now);
    }
    var min = rows.first.date;
    var max = rows.first.date;
    for (final t in rows) {
      if (t.date.isBefore(min)) min = t.date;
      if (t.date.isAfter(max)) max = t.date;
    }
    final end = max.isAfter(now) ? max : now;
    return PeriodBounds.normalize(start: min, end: end);
  }

  /// Starts the calendar day **after** [record.periodEndInclusive] through today.
  ///
  /// Transactions are filtered by **date-only** fields; export time cannot split a day.
  static PeriodBounds? sinceLastExportBounds(StatementExportRecord? record) {
    if (record == null) return null;
    final nextDay = DateTime(
      record.periodEndInclusive.year,
      record.periodEndInclusive.month,
      record.periodEndInclusive.day,
    ).add(const Duration(days: 1));
    final end = DateTime.now();
    var start = nextDay;
    if (start.isAfter(DateTime(end.year, end.month, end.day))) {
      start = DateTime(end.year, end.month, end.day);
    }
    return PeriodBounds.normalize(start: start, end: end);
  }

  static String formatPeriodRangeLabel(PeriodBounds bounds) {
    final s = '${bounds.start.day}/${bounds.start.month}/${bounds.start.year}';
    final e = '${bounds.end.day}/${bounds.end.month}/${bounds.end.year}';
    return s == e ? s : '$s — $e';
  }
}
