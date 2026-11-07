import 'package:bnood/core/widgets/app_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatPiastres ar shows currency', () {
    expect(AppAmount.format(piastres: 1_200_000, localeCode: 'ar'), contains('ج.م'));
    expect(AppAmount.format(piastres: 1_200_000, localeCode: 'ar'), contains('١٢'));
  });

  test('format without currency strips suffix', () {
    final plain = AppAmount.format(piastres: 500_000, localeCode: 'en', showCurrency: false);
    expect(plain, isNot(contains('EGP')));
    expect(plain, isNot(contains('ج.م')));
  });
}
