import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/features/statements/statement_period_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monthBounds uses Cairo calendar day for end date', () {
    // Device local is still Nov 10, but Cairo is Nov 9 (UTC evening).
    final reference = DateTime.utc(2026, 11, 9, 21, 0);
    final bounds = StatementPeriodLogic.monthBounds(reference);
    expect(bounds.end.year, 2026);
    expect(bounds.end.month, 11);
    expect(bounds.end.day, 9);
    expect(bounds.start.day, 1);
  });

  test('wholePeriodBounds uses natural start through Cairo today', () {
    final reference = DateTime.utc(2026, 11, 9, 21, 0);
    final bounds = StatementPeriodLogic.wholePeriodBounds(
      naturalStart: DateTime(2025, 6, 15),
      referenceUtc: reference,
    );
    expect(bounds.start.year, 2025);
    expect(bounds.start.month, 6);
    expect(bounds.start.day, 15);
    expect(bounds.end.day, 9);
  });

  test('clampForRemoteApi caps future end to Cairo today', () {
    final reference = DateTime.utc(2026, 11, 9, 21, 0);
    final bounds = PeriodBounds.normalize(
      start: DateTime(2026, 11, 1),
      end: DateTime(2026, 11, 10),
    );
    final capped = StatementPeriodLogic.clampForRemoteApi(bounds, reference);
    expect(capped.end.day, 9);
    expect(capped.start.day, 1);
  });
}
