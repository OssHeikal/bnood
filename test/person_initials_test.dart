import 'package:bnood/core/domain/formatting/person_initials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('latin two words use first and last initials', () {
    expect(personInitials('Osama heikal'), 'OH');
    expect(personInitials('osama HEIKAL'), 'OH');
    expect(personInitials('Osama heikal middle'), 'OM');
  });

  test('single word uses first letter', () {
    expect(personInitials('Osama'), 'O');
  });

  test('empty name is em dash', () {
    expect(personInitials(''), '—');
    expect(personInitials(null), '—');
  });

  test('strips honorific prefixes for arabic names', () {
    expect(
      personInitials('أ/ سارة محمود'),
      'س${officeInitialsSeparator}م',
    );
    expect(personInitials('م. أحمد علي'), 'ا$officeInitialsSeparatorع');
  });

  test('arabic single word after prefix strip', () {
    expect(personInitials('د/ مصطفى'), 'م');
  });
}