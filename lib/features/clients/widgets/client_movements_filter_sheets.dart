import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/clients/client_statement_record.dart';
import '../../../core/clients/statement_item_visual.dart';
import '../../../core/items/item_api_record.dart';
import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/widgets/app_fallback.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../core/widgets/bounded_sheet_navigator.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/custom_bottom_sheet.dart';
import '../../../core/widgets/sheet_drag_handle.dart';
import '../../items/item_semantic_icon.dart';
import '../../vouchers/voucher_date_sheet.dart';
import '../../vouchers/voucher_transaction_date_bounds.dart';
import '../client_movements_filters.dart';

void _closeSheet<T>(BuildContext context, T value) {
  Navigator.of(context).pop(value);
}

Future<T?> _showMovementsFilterSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder body,
}) {
  return CustomBottomSheet.show<T>(
    context: context,
    title: null,
    nestedNavigator: false,
    builder: (ctx) => _MovementsFilterSheetScaffold(title: title, child: body(ctx)),
  );
}

class _MovementsFilterSheetScaffold extends StatelessWidget {
  const _MovementsFilterSheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: AppSize.spaceSM),
            child: SheetDragHandle(),
          ),
          AppSize.spaceMD.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: Text(title, style: text.title),
          ),
          AppSize.spaceMD.gap,
          child,
        ],
    );
  }
}

Future<ClientMovementsSort?> showMovementsSortSheet(
  BuildContext context, {
  required ClientMovementsSort current,
}) {
  final l10n = AppLocalizations.of(context);
  return _showMovementsFilterSheet<ClientMovementsSort>(
    context,
    title: l10n.movementsFilterSort,
    body: (ctx) => _SortSheetBody(current: current),
  );
}

class _SortSheetBody extends StatelessWidget {
  const _SortSheetBody({required this.current});

  final ClientMovementsSort current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _FilterOptionsList(
      children: [
        _FilterSheetOption(
          label: l10n.movementsSortNewest,
          selected: current == ClientMovementsSort.dateDesc,
          onTap: () => _closeSheet(context, ClientMovementsSort.dateDesc),
        ),
        _FilterSheetOption(
          label: l10n.movementsSortOldest,
          selected: current == ClientMovementsSort.dateAsc,
          onTap: () => _closeSheet(context, ClientMovementsSort.dateAsc),
        ),
        if (current != ClientMovementsSort.dateDesc) ...[
          AppSize.spaceMD.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppButton(
              text: l10n.movementsClearFilter,
              style: AppButtonStyle.text,
              onPressed: () => _closeSheet(context, ClientMovementsSort.dateDesc),
            ),
          ),
        ],
        AppSize.spaceMD.gap,
      ],
    );
  }
}

class MovementsItemPickResult {
  const MovementsItemPickResult({this.itemId, this.itemName});

  final String? itemId;
  final String? itemName;
}

Future<MovementsItemPickResult?> showMovementsItemSheet(
  BuildContext context, {
  required List<AppClientStatementItemSpend> items,
  String? currentItemId,
}) {
  final l10n = AppLocalizations.of(context);
  return _showMovementsFilterSheet<MovementsItemPickResult>(
    context,
    title: l10n.movementsFilterItem,
    body: (ctx) => _ItemSheetBody(items: items, currentItemId: currentItemId),
  );
}

class _ItemSheetBody extends StatelessWidget {
  const _ItemSheetBody({required this.items, this.currentItemId});

  final List<AppClientStatementItemSpend> items;
  final String? currentItemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        child: AppFallback.section(
          icon: Icons.inventory_2_outlined,
          title: l10n.clientDetailNoItemSpend,
        ),
      );
    }

    return _FilterOptionsList(
      children: [
        _FilterSheetOption(
          label: l10n.movementsFilterAllItems,
          selected: currentItemId == null,
          onTap: () => _closeSheet(context, const MovementsItemPickResult()),
        ),
        for (final item in items)
          _FilterSheetOption(
            label: item.name,
            selected: currentItemId == item.id,
            leading: _ItemFilterIcon.fromItemSpend(item),
            onTap: () => _closeSheet(
              context,
              MovementsItemPickResult(itemId: item.id, itemName: item.name),
            ),
          ),
        if (currentItemId != null) ...[
          AppSize.spaceMD.gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: AppButton(
              text: l10n.movementsClearFilter,
              style: AppButtonStyle.text,
              onPressed: () => _closeSheet(context, const MovementsItemPickResult()),
            ),
          ),
        ],
        AppSize.spaceMD.gap,
      ],
    );
  }
}

class _ItemFilterIcon extends StatelessWidget {
  const _ItemFilterIcon({required this.iconKey, required this.colorKey});

  factory _ItemFilterIcon.fromItemSpend(AppClientStatementItemSpend item, {Map<String, CatalogItem>? catalogById}) {
    final visual = resolveStatementItemVisual(item, catalogById: catalogById);
    return _ItemFilterIcon(iconKey: visual.iconKey, colorKey: visual.colorKey);
  }

  final String iconKey;
  final String colorKey;

  @override
  Widget build(BuildContext context) {
    final accent = itemSemanticAccentColor(colorKey);
    return Material(
      color: accent.withValues(alpha: 0.15),
      shape: AppShape.superellipse(radius: AppSize.radiusSM),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: AppSize.statIconBox,
        height: AppSize.statIconBox,
        child: Center(
          child: itemSemanticIconWidget(
            iconKey: iconKey,
            color: accent,
            size: AppSize.iconSmall,
          ),
        ),
      ),
    );
  }
}

class MovementsDatePickResult {
  const MovementsDatePickResult({this.from, this.to});

  final DateTime? from;
  final DateTime? to;
}

Future<MovementsDatePickResult?> showMovementsDateSheet(
  BuildContext context, {
  DateTime? from,
  DateTime? to,
}) {
  final l10n = AppLocalizations.of(context);
  return _showMovementsFilterSheet<MovementsDatePickResult>(
    context,
    title: l10n.movementsFilterDate,
    body: (ctx) => _DateSheetBody(initialFrom: from, initialTo: to),
  );
}

class _DateSheetBody extends StatefulWidget {
  const _DateSheetBody({this.initialFrom, this.initialTo});

  final DateTime? initialFrom;
  final DateTime? initialTo;

  @override
  State<_DateSheetBody> createState() => _DateSheetBodyState();
}

class _DateSheetBodyState extends State<_DateSheetBody> {
  late DateTime? _from = widget.initialFrom;
  late DateTime? _to = widget.initialTo ?? widget.initialFrom;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickFrom() async {
    final last = VoucherTransactionDateBounds.last;
    final cap = _to != null ? _dateOnly(_to!) : last;
    final effectiveLast = cap.isBefore(last) ? cap : last;
    final picked = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VoucherDateSheetPage(
          initial: _from ?? _to ?? effectiveLast,
          firstDate: VoucherTransactionDateBounds.first,
          lastDate: effectiveLast,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _from = picked;
      if (_to != null && _dateOnly(_to!).isBefore(_dateOnly(picked))) {
        _to = picked;
      }
    });
  }

  Future<void> _pickTo() async {
    final first = VoucherTransactionDateBounds.first;
    final floor = _from != null ? _dateOnly(_from!) : first;
    final effectiveFirst = floor.isAfter(first) ? floor : first;
    final picked = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VoucherDateSheetPage(
          initial: _to ?? _from ?? VoucherTransactionDateBounds.last,
          firstDate: effectiveFirst,
          lastDate: VoucherTransactionDateBounds.last,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _to = picked;
      if (_from != null && _dateOnly(_from!).isAfter(_dateOnly(picked))) {
        _from = picked;
      }
    });
  }

  String _formatDay(DateTime? day, String localeCode, String placeholder) {
    if (day == null) return placeholder;
    final raw = DateFormat.yMMMd(localeCode).format(day);
    return DisplayDigits.toWesternDigits(raw);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateRow(
            label: l10n.movementsDateFrom,
            value: _formatDay(_from, localeCode, l10n.date),
            onTap: _pickFrom,
          ),
          AppSize.spaceSM.gap,
          _DateRow(
            label: l10n.movementsDateTo,
            value: _formatDay(_to, localeCode, l10n.date),
            onTap: _pickTo,
          ),
          AppSize.spaceMD.gap,
          AppButton(
            text: l10n.save,
            onPressed: () => _closeSheet(context, MovementsDatePickResult(from: _from, to: _to)),
          ),
          if (_from != null || _to != null) ...[
            AppSize.spaceSM.gap,
            AppButton(
              text: l10n.movementsClearFilter,
              style: AppButtonStyle.text,
              onPressed: () => _closeSheet(context, const MovementsDatePickResult()),
            ),
          ],
          AppSize.spaceLG.gap,
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Material(
      color: colors.surfaceSunken,
      shape: AppShape.superellipse(radius: AppSize.radiusSM),
      clipBehavior: Clip.antiAlias,
      child: AppPressable(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSize.spaceMD,
            vertical: AppSize.spaceMD,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(label, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                    AppSize.spaceXS.gap,
                    Text(value, style: text.bodyEmphasis),
                  ],
                ),
              ),
              Icon(Icons.calendar_today_outlined, size: AppSize.iconCompact, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOptionsList extends StatelessWidget {
  const _FilterOptionsList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxHeight = SheetContentBounds.viewportCap(MediaQuery.of(context)) * 0.55;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
        children: children,
      ),
    );
  }
}

class _FilterSheetOption extends StatelessWidget {
  const _FilterSheetOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.spaceSM),
      child: AppPressable(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceMD),
          decoration: BoxDecoration(
            color: selected ? colors.primaryTint : colors.surface,
            borderRadius: BorderRadius.circular(AppSize.radiusSM),
            border: Border.all(
              color: selected ? colors.primary.withValues(alpha: 0.35) : colors.outlineSubtle,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSize.spaceMD),
              ],
              Expanded(
                child: Text(
                  label,
                  style: text.bodyEmphasis.copyWith(
                    color: selected ? colors.primaryOnTint : colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: colors.primary, size: AppSize.iconCompact),
            ],
          ),
        ),
      ),
    );
  }
}
