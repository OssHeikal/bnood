import 'package:flutter/material.dart';

import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';

class PaywallComparisonTable extends StatelessWidget {
  const PaywallComparisonTable({
    super.key,
    required this.table,
    required this.selectedPackageSlug,
  });

  final AppPaywallComparisonTable table;
  final String selectedPackageSlug;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? const Color(0xFFF3EEF8) : const Color(0xFF1C1722);
    final muted = isDark ? const Color(0xFFA59EAF) : const Color(0xFF6F6878);
    final highlightText = isDark ? const Color(0xFFE4D4FF) : SubscriptionColors.violetDark;
    final highlightBg = isDark ? const Color(0xFF2A1D40) : SubscriptionColors.violetSoft;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const FlexColumnWidth(1.6),
        for (var i = 0; i < table.columns.length; i++) i + 1: const FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            for (final col in table.columns) _HeaderCell(
              label: col.name,
              highlighted: col.slug == selectedPackageSlug,
              ink: ink,
              highlightText: highlightText,
              highlightBg: highlightBg,
            ),
          ],
        ),
        for (final row in table.rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  row.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted),
                  textAlign: TextAlign.start,
                ),
              ),
              for (final col in table.columns)
                _ValueCell(
                  value: table.cells[col.slug]?[row.key] ?? '—',
                  highlighted: col.slug == selectedPackageSlug,
                  muted: muted,
                  highlightText: highlightText,
                  highlightBg: highlightBg,
                ),
            ],
          ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.highlighted,
    required this.ink,
    required this.highlightText,
    required this.highlightBg,
  });

  final String label;
  final bool highlighted;
  final Color ink;
  final Color highlightText;
  final Color highlightBg;

  @override
  Widget build(BuildContext context) {
    return _CellFrame(
      highlighted: highlighted,
      highlightBg: highlightBg,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: highlighted ? highlightText : ink,
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.value,
    required this.highlighted,
    required this.muted,
    required this.highlightText,
    required this.highlightBg,
  });

  final String value;
  final bool highlighted;
  final Color muted;
  final Color highlightText;
  final Color highlightBg;

  @override
  Widget build(BuildContext context) {
    return _CellFrame(
      highlighted: highlighted,
      highlightBg: highlightBg,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: highlighted ? highlightText : muted,
        ),
      ),
    );
  }
}

class _CellFrame extends StatelessWidget {
  const _CellFrame({required this.highlighted, required this.highlightBg, required this.child});

  final bool highlighted;
  final Color highlightBg;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlighted ? highlightBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: child,
        ),
      ),
    );
  }
}