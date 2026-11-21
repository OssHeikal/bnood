import 'package:bnood/features/clients/data/client_statement_record.dart';
import 'package:bnood/features/clients/data/statement_item_visual.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import '../../../../core/money/ledger_math.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';

ClientDetailItemRowData clientItemRowFromItemSpend(
  AppClientStatementItemSpend item, {
  Map<String, CatalogItem>? catalogById,
}) {
  final visual = resolveStatementItemVisual(item, catalogById: catalogById);
  return ClientDetailItemRowData(
    itemId: item.id,
    name: item.name,
    colorKey: visual.colorKey,
    iconName: visual.iconKey,
    breakdown: ItemExpenseBreakdown(
      materialsPiastres: item.materialsMinor,
      laborPiastres: item.laborMinor,
    ),
  );
}

List<ClientDetailItemRowData> clientItemRowsFromItemSpend(
  Iterable<AppClientStatementItemSpend> items,
) {
  return items.map(clientItemRowFromItemSpend).toList();
}
