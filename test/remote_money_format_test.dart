import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/money/remote_money_format.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('minor display uses three decimal major units', () {
    expect(RemoteMoneyFormat.formatMinor(1500), '1.5 EGP');
    expect(RemoteMoneyFormat.formatMinor(1000), '1 EGP');
  });

  test('parse major input returns minor integers', () {
    expect(RemoteMoneyFormat.parseMajorInput('1.25'), 1250);
    expect(RemoteMoneyFormat.parseMajorInput('2'), 2000);
  });

  test('agreement null remaining distinct from zero', () {
    final unset = AppAgreement.fromDataJson({
      'id': 'a1',
      'client_id': 'c1',
      'provider_id': 'p1',
      'amount': null,
      'paid': 0,
      'remaining': null,
    });
    final zeroRemain = AppAgreement.fromDataJson({
      'id': 'a2',
      'client_id': 'c1',
      'provider_id': 'p1',
      'amount': 10.5,
      'paid': 10.5,
      'remaining': 0,
    });
    expect(unset.remainingMinorForDisplay, isNull);
    expect(zeroRemain.remainingMinorForDisplay, 0);
    expect(zeroRemain.paidMinorForDisplay, RemoteMoneyUnits.majorToMinor(10.5));
  });
}
