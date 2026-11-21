import 'package:bnood/core/subscription/paywall_money_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('whole major rounds piastres for paywall display', () {
    expect(PaywallMoneyDisplay.wholeMajorFromMinor(17494), 175);
    expect(PaywallMoneyDisplay.wholeMajorFromMinor(24917), 249);
    expect(PaywallMoneyDisplay.formatMinorWhole(299000, arabic: true), '2,999 ج.م');
  });
}