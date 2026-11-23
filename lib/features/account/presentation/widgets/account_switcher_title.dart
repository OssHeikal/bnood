import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/account/account_context_providers.dart';
import '../../../../core/account/account_office_providers.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_pressable.dart';
import 'package:bnood/l10n/app_localizations.dart';
import '../account_switcher_actions.dart';

class AccountSwitcherTitle extends ConsumerWidget {
  const AccountSwitcherTitle({
    super.key,
    required this.displayName,
    this.greeting,
  });

  final String displayName;
  final String? greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final colors = context.colors;
    final showSwitcher = ref.watch(accountSwitcherVisibleProvider);
    final ctx = ref.watch(accountContextProvider);
    final selectedOffice = ref.watch(selectedOfficeMembershipProvider);

    final title = accountDisplayTitle(
      isPersonal: ctx.isPersonal,
      personalName: displayName,
      selectedOffice: selectedOffice,
    );
    final resolvedTitle = title.isNotEmpty
        ? title
        : (ctx.isPersonal ? l10n.accountScopePersonal : l10n.homeAppName);

    final titleWidget = showSwitcher
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  resolvedTitle,
                  style: text.pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSize.spaceXS.gap,
              Icon(Icons.expand_more, size: 18, color: colors.onSurfaceMuted),
            ],
          )
        : Text(
            resolvedTitle,
            style: text.pageTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (greeting != null)
          Text(
            greeting!,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        titleWidget,
      ],
    );

    if (!showSwitcher) {
      return column;
    }

    return Semantics(
      button: true,
      label: l10n.accountSwitchTitle,
      child: AppPressable(
        onPressed: () => showAccountSwitcherSheet(context, ref),
        child: column,
      ),
    );
  }
}