import '../../core/database/database.dart';
import 'client_detail_snapshot.dart';

typedef MovementEntityMaps = ({
  Map<String, Item> itemById,
  Map<String, Supplier> supplierById,
  Map<String, CraftsmenData> craftsmanById,
});

ClientDetailMovementLine movementLineFromTransaction(
  Transaction t, {
  required Map<String, Item> itemById,
  required Map<String, Supplier> supplierById,
  required Map<String, CraftsmenData> craftsmanById,
}) {
  final item = t.itemId != null ? itemById[t.itemId] : null;
  String? payeeName;
  bool? payeeIsSupplier;
  if (t.supplierId != null) {
    payeeName = supplierById[t.supplierId]?.name;
    payeeIsSupplier = true;
  } else if (t.craftsmanId != null) {
    payeeName = craftsmanById[t.craftsmanId]?.name;
    payeeIsSupplier = false;
  }
  return ClientDetailMovementLine(
    transaction: t,
    itemName: item?.name,
    payeeName: payeeName,
    payeeIsSupplier: payeeIsSupplier,
  );
}

List<ClientDetailMovementLine> movementLinesFromTransactions(
  List<Transaction> transactions, {
  required Map<String, Item> itemById,
  required Map<String, Supplier> supplierById,
  required Map<String, CraftsmenData> craftsmanById,
}) {
  return transactions
      .map(
        (t) => movementLineFromTransaction(
          t,
          itemById: itemById,
          supplierById: supplierById,
          craftsmanById: craftsmanById,
        ),
      )
      .toList();
}
