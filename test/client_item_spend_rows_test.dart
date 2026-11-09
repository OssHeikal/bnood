import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/features/clients/client_item_spend_rows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clientItemRowFromItemSpend maps split and catalog keys', () {
    final row = clientItemRowFromItemSpend(
      AppClientStatementItemSpend.fromDataJson({
        'id': '01ITEM',
        'name': 'سباكة',
        'spent': 13_000_000,
        'materials': 10_000_000,
        'labor': 3_000_000,
        'icon_key': 'plumbing',
        'color_key': 'cyan',
      }),
    );
    expect(row.itemId, '01ITEM');
    expect(row.name, 'سباكة');
    expect(row.iconName, 'plumbing');
    expect(row.colorKey, 'cyan');
    expect(row.breakdown.materialsPiastres, 10_000_000);
    expect(row.breakdown.laborPiastres, 3_000_000);
    expect(row.breakdown.totalPiastres, 13_000_000);
  });
}
