import 'package:bnood/core/validation/egypt_mobile_phone.dart';
import 'package:bnood/core/validation/egypt_mobile_phone_validation.dart';
import 'package:bnood/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EgyptMobilePhone.normalizeDigits', () {
    test('accepts 11-digit local numbers with allowed prefixes', () {
      expect(EgyptMobilePhone.normalizeDigits('01012345678'), '01012345678');
      expect(EgyptMobilePhone.normalizeDigits('01112345678'), '01112345678');
      expect(EgyptMobilePhone.normalizeDigits('01212345678'), '01212345678');
      expect(EgyptMobilePhone.normalizeDigits('01512345678'), '01512345678');
    });

    test('strips +20 and 0020 prefixes', () {
      expect(EgyptMobilePhone.normalizeDigits('+201012345678'), '01012345678');
      expect(EgyptMobilePhone.normalizeDigits('00201012345678'), '01012345678');
      expect(EgyptMobilePhone.normalizeDigits('201012345678'), '01012345678');
      expect(EgyptMobilePhone.normalizeDigits('+20 10 1234-5678'), '01012345678');
    });

    test('rejects invalid prefix or length', () {
      expect(EgyptMobilePhone.normalizeDigits('01312345678'), isNull);
      expect(EgyptMobilePhone.normalizeDigits('0101234567'), isNull);
      expect(EgyptMobilePhone.normalizeDigits('abc'), isNull);
    });
  });

  group('validateOptionalEgyptMobile', () {
    final l10n = AppLocalizationsEn();

    test('empty optional field passes', () {
      expect(validateOptionalEgyptMobile(l10n, ''), isNull);
      expect(validateOptionalEgyptMobile(l10n, '   '), isNull);
    });

    test('invalid value returns localized hint', () {
      expect(validateOptionalEgyptMobile(l10n, '123'), l10n.egyptMobileInvalid);
    });
  });
}
