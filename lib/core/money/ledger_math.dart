import '../database/database.dart';

class ProjectBalance {
  const ProjectBalance({
    required this.receivedPiastres,
    required this.spentPiastres,
  });

  final int receivedPiastres;
  final int spentPiastres;

  int get balancePiastres => receivedPiastres - spentPiastres;
}

class StatementPeriodTotals {
  const StatementPeriodTotals({
    required this.openingBalancePiastres,
    required this.periodReceivedPiastres,
    required this.periodSpentPiastres,
    required this.closingBalancePiastres,
    required this.materialsPiastres,
    required this.laborPiastres,
  });

  final int openingBalancePiastres;
  final int periodReceivedPiastres;
  final int periodSpentPiastres;
  final int closingBalancePiastres;
  final int materialsPiastres;
  final int laborPiastres;
}

class LedgerMath {
  static ProjectBalance projectBalance(Iterable<Transaction> rows) {
    var received = 0;
    var spent = 0;
    for (final t in rows) {
      if (t.kind == 'receive') {
        received += t.amountPiastres;
      } else if (t.kind == 'spend') {
        spent += t.amountPiastres;
      }
    }
    return ProjectBalance(receivedPiastres: received, spentPiastres: spent);
  }

  static int craftsmanPaidPiastres({
    required Iterable<Transaction> rows,
    required String craftsmanId,
  }) {
    return rows
        .where((t) =>
            t.kind == 'spend' &&
            t.expenseType == 'labor' &&
            t.craftsmanId == craftsmanId)
        .fold<int>(0, (sum, t) => sum + t.amountPiastres);
  }

  static int? craftsmanRemainingPiastres({
    required int? initialAmountPiastres,
    required int paidPiastres,
  }) {
    if (initialAmountPiastres == null) return null;
    return initialAmountPiastres - paidPiastres;
  }

  static StatementPeriodTotals periodTotals({
    required List<Transaction> projectRows,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final start =
        DateTime(periodStart.year, periodStart.month, periodStart.day);
    final end = DateTime(
        periodEnd.year, periodEnd.month, periodEnd.day, 23, 59, 59, 999);

    int beforeReceive = 0;
    int beforeSpend = 0;
    int periodReceive = 0;
    int periodSpend = 0;
    int materials = 0;
    int labor = 0;

    for (final t in projectRows) {
      final d = t.date;
      final isBefore = d.isBefore(start);
      final inPeriod = !d.isBefore(start) && !d.isAfter(end);
      if (t.kind == 'receive') {
        if (isBefore) {
          beforeReceive += t.amountPiastres;
        } else if (inPeriod) {
          periodReceive += t.amountPiastres;
        }
      } else if (t.kind == 'spend') {
        if (isBefore) {
          beforeSpend += t.amountPiastres;
        } else if (inPeriod) {
          periodSpend += t.amountPiastres;
          if (t.expenseType == 'materials') materials += t.amountPiastres;
          if (t.expenseType == 'labor') labor += t.amountPiastres;
        }
      }
    }

    final opening = beforeReceive - beforeSpend;
    final closing = opening + periodReceive - periodSpend;
    return StatementPeriodTotals(
      openingBalancePiastres: opening,
      periodReceivedPiastres: periodReceive,
      periodSpentPiastres: periodSpend,
      closingBalancePiastres: closing,
      materialsPiastres: materials,
      laborPiastres: labor,
    );
  }

  static Map<String, ItemExpenseBreakdown> itemBreakdown(
      Iterable<Transaction> spendRows) {
    final map = <String, ItemExpenseBreakdown>{};
    for (final t in spendRows) {
      final itemId = t.itemId;
      if (itemId == null) continue;
      final existing = map[itemId] ?? const ItemExpenseBreakdown();
      map[itemId] = ItemExpenseBreakdown(
        materialsPiastres: existing.materialsPiastres +
            (t.expenseType == 'materials' ? t.amountPiastres : 0),
        laborPiastres: existing.laborPiastres +
            (t.expenseType == 'labor' ? t.amountPiastres : 0),
      );
    }
    return map;
  }
}

class ItemExpenseBreakdown {
  const ItemExpenseBreakdown({
    this.materialsPiastres = 0,
    this.laborPiastres = 0,
  });

  final int materialsPiastres;
  final int laborPiastres;

  int get totalPiastres => materialsPiastres + laborPiastres;
}
