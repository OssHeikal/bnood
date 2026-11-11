import 'package:flutter/material.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/entity_picker_row.dart';
import 'client_balance_card.dart';

class ClientRosterChoiceRow extends StatelessWidget {
  const ClientRosterChoiceRow({
    super.key,
    required this.clientId,
    required this.name,
    this.phone,
    required this.selected,
    required this.onToggle,
    required this.showDivider,
  });

  final String clientId;
  final String name;
  final String? phone;
  final bool selected;
  final VoidCallback onToggle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = legacy.AppColors.accent(clientAccentKeyFor(clientId));
    final initial = name.isNotEmpty ? name.characters.first : '?';
    final subtitle = phone?.trim().isNotEmpty == true ? phone!.trim() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        EntityPickerOptionRow(
          selected: selected,
          onSelect: onToggle,
          leadingWidth: 36,
          showDivider: false,
          showSelectionMark: false,
          title: name,
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle,
                  textDirection: TextDirection.ltr,
                  style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
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
