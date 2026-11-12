import 'package:bnood/core/formatting/person_initials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('capitalizes latin initials from two words', () {
    expect(personInitials('Osama heikal'), 'OH');
    expect(personInitials('osama HEIKAL'), 'OH');
  });

  test('single word uses first letter', () {
    expect(personInitials('Osama'), 'O');
  });

  test('empty name is question mark', () {
    expect(personInitials(''), '?');
    expect(personInitials(null), '?');
  });
}
