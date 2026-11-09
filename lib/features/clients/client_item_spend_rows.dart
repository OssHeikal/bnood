import '../../core/clients/client_statement_record.dart';
import '../../core/money/ledger_math.dart';
import 'client_detail_snapshot.dart';

ClientDetailItemRowData clientItemRowFromItemSpend(AppClientStatementItemSpend item) {
  return ClientDetailItemRowData(
    itemId: item.id,
    name: item.name,
    colorKey: item.colorKey,
    iconName: item.iconKey,
    breakdown: ItemExpenseBreakdown(
      materialsPiastres: item.materialsMinor,
      laborPiastres: item.laborMinor,
    ),
  );
}

List<ClientDetailItemRowData> clientItemRowsFromItemSpend(Iterable<AppClientStatementItemSpend> items) {
  return items.map(clientItemRowFromItemSpend).toList();
}
