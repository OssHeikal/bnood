import 'package:bnood/core/money/basis_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse percent with decimals', () {
    expect(BasisPoints.parsePercentInput('10.5')?.value, 1050);
    expect(BasisPoints.parsePercentInput(''), isNull);
    expect(BasisPoints.parsePercentInput('101'), isNull);
  });
}
