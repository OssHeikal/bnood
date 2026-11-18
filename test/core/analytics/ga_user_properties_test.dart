import 'package:bnood/core/analytics/ga_user_properties.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('truncateGaUserProperty respects 36-char limit', () {
    expect(truncateGaUserProperty('short'), 'short');
    expect(truncateGaUserProperty(null), isNull);
    expect(truncateGaUserProperty('   '), isNull);

    final input = 'a' * 50;
    expect(truncateGaUserProperty(input), 'a' * gaUserPropertyMaxLength);
  });
}