import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/money/period_bounds.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pressable.dart';
import 'statement_export_store.dart';
import 'statement_period_logic.dart';

typedef PeriodChanged = void Function(PeriodBounds bounds, StatementPeriodPreset preset);

class StatementPeriodControls extends StatelessWidget {
  const StatementPeriodControls({
    super.key,
    required this.bounds,
    required this.preset,
    required this.onChanged,
    required this.lastExport,
    this.sinceLastExportAvailable = false,
  });

  final PeriodBounds bounds;
  final StatementPeriodPreset preset;
  final PeriodChanged onChanged;
  final StatementExportRecord? lastExport;
  final bool sinceLastExportAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final fmt = DateFormat.yMMMd(locale);
    final colors = context.colors;
    final text = context.text;
    final rangeLabel = StatementPeriodLogic.formatPeriodRangeLabel(bounds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSize.spaceSM,
          runSpacing: AppSize.spaceSM,
          children: [
            _chip(context, l10n.statementPeriodToday, StatementPeriodPreset.today),
            _chip(context, l10n.statementPeriodMonth, StatementPeriodPreset.month),
            _chip(context, l10n.statementPeriodAll, StatementPeriodPreset.all),
            _chip(
              context,
              l10n.statementPeriodSinceLastExport,
              StatementPeriodPreset.sinceLastExport,
              enabled: sinceLastExportAvailable,
            ),
            _chip(context, l10n.statementPeriodCustomize, StatementPeriodPreset.custom),
          ],
        ),
        const SizedBox(height: AppSize.spaceSM),
        Text(
          l10n.statementPeriodDisplay(rangeLabel),
          style: text.supporting.copyWith(color: colors.onSurfaceMuted),
        ),
        if (!sinceLastExportAvailable && preset == StatementPeriodPreset.sinceLastExport) ...[
          const SizedBox(height: AppSize.spaceXS),
          Text(
            l10n.statementSinceLastExportUnavailable,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
        if (lastExport != null) ...[
          const SizedBox(height: AppSize.spaceXS),
          Text(
            l10n.statementLastExportAt(fmt.format(lastExport!.exportedAt)),
            style: text.caption,
          ),
        ],
        const SizedBox(height: AppSize.spaceXS),
        Text(
          l10n.statementPeriodDatesHint,
          style: text.caption.copyWith(color: colors.onSurfaceMuted),
        ),
        if (preset == StatementPeriodPreset.custom) ...[
          const SizedBox(height: AppSize.spaceMD),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceSM),
            child: Column(
              children: [
                _compactDateRow(
                  context,
                  label: l10n.statementPeriodFrom,
                  date: bounds.start,
                  onTap: () => _pick(context, initial: bounds.start, onPicked: (d) {
                    onChanged(PeriodBounds.normalize(start: d, end: bounds.end), StatementPeriodPreset.custom);
                  }),
                ),
                Divider(height: 1, color: colors.outlineSubtle),
                _compactDateRow(
                  context,
                  label: l10n.statementPeriodTo,
                  date: bounds.end,
                  onTap: () => _pick(context, initial: bounds.end, onPicked: (d) {
                    onChanged(PeriodBounds.normalize(start: bounds.start, end: d), StatementPeriodPreset.custom);
                  }),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    StatementPeriodPreset value, {
    bool enabled = true,
  }) {
    final selected = preset == value;
    final colors = context.colors;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: colors.primaryTint,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: enabled ? colors.onSurface : colors.onSurfaceMuted,
      ),
      onSelected: enabled
          ? (_) => onChanged(bounds, value)
          : null,
    );
  }

  Future<void> _pick(
    BuildContext context, {
    required DateTime initial,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context).period,
    );
    if (picked != null) onPicked(picked);
  }

  Widget _compactDateRow(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final text = context.text;
    return AppPressable(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
        child: Row(
          children: [
            Text(label, style: text.label),
            const Spacer(),
            Text(fmt.format(date), style: text.bodyEmphasis),
            const SizedBox(width: AppSize.spaceSM),
            Icon(Icons.calendar_today, size: AppSize.iconCompact, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}
