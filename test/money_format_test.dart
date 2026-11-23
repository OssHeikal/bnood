import 'package:bnood/core/domain/money/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse egp input to piastres', () {
    expect(MoneyFormat.parseEgpInput('20000'), 2000000);
    expect(MoneyFormat.parseEgpInput('1,000,000'), 100000000);
    expect(MoneyFormat.parseEgpInput('20.5'), 2050);
    expect(MoneyFormat.parseEgpInput('٢٠.٥'), 2050);
  });

  test('format ar locale keeps western digits and EGP', () {
    expect(MoneyFormat.formatPiastres(100000, locale: 'ar_EG'), '1,000 EGP');
    expect(MoneyFormat.formatPiastres(100000, locale: 'en_US'), '1,000 EGP');
  });

  test('display rounds to whole EGP half away from zero', () {
    expect(MoneyFormat.displayWholeEgpFromPiastres(0), 0);
    expect(MoneyFormat.displayWholeEgpFromPiastres(49), 0);
    expect(MoneyFormat.displayWholeEgpFromPiastres(50), 1);
    expect(MoneyFormat.displayWholeEgpFromPiastres(100), 1);
    expect(MoneyFormat.displayWholeEgpFromPiastres(33_649_591), 336_496);
    expect(MoneyFormat.displayWholeEgpFromPiastres(-1_250), -13);
    expect(MoneyFormat.displayWholeEgpFromPiastres(-49), 0);
    expect(MoneyFormat.displayWholeEgpFromPiastres(-50), -1);

    expect(
      MoneyFormat.formatPiastres(33_649_591),
      '336,496 EGP',
    );
    expect(MoneyFormat.formatPiastres(-1_250), '−13 EGP');
  });

  test('engineer profit rounds down', () {
    expect(
      MoneyFormat.estimatedProfitPiastres(
        totalSpendPiastres: 1000099,
        engineerBasisPoints: 1050,
      ),
      (1000099 * 1050) ~/ 10000,
    );
  });
}
