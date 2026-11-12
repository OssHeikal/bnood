import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/features/clients/client_item_spend_rows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clientItemRowFromItemSpend maps split and catalog keys', () {
    final row = clientItemRowFromItemSpend(
      AppClientStatementItemSpend.fromDataJson({
        'id': '01ITEM',
        'name': 'سباكة',
        'spent': 1_300_000,
        'materials': 1_000_000,
        'labor': 300_000,
        'icon_key': 'plumbing',
        'color_key': 'cyan',
      }),
    );
    expect(row.itemId, '01ITEM');
    expect(row.name, 'سباكة');
    expect(row.iconName, 'plumbing');
    expect(row.colorKey, 'cyan');
    expect(row.breakdown.materialsPiastres, 1_000_000);
    expect(row.breakdown.laborPiastres, 300_000);
    expect(row.breakdown.totalPiastres, 1_300_000);
  });
}
