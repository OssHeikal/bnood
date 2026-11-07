import 'package:bnood/core/money/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse egp input to piastres', () {
    expect(MoneyFormat.parseEgpInput('20000'), 2000000);
    expect(MoneyFormat.parseEgpInput('20.5'), 2050);
    expect(MoneyFormat.parseEgpInput('٢٠.٥'), 2050);
  });

  test('format ar locale keeps western digits and EGP', () {
    expect(MoneyFormat.formatPiastres(100000, locale: 'ar_EG'), '1,000 EGP');
    expect(MoneyFormat.formatPiastres(100000, locale: 'en_US'), '1,000 EGP');
  });

  test('engineer profit rounds down', () {
    expect(
      MoneyFormat.estimatedProfitPiastres(
          totalSpendPiastres: 1000099, engineerBasisPoints: 1050),
      (1000099 * 1050) ~/ 10000,
    );
  });
}
