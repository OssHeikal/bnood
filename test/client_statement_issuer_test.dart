import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppClientStatement.fromDataJson parses issuer', () {
    final statement = AppClientStatement.fromDataJson({
      'from': '2025-01-01',
      'to': '2025-12-31',
      'opening_balance': 0,
      'received': 0,
      'spent': 0,
      'closing_balance': 0,
      'items': [],
      'issuer': {
        'name': 'Statement Owner',
        'logo_url': 'https://cdn/logo.png',
        'contact_phone': '+201033334444',
      },
    });
    expect(statement.issuer?.name, 'Statement Owner');
    expect(statement.issuer?.logoUrl, 'https://cdn/logo.png');
    expect(statement.issuer?.contactPhone, '+201033334444');
  });
}
