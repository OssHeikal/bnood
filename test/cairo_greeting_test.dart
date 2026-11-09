import 'package:bnood/core/formatting/cairo_local_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('morning before noon Cairo local', () {
    final cairo = cairoLocalNow(DateTime.utc(2026, 11, 9, 8, 0));
    expect(cairo.hour, 10);
    expect(cairoIsMorning(cairo), isTrue);
  });

  test('evening from noon Cairo local', () {
    final cairo = cairoLocalNow(DateTime.utc(2026, 11, 9, 12, 0));
    expect(cairo.hour, 14);
    expect(cairoIsMorning(cairo), isFalse);
  });
}
