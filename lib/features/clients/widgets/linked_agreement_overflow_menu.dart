import 'package:flutter/material.dart';

import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../l10n/app_localizations.dart';

List<AppOverflowMenuAction> linkedAgreementOverflowActions({
  required AppLocalizations l10n,
  required VoidCallback onEdit,
  required VoidCallback onUnlink,
}) =>
    [
      AppOverflowMenuAction(
        label: l10n.craftsmanDetailEditAgreement,
        icon: Assets.icons.documentEditOutline,
        onSelected: onEdit,
      ),
      AppOverflowMenuAction(
        label: l10n.unlink,
        icon: Assets.icons.deleteSquareOutline,
        onSelected: onUnlink,
        destructive: true,
      ),
    ];

class LinkedAgreementOverflowMenu extends StatelessWidget {
  const LinkedAgreementOverflowMenu({
    super.key,
    required this.menuKey,
    required this.actions,
  });

  final Key menuKey;
  final List<AppOverflowMenuAction> actions;

  @override
  Widget build(BuildContext context) {
    return AppOverflowMenu(
      buttonKey: menuKey,
      actions: actions,
    );
  }
}
