import 'package:flutter/material.dart';

import '../../../core/formatting/display_digits.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../paywall_theme.dart';

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
    final theme = PaywallTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightText = isDark ? const Color(0xFFE4D4FF) : SubscriptionColors.violetDark;
    final highlightBg = isDark
        ? const Color(0xFF2A1D40).withValues(alpha: 0.45)
        : SubscriptionColors.violetSoft.withValues(alpha: 0.4);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final planColumns = isRtl ? table.columns.reversed.toList() : table.columns;

    return Opacity(
      opacity: 0.95,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: const FlexColumnWidth(1.6),
          for (var i = 0; i < planColumns.length; i++) i + 1: const FlexColumnWidth(),
        },
        children: [
          _headerRow(
            planColumns: planColumns,
            labelAtEnd: isRtl,
            theme: theme,
            highlightText: highlightText,
            highlightBg: highlightBg,
          ),
          for (final row in table.rows)
            _valueRow(
              row: row,
              planColumns: planColumns,
              labelAtEnd: isRtl,
              theme: theme,
              highlightText: highlightText,
              highlightBg: highlightBg,
            ),
        ],
      ),
    );
  }

  TableRow _headerRow({
    required List<AppPaywallComparisonColumn> planColumns,
    required bool labelAtEnd,
    required PaywallTheme theme,
    required Color highlightText,
    required Color highlightBg,
  }) {
    final planCells = planColumns
        .map(
          (col) => _HeaderCell(
            label: col.name,
            highlighted: col.slug == selectedPackageSlug,
            theme: theme,
            highlightText: highlightText,
            highlightBg: highlightBg,
          ),
        )
        .toList();

    return TableRow(
      children: labelAtEnd
          ? [...planCells, const SizedBox.shrink()]
          : [const SizedBox.shrink(), ...planCells],
    );
  }

  TableRow _valueRow({
    required AppPaywallComparisonRow row,
    required List<AppPaywallComparisonColumn> planColumns,
    required bool labelAtEnd,
    required PaywallTheme theme,
    required Color highlightText,
    required Color highlightBg,
  }) {
    final label = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(row.label, style: theme.compareRow, textAlign: TextAlign.start),
    );

    final planCells = planColumns
        .map(
          (col) => _ValueCell(
            value: table.cells[col.slug]?[row.key] ?? '—',
            highlighted: col.slug == selectedPackageSlug,
            theme: theme,
            highlightText: highlightText,
            highlightBg: highlightBg,
          ),
        )
        .toList();

    return TableRow(
      children: labelAtEnd ? [...planCells, label] : [label, ...planCells],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.highlighted,
    required this.theme,
    required this.highlightText,
    required this.highlightBg,
  });

  final String label;
  final bool highlighted;
  final PaywallTheme theme;
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
        style: theme.compareHeader.copyWith(color: highlighted ? highlightText : theme.ink),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.value,
    required this.highlighted,
    required this.theme,
    required this.highlightText,
    required this.highlightBg,
  });

  final String value;
  final bool highlighted;
  final PaywallTheme theme;
  final Color highlightText;
  final Color highlightBg;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    final isCheck = trimmed == '✓' || trimmed.toLowerCase() == 'yes';
    final isDash = trimmed == '—' || trimmed == '-' || trimmed.isEmpty;

    Widget child;
    if (isCheck) {
      child = Icon(
        Icons.check_rounded,
        size: 13,
        color: highlighted ? highlightText : SubscriptionColors.violet.withValues(alpha: 0.85),
      );
    } else if (isDash) {
      child = Text('—', textAlign: TextAlign.center, style: theme.compareCell);
    } else {
      child = Text(
        DisplayDigits.toWesternDigits(trimmed),
        textAlign: TextAlign.center,
        style: theme.compareCell.copyWith(color: highlighted ? highlightText : theme.muted),
      );
    }

    return _CellFrame(
      highlighted: highlighted,
      highlightBg: highlightBg,
      child: Center(child: child),
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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: child,
        ),
      ),
    );
  }
}