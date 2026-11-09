import 'package:flutter/material.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/entity_picker_row.dart';
import '../../../l10n/app_localizations.dart';
import 'client_balance_card.dart';

class CraftsmanRosterChoiceRow extends StatelessWidget {
  const CraftsmanRosterChoiceRow({
    super.key,
    required this.craftsman,
    required this.selected,
    required this.selectionLocked,
    required this.onToggle,
    required this.showDivider,
    this.onManageAmount,
    this.showAmountSummary = false,
    this.agreedPiastres,
    this.localeCode,
  });

  final CraftsmenData craftsman;
  final bool selected;
  final bool selectionLocked;
  final VoidCallback onToggle;
  final bool showDivider;
  final VoidCallback? onManageAmount;
  final bool showAmountSummary;
  final int? agreedPiastres;
  final String? localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final accent = legacy.AppColors.accent(clientAccentKeyFor(craftsman.id));
    final initial = craftsman.name.isNotEmpty ? craftsman.name.characters.first : '?';
    final trade = craftsman.trade?.trim();
    final subtitle = selectionLocked
        ? l10n.craftsmanAgreementHasPayments
        : (trade != null && trade.isNotEmpty ? trade : l10n.craftsman);

    final locale = localeCode ?? Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        EntityPickerOptionRow(
          selected: selected,
          onSelect: selectionLocked ? () {} : onToggle,
          leadingWidth: 36,
          showDivider: false,
          showSelectionMark: false,
          title: craftsman.name,
          subtitle: Text(subtitle),
          trailing: selected && onManageAmount != null
              ? _AgreedAmountTrailing(
                  showAmountSummary: showAmountSummary,
                  agreedPiastres: agreedPiastres,
                  localeCode: locale,
                  onManageAmount: onManageAmount!,
                )
              : null,
          leading: Material(
            color: accent,
            shape: AppShape.superellipse(radius: 11),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: AppSize.borderWidthHairline,
            indent: EntityPickerOptionRow.dividerStartInset(36),
            endIndent: 0,
            color: colors.outline,
          ),
      ],
    );
  }
}

class _AgreedAmountTrailing extends StatelessWidget {
  const _AgreedAmountTrailing({
    required this.showAmountSummary,
    required this.agreedPiastres,
    required this.localeCode,
    required this.onManageAmount,
  });

  final bool showAmountSummary;
  final int? agreedPiastres;
  final String localeCode;
  final VoidCallback onManageAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final label = showAmountSummary ? l10n.craftsmanEditAgreedAmount : l10n.craftsmanSetAgreedAmount;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.48),
      child: InkWell(
        onTap: onManageAmount,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAmountSummary) ...[
              if (agreedPiastres != null)
                AppAmount(
                  piastres: agreedPiastres!,
                  role: AppAmountRole.neutral,
                  size: AppAmountSize.small,
                  localeCode: localeCode,
                )
              else
                Text(
                  l10n.craftsmanDetailNoAgreedAmount,
                  style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSize.spaceXS),
            ],
            Text(
              label,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.label.copyWith(color: colors.primary, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}
