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

  /// Whole-period preset: natural client start through Cairo today (remote API).
  static PeriodBounds wholePeriodBounds({DateTime? naturalStart, DateTime? referenceUtc}) {
    final today = cairoTodayDate(referenceUtc);
    final rawStart = naturalStart ?? today;
    final startDay = DateTime(rawStart.year, rawStart.month, rawStart.day);
    final start = startDay.isAfter(today) ? today : startDay;
    return PeriodBounds.normalize(start: start, end: today);
  }

  static DateTime cairoCalendarDayFromUtc(DateTime utc) {
    final cairo = cairoLocalNow(utc.toUtc());
    return DateTime(cairo.year, cairo.month, cairo.day);
  }

  static DateTime? parseStatementApiDate(String? ymd) {
    if (ymd == null || ymd.isEmpty) return null;
    final parts = ymd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static PeriodBounds allTimeBounds(
    Iterable<Transaction> rows, {
    DateTime? emptyFallbackStart,
    DateTime? referenceUtc,
  }) {
    final today = cairoTodayDate(referenceUtc);
    if (rows.isEmpty) {
      final fallback = emptyFallbackStart != null
          ? DateTime(emptyFallbackStart.year, emptyFallbackStart.month, emptyFallbackStart.day)
          : today;
      final start = fallback.isAfter(today) ? today : fallback;
      return PeriodBounds.normalize(start: start, end: today);
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
