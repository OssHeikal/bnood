import 'package:bnood/core/api/api_accept_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps locale to ar or en Accept-Language', () {
    expect(acceptLanguageHeaderForLocale('ar'), 'ar');
    expect(acceptLanguageHeaderForLocale('ar_EG'), 'ar');
    expect(acceptLanguageHeaderForLocale('en'), 'en');
    expect(acceptLanguageHeaderForLocale('en_US'), 'en');
  });
}
