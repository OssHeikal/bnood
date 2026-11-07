import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/buttons/app_button.dart';
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
          title: craftsman.name,
          subtitle: Text(subtitle),
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
        if (selected && onManageAmount != null) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSize.screenPadding,
              end: AppSize.screenPadding,
              bottom: AppSize.spaceMD,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showAmountSummary) ...[
                  if (agreedPiastres != null)
                    AppAmount(
                      piastres: agreedPiastres!,
                      role: AppAmountRole.neutral,
                      size: AppAmountSize.small,
                      localeCode: locale,
                    )
                  else
                    Text(
                      l10n.craftsmanDetailNoAgreedAmount,
                      style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                    ),
                  AppSize.spaceXS.gap,
                ],
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppButton.text(
                    text: showAmountSummary
                        ? l10n.craftsmanEditAgreedAmount
                        : l10n.craftsmanSetAgreedAmount,
                    onPressed: onManageAmount,
                  ),
                ),
              ],
            ),
          ),
        ],
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
