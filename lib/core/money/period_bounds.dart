/// Inclusive local-calendar period boundaries for statements.
class PeriodBounds {
  const PeriodBounds({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  DateTime get startOfDay => DateTime(start.year, start.month, start.day);

  DateTime get endOfDay =>
      DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

  static PeriodBounds normalize(
      {required DateTime start, required DateTime end}) {
    final s = DateTime(start.year, start.month, start.day);
    var e = DateTime(end.year, end.month, end.day);
    if (e.isBefore(s)) {
      e = s;
    }
    return PeriodBounds(start: s, end: e);
  }

  bool containsLocalDate(DateTime value) {
    final d = DateTime(value.year, value.month, value.day);
    return !d.isBefore(startOfDay) &&
        !d.isAfter(DateTime(end.year, end.month, end.day));
  }

  bool isStrictlyBefore(DateTime value) {
    final d = DateTime(value.year, value.month, value.day);
    return d.isBefore(startOfDay);
  }
}
