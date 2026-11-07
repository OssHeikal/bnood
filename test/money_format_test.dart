import 'package:bnood/core/money/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse egp input to piastres', () {
    expect(MoneyFormat.parseEgpInput('20000'), 2000000);
    expect(MoneyFormat.parseEgpInput('20.5'), 2050);
  });

  test('engineer profit rounds down', () {
    expect(
      MoneyFormat.estimatedProfitPiastres(
          totalSpendPiastres: 1000099, engineerBasisPoints: 1050),
      (1000099 * 1050) ~/ 10000,
    );
  });
}
