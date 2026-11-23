import 'package:bnood/features/providers/data/app_agreement_record.dart';
import 'package:bnood/core/domain/money/remote_money_format.dart';
import 'package:bnood/core/domain/money/remote_money_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatMajor rounds fractional major units for display', () {
    expect(RemoteMoneyFormat.formatMajor(336495.91), '336,496 EGP');
    expect(RemoteMoneyFormat.formatMajor(-12.5), '−13 EGP');
  });

  test('minor display uses whole EGP rounded half away from zero', () {
    expect(RemoteMoneyFormat.formatMinor(150), '2 EGP');
    expect(RemoteMoneyFormat.formatMinor(100), '1 EGP');
    expect(RemoteMoneyFormat.formatMinor(149), '1 EGP');
    expect(RemoteMoneyFormat.formatMinor(29900), '299 EGP');
    expect(RemoteMoneyFormat.formatMinor(299000), '2,990 EGP');
    expect(RemoteMoneyFormat.formatMinor(-1250), '−13 EGP');
  });

  test('parse major input returns minor integers', () {
    expect(RemoteMoneyFormat.parseMajorInput('1.25'), 125);
    expect(RemoteMoneyFormat.parseMajorInput('2'), 200);
    expect(RemoteMoneyFormat.parseMajorInput('299'), 29900);
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

  test('minorPerMajor is 100', () {
    expect(RemoteMoneyUnits.minorPerMajor, 100);
    expect(RemoteMoneyUnits.minorToMajor(29900), 299);
  });
}
