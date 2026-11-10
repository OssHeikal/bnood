import '../../core/database/database.dart';
import '../../core/formatting/cairo_local_time.dart';
import '../../core/money/period_bounds.dart';
import 'statement_export_store.dart';

enum StatementPeriodPreset { today, month, all, sinceLastExport, custom }

/// Inclusive local-calendar period presets for statements.
abstract final class StatementPeriodLogic {
  /// Calendar "today" for statement ranges — matches API validation (Africa/Cairo).
  static DateTime cairoTodayDate([DateTime? referenceUtc]) {
    final cairo = cairoLocalNow(referenceUtc);
    return DateTime(cairo.year, cairo.month, cairo.day);
  }

  static PeriodBounds todayBounds([DateTime? referenceUtc]) {
    final today = cairoTodayDate(referenceUtc);
    return PeriodBounds.normalize(start: today, end: today);
  }

  static PeriodBounds monthBounds([DateTime? referenceUtc]) {
    final today = cairoTodayDate(referenceUtc);
    return PeriodBounds.normalize(
      start: DateTime(today.year, today.month, 1),
      end: today,
    );
  }

  /// Online statements: server accepts `from` not before 2000-01-01.
  static PeriodBounds remoteAllTimeBounds([DateTime? referenceUtc]) => PeriodBounds.normalize(
        start: DateTime(2000, 1, 1),
        end: cairoTodayDate(referenceUtc),
      );

  static PeriodBounds allTimeBounds(Iterable<Transaction> rows, [DateTime? referenceUtc]) {
    final today = cairoTodayDate(referenceUtc);
    if (rows.isEmpty) {
      return PeriodBounds.normalize(start: today, end: today);
    }
    var min = rows.first.date;
    var max = rows.first.date;
    for (final t in rows) {
      if (t.date.isBefore(min)) min = t.date;
      if (t.date.isAfter(max)) max = t.date;
    }
    final maxDay = DateTime(max.year, max.month, max.day);
    final end = maxDay.isAfter(today) ? today : maxDay;
    return PeriodBounds.normalize(start: min, end: end);
  }

  /// Caps `to` at Cairo today so remote statement APIs never receive a future date.
  static PeriodBounds clampForRemoteApi(PeriodBounds bounds, [DateTime? referenceUtc]) {
    final today = cairoTodayDate(referenceUtc);
    final endDay = DateTime(bounds.end.year, bounds.end.month, bounds.end.day);
    final cappedEnd = endDay.isAfter(today) ? today : bounds.end;
    return PeriodBounds.normalize(start: bounds.start, end: cappedEnd);
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
    final today = cairoTodayDate();
    var start = nextDay;
    if (start.isAfter(today)) {
      start = today;
    }
    return PeriodBounds.normalize(start: start, end: today);
  }

  static String formatPeriodRangeLabel(PeriodBounds bounds) {
    final s = '${bounds.start.day}/${bounds.start.month}/${bounds.start.year}';
    final e = '${bounds.end.day}/${bounds.end.month}/${bounds.end.year}';
    return s == e ? s : '$s — $e';
  }
}
