import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../paywall_theme.dart';

class PaywallComparisonTable extends StatelessWidget {
  const PaywallComparisonTable({
    super.key,
    required this.table,
    required this.selectedPackageSlug,
    this.comfortableSheetLayout = false,
  });

  final AppPaywallComparisonTable table;
  final String selectedPackageSlug;
  final bool comfortableSheetLayout;

  static const double _sheetRowMinHeight = 44;

  @override
  Widget build(BuildContext context) {
    final theme = PaywallTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightText = isDark ? const Color(0xFFE4D4FF) : SubscriptionColors.violetDark;
    final highlightBg = isDark
        ? const Color(0xFF2A1D40).withValues(alpha: 0.55)
        : SubscriptionColors.violetSoft.withValues(alpha: 0.55);
    final stripe = isDark ? const Color(0xFF1E1828) : const Color(0xFFF7F4FA);

    if (comfortableSheetLayout) {
      final headerStyle = theme.compareHeader.copyWith(fontSize: 14, height: 1.25, fontWeight: FontWeight.w800);
      final rowLabelStyle = theme.compareRow.copyWith(fontSize: 14.5, height: 1.3, fontWeight: FontWeight.w700);
      final cellStyle = theme.compareCell.copyWith(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(flex: 5, child: SizedBox.shrink()),
                for (final col in table.columns)
                  Expanded(
                    flex: 4,
                    child: _HeaderCell(
                      label: col.name,
                      highlighted: col.slug == selectedPackageSlug,
                      theme: theme,
                      highlightText: highlightText,
                      highlightBg: highlightBg,
                      textStyle: headerStyle,
                      minHeight: _sheetRowMinHeight,
                      comfortable: true,
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: theme.line),
          for (var i = 0; i < table.rows.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                color: i.isOdd ? stripe : Colors.transparent,
                border: Border(bottom: BorderSide(color: theme.line.withValues(alpha: 0.65))),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _RowLabelCell(
                        label: table.rows[i].label,
                        style: rowLabelStyle,
                        minHeight: _sheetRowMinHeight,
                      ),
                    ),
                    for (final col in table.columns)
                      Expanded(
                        flex: 4,
                        child: _ValueCell(
                          value: table.cells[col.slug]?[table.rows[i].key] ?? '—',
                          highlighted: col.slug == selectedPackageSlug,
                          theme: theme,
                          highlightText: highlightText,
                          highlightBg: highlightBg,
                          checkColor:
                              col.slug == selectedPackageSlug ? theme.compareCheckSelected : theme.compareCheck,
                          textStyle: cellStyle,
                          minHeight: _sheetRowMinHeight,
                          comfortable: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Opacity(
      opacity: 0.95,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: const FlexColumnWidth(2),
          for (var i = 0; i < table.columns.length; i++) i + 1: const FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final col in table.columns)
                _HeaderCell(
                  label: col.name,
                  highlighted: col.slug == selectedPackageSlug,
                  theme: theme,
                  highlightText: highlightText,
                  highlightBg: highlightBg,
                  textStyle: theme.compareHeader,
                  minHeight: 32,
                  comfortable: false,
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
                    style: theme.compareRow,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                for (final col in table.columns)
                  _ValueCell(
                    value: table.cells[col.slug]?[row.key] ?? '—',
                    highlighted: col.slug == selectedPackageSlug,
                    theme: theme,
                    highlightText: highlightText,
                    highlightBg: highlightBg,
                    checkColor: col.slug == selectedPackageSlug ? theme.compareCheckSelected : theme.compareCheck,
                    textStyle: theme.compareCell,
                    minHeight: 32,
                    comfortable: false,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RowLabelCell extends StatelessWidget {
  const _RowLabelCell({required this.label, required this.style, required this.minHeight});

  final String label;
  final TextStyle style;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceSM, 10, AppSize.spaceMD, 10),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: style,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
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
    required this.textStyle,
    required this.minHeight,
    required this.comfortable,
  });

  final String label;
  final bool highlighted;
  final PaywallTheme theme;
  final Color highlightText;
  final Color highlightBg;
  final TextStyle textStyle;
  final double minHeight;
  final bool comfortable;

  @override
  Widget build(BuildContext context) {
    return _CellFrame(
      highlighted: highlighted,
      highlightBg: highlightBg,
      minHeight: minHeight,
      comfortable: comfortable,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: comfortable ? 2 : 1,
        softWrap: comfortable,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(color: highlighted ? highlightText : theme.ink),
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
    required this.checkColor,
    required this.textStyle,
    required this.minHeight,
    required this.comfortable,
  });

  final String value;
  final bool highlighted;
  final PaywallTheme theme;
  final Color highlightText;
  final Color highlightBg;
  final Color checkColor;
  final TextStyle textStyle;
  final double minHeight;
  final bool comfortable;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    final isCheck = trimmed == '✓' || trimmed.toLowerCase() == 'yes';
    final isDash = trimmed == '—' || trimmed == '-' || trimmed.isEmpty;

    Widget child;
    if (isCheck) {
      child = Icon(Icons.check_rounded, size: comfortable ? 18 : 13, color: checkColor);
    } else if (isDash) {
      child = Text('—', textAlign: TextAlign.center, style: textStyle);
    } else {
      child = Text(
        DisplayDigits.toWesternDigits(trimmed),
        textAlign: TextAlign.center,
        maxLines: comfortable ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(color: highlighted ? highlightText : theme.muted),
      );
    }

    return _CellFrame(
      highlighted: highlighted,
      highlightBg: highlightBg,
      minHeight: minHeight,
      comfortable: comfortable,
      child: Center(child: child),
    );
  }
}

class _CellFrame extends StatelessWidget {
  const _CellFrame({
    required this.highlighted,
    required this.highlightBg,
    required this.child,
    required this.minHeight,
    required this.comfortable,
  });

  final bool highlighted;
  final Color highlightBg;
  final Widget child;
  final double minHeight;
  final bool comfortable;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: comfortable ? 6 : 2,
          horizontal: comfortable ? AppSize.spaceXS : 1,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: highlighted ? highlightBg : Colors.transparent,
            borderRadius: BorderRadius.circular(comfortable ? 8 : 6),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: comfortable ? 8 : 4, horizontal: comfortable ? 6 : 2),
            child: child,
          ),
        ),
      ),
    );
  }
}