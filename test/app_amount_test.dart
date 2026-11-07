import 'package:bnood/core/widgets/app_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatPiastres ar shows EGP and western digits', () {
    final ar = AppAmount.format(piastres: 1_200_000, localeCode: 'ar');
    expect(ar, contains('EGP'));
    expect(ar, contains('12,000'));
    expect(ar, isNot(contains('١')));
    expect(ar, isNot(contains('ج.م')));
  });

  test('formatPiastres en also shows EGP', () {
    final en = AppAmount.format(piastres: 1_200_000, localeCode: 'en');
    expect(en, contains('EGP'));
    expect(en, contains('12,000'));
  });

  test('format without currency strips suffix', () {
    final plain = AppAmount.format(piastres: 500_000, localeCode: 'en', showCurrency: false);
    expect(plain, isNot(contains('EGP')));
    expect(plain, isNot(contains('ج.م')));
  });
}
