import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../client_movements_filters.dart';

class ClientMovementsFilterBar extends StatelessWidget {
  const ClientMovementsFilterBar({
    super.key,
    required this.searchController,
    required this.filters,
    required this.onOpenSort,
    required this.onOpenItem,
    required this.onOpenDate,
    required this.onClearAll,
    this.onClearSort,
    this.onClearItem,
    this.onClearDate,
  });

  final TextEditingController searchController;
  final ClientMovementsFilters filters;
  final VoidCallback onOpenSort;
  final VoidCallback onOpenItem;
  final VoidCallback onOpenDate;
  final VoidCallback onClearAll;
  final VoidCallback? onClearSort;
  final VoidCallback? onClearItem;
  final VoidCallback? onClearDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.yMMMd(locale);

    final sortLabel =
        filters.sort == ClientMovementsSort.dateAsc ? l10n.movementsSortOldest : l10n.movementsSortNewest;
    final itemLabel = filters.hasItemFilter ? (filters.itemName ?? l10n.movementsFilterItem) : l10n.movementsFilterItem;
    final dateLabel = _dateChipLabel(l10n, dateFmt, filters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField.search(
          controller: searchController,
          placeholder: l10n.movementsSearchHint,
        ),
        AppSize.spaceSM.gap,
        Wrap(
          spacing: AppSize.spaceSM,
          runSpacing: AppSize.spaceSM,
          children: [
            _FilterChip(
              label: sortLabel,
              applied: filters.hasNonDefaultSort,
              onTap: onOpenSort,
              onClear: filters.hasNonDefaultSort ? onClearSort : null,
            ),
            _FilterChip(
              label: itemLabel,
              applied: filters.hasItemFilter,
              onTap: onOpenItem,
              onClear: filters.hasItemFilter ? onClearItem : null,
            ),
            _FilterChip(
              label: dateLabel,
              applied: filters.hasDateFilter,
              onTap: onOpenDate,
              onClear: filters.hasDateFilter ? onClearDate : null,
            ),
          ],
        ),
        if (filters.hasAnyFilter) ...[
          AppSize.spaceSM.gap,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppPressable(
              onPressed: onClearAll,
              child: Text(
                l10n.movementsClearFilters,
                style: context.text.bodyEmphasis.copyWith(color: context.colors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _dateChipLabel(AppLocalizations l10n, DateFormat fmt, ClientMovementsFilters filters) {
    if (!filters.hasDateFilter) return l10n.movementsFilterDate;
    final from = filters.from;
    final to = filters.to;
    if (from != null && to != null) {
      return l10n.movementsDateRangeSummary(fmt.format(from), fmt.format(to));
    }
    if (from != null) return '${l10n.movementsDateFrom} ${fmt.format(from)}';
    if (to != null) return '${l10n.movementsDateTo} ${fmt.format(to)}';
    return l10n.movementsFilterDate;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.applied,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool applied;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Material(
      color: applied ? colors.primary : colors.surface,
      shape: AppShape.superellipse(radius: AppSize.radiusSM),
      clipBehavior: Clip.antiAlias,
      child: AppPressable(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.buttonHeightSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: text.bodyEmphasis.copyWith(
                      color: applied ? colors.onPrimary : colors.onSurfaceMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (applied && onClear != null) ...[
                  const SizedBox(width: AppSize.spaceXS),
                  AppPressable(
                    onPressed: onClear,
                    child: Icon(Icons.close, size: 16, color: applied ? colors.onPrimary : colors.onSurfaceMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
