import '../database/database.dart' show Transaction;
import 'period_bounds.dart';

class SupplierPeriodTotals {
  const SupplierPeriodTotals({
    required this.openingPaidPiastres,
    required this.periodPaidPiastres,
    required this.closingPaidPiastres,
  });

  final int openingPaidPiastres;
  final int periodPaidPiastres;
  final int closingPaidPiastres;
}

/// Supplier statements track **payments** (spend rows linked to supplier).
class SupplierPeriodMath {
  static SupplierPeriodTotals totals({
    required List<Transaction> supplierSpends,
    required PeriodBounds bounds,
  }) {
    var opening = 0;
    var period = 0;
    for (final t in supplierSpends) {
      if (t.kind != 'spend') continue;
      final amount = t.amountPiastres;
      if (bounds.isStrictlyBefore(t.date)) {
        opening += amount;
      } else if (bounds.containsLocalDate(t.date)) {
        period += amount;
      }
    }
    return SupplierPeriodTotals(
      openingPaidPiastres: opening,
      periodPaidPiastres: period,
      closingPaidPiastres: opening + period,
    );
  }
}
