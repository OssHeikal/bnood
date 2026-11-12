import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('User.fromJson parses contact_phone and logo_url', () {
    final user = User.fromJson({
      'id': 'u1',
      'phone': '+201012345678',
      'name': 'Owner',
      'phone_verified_at': '2025-01-01T00:00:00Z',
      'contact_phone': '+201022223333',
      'logo_url': 'https://cdn.example/logo.png',
    });
    expect(user.contactPhone, '+201022223333');
    expect(user.logoUrl, 'https://cdn.example/logo.png');
  });

  test('User.fromJson accepts null branding fields', () {
    final user = User.fromJson({
      'id': 'u1',
      'phone': '+201012345678',
      'name': null,
      'phone_verified_at': null,
      'contact_phone': null,
      'logo_url': null,
    });
    expect(user.contactPhone, isNull);
    expect(user.logoUrl, isNull);
  });
}
