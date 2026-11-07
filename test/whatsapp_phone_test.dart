import 'package:bnood/core/utils/whatsapp_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('waMeDigits normalizes Egypt mobile', () {
    expect(WhatsAppPhone.waMeDigits('01012345678'), '201012345678');
    expect(WhatsAppPhone.waMeDigits('+20 10 1234 5678'), '201012345678');
  });

  test('waMeDigits rejects empty or too short', () {
    expect(WhatsAppPhone.waMeDigits(''), isNull);
    expect(WhatsAppPhone.waMeDigits('123'), isNull);
  });
}
