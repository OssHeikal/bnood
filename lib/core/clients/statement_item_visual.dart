import '../items/item_api_record.dart';
import 'client_statement_record.dart';

/// Default item tile keys when API and catalog omit visuals (matches [CatalogItem.fromDataJson]).
const statementItemDefaultIconKey = 'layers';
const statementItemDefaultColorKey = 'teal';

class StatementItemVisual {
  const StatementItemVisual({required this.iconKey, required this.colorKey});

  final String iconKey;
  final String colorKey;
}

String? readOptionalCatalogString(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

/// Resolves icon/color: statement payload → items catalog by [AppClientStatementItemSpend.id] → defaults.
StatementItemVisual resolveStatementItemVisual(
  AppClientStatementItemSpend item, {
  Map<String, CatalogItem>? catalogById,
}) {
  final catalog = catalogById?[item.id];
  final iconKey = item.iconKey ?? catalog?.iconKey ?? statementItemDefaultIconKey;
  final colorKey = item.colorKey ?? catalog?.colorKey ?? statementItemDefaultColorKey;
  return StatementItemVisual(iconKey: iconKey, colorKey: colorKey);
}

Map<String, CatalogItem> catalogItemsById(Iterable<CatalogItem> items) {
  return {for (final item in items) item.id: item};
}
