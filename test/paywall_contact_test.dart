import 'package:bnood/core/subscription/paywall_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyPaywallContactPlaceholders fills plan period and user fields', () {
    final out = applyPaywallContactPlaceholders(
      'Plan {plan}, {period}, {user_name}, {phone}',
      plan: 'Enterprise',
      period: 'سنوية',
      userName: 'Osama',
      phone: '01011111111',
    );
    expect(out, 'Plan Enterprise, سنوية, Osama, 01011111111');
  });

  test('parses contact payload from json', () {
    final contact = AppPaywallContact.fromJson({
      'whatsapp_phone': '2010999888777',
      'message_template': 'Hi {plan}',
      'whatsapp_url': 'https://wa.me/2010999888777?text=Hi',
      'contact_url': 'https://example.com',
    });
    expect(contact?.whatsappPhone, '2010999888777');
    expect(contact?.whatsappUrl, contains('wa.me'));
  });
}